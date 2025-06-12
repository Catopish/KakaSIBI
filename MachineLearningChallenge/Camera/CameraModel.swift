//
//  CameraModel.swift
//  MachineLearningChallenge
//
//  Created by Al Amin Dwiesta on 12/06/25.
//

import SwiftUI
import AVFoundation
import Vision
import CoreML

final class CameraModel: NSObject, ObservableObject {
    // MARK: – public
    @Published var lastPrediction = "…"
    let session = AVCaptureSession()
    
    // MARK: – private
    private let classifier: SIBIClassifier
    private var poseBuffer = [[Float]]()   // each frame: 21 joints × 3 floats
    private let jointNames: [VNHumanHandPoseObservation.JointName] = [
      .wrist,
      .thumbCMC, .thumbMP, .thumbIP, .thumbTip,
      .indexMCP, .indexPIP, .indexDIP, .indexTip,
      .middleMCP, .middlePIP, .middleDIP, .middleTip,
      .ringMCP, .ringPIP, .ringDIP, .ringTip,
      .littleMCP, .littlePIP, .littleDIP, .littleTip
    ]
    
    override init() {
        // 1) instantiate your compiled model
        guard let m = try? SIBIClassifier() else {
            fatalError("Failed to load SIBIClassifier.mlmodel")
        }
        classifier = m
        
        super.init()
        setupSession()
    }
    
    func start() {
        session.startRunning()
    }
    
    private func setupSession() {
        session.sessionPreset = .high
        guard
          let cam = AVCaptureDevice.default(for: .video),
          let input = try? AVCaptureDeviceInput(device: cam),
          session.canAddInput(input)
        else { fatalError("Cannot access camera") }
        session.addInput(input)

        let out = AVCaptureVideoDataOutput()
        out.setSampleBufferDelegate(self, queue: .global(qos: .userInitiated))
        guard session.canAddOutput(out) else { fatalError("Cannot add output") }
        session.addOutput(out)
    }
    
    private func classifyIfReady() {
        guard poseBuffer.count == 90 else { return }   // wait until buffer is full
        
        // build the MLMultiArray [90, 3, 21]
        guard let arr = try? MLMultiArray(shape: [90,3,21], dataType: .float32) else {
            return
        }
        
        for t in 0..<90 {
            let frame = poseBuffer[t]        // 63 floats
            for j in 0..<21 {
                let base = j*3
                arr[[t, 0, j] as [NSNumber]] = frame[base + 0] as NSNumber
                arr[[t, 1, j] as [NSNumber]] = frame[base + 1] as NSNumber
                arr[[t, 2, j] as [NSNumber]] = frame[base + 2] as NSNumber
            }
        }
        
        // run your model
        let input  = SIBIClassifierInput(poses: arr)
        guard let out = try? classifier.prediction(input: input) else { return }
        
        DispatchQueue.main.async {
            self.lastPrediction = out.label   // or use out.labelProbabilities
        }
    }
}

extension CameraModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let buf = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let handler = VNImageRequestHandler(cvPixelBuffer: buf, options: [:])
        let req = VNDetectHumanHandPoseRequest()
        req.maximumHandCount = 1
        
        do {
            try handler.perform([req])
            guard let obs = req.results?.first else {
                // no hand → pad a zero‐frame
                poseBuffer.append([Float](repeating: 0, count: 21*3))
                breakBufferIfNeeded()
                return
            }
            
            let points = try obs.recognizedPoints(.all)
            var frameArray = [Float]()
            frameArray.reserveCapacity(21*3)
            
            for name in jointNames {
                if let p = points[name] {
                    frameArray += [Float(p.location.x),
                                   Float(p.location.y),
                                   Float(p.confidence)]
                } else {
                    frameArray += [0,0,0]
                }
            }
            
            poseBuffer.append(frameArray)
            breakBufferIfNeeded()
            
        } catch {
            // if pose detection fails, pad zeros
            poseBuffer.append([Float](repeating: 0, count: 21*3))
            breakBufferIfNeeded()
        }
        
        classifyIfReady()
    }
    
    private func breakBufferIfNeeded() {
        if poseBuffer.count > 90 {
            poseBuffer.removeFirst(poseBuffer.count - 90)
        }
    }
}
