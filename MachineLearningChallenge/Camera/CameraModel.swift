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

/// Bridges an AVCaptureVideoPreviewLayer into SwiftUI on macOS, with joint overlays
typealias JointPoint = VNRecognizedPoint

struct CameraPreview: NSViewRepresentable {
    let session: AVCaptureSession
    @ObservedObject var model: CameraModel

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        view.wantsLayer = true

        // Preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.setAffineTransform(CGAffineTransform(scaleX: -1, y: 1))
        previewLayer.frame = view.bounds
        previewLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        view.layer?.addSublayer(previewLayer)

        // Overlay layer for joints
        let overlay = CALayer()
        overlay.frame = view.bounds
        overlay.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        overlay.name = "OverlayLayer"
        view.layer?.addSublayer(overlay)

        // Keep references
        context.coordinator.previewLayer = previewLayer
        context.coordinator.overlayLayer = overlay
        model.delegate = context.coordinator

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        // Nothing to update explicitly; overlay handled via delegate callbacks
    }

    class Coordinator: NSObject, CameraModelDelegate {
        var parent: CameraPreview
        weak var previewLayer: AVCaptureVideoPreviewLayer?
        weak var overlayLayer: CALayer?

        init(_ parent: CameraPreview) {
            self.parent = parent
        }

        /// Called by CameraModel when new points are detected
        func cameraModel(_ model: CameraModel, didDetect jointPoints: [JointPoint]) {
            guard let preview = previewLayer,
                  let overlay = overlayLayer else { return }

            DispatchQueue.main.async {
                // Clear old markers
                overlay.sublayers?.forEach { $0.removeFromSuperlayer() }

                // Draw new markers
                let markerSize: CGFloat = 8
                for point in jointPoints {
                    let capPoint = CGPoint(x: 1 - point.location.x, y: point.location.y)
                    let layerPoint = preview.layerPointConverted(fromCaptureDevicePoint: capPoint)

                    let circle = CAShapeLayer()
                    let rect = CGRect(x: layerPoint.x - markerSize/2,
                                      y: layerPoint.y - markerSize/2,
                                      width: markerSize,
                                      height: markerSize)
                    circle.path = CGPath(ellipseIn: rect, transform: nil)
                    circle.fillColor = NSColor.systemGreen.cgColor
                    overlay.addSublayer(circle)
                }
            }
        }
    }
}

protocol CameraModelDelegate: AnyObject {
    func cameraModel(_ model: CameraModel, didDetect jointPoints: [JointPoint])
}

final class CameraModel: NSObject, ObservableObject {
    @Published var lastPrediction = "…"
    let session = AVCaptureSession()

    private let classifier: SIBIClassifier
    private var poseBuffer = [[Float]]()
    private(set) var jointNames: [VNHumanHandPoseObservation.JointName] = [
        .wrist,
        .thumbCMC, .thumbMP, .thumbIP, .thumbTip,
        .indexMCP, .indexPIP, .indexDIP, .indexTip,
        .middleMCP, .middlePIP, .middleDIP, .middleTip,
        .ringMCP, .ringPIP, .ringDIP, .ringTip,
        .littleMCP, .littlePIP, .littleDIP, .littleTip
    ]

    weak var delegate: CameraModelDelegate?

    override init() {
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
        guard let cam = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: cam),
              session.canAddInput(input) else {
            fatalError("Cannot access camera")
        }
        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: .global(qos: .userInitiated))
        guard session.canAddOutput(output) else { fatalError("Cannot add output") }
        session.addOutput(output)
    }

    private func classifyIfReady() {
        guard poseBuffer.count == 90 else { return }
        guard let arr = try? MLMultiArray(shape: [90, 3, 21], dataType: .float32) else { return }

        for t in 0..<90 {
            let frame = poseBuffer[t]
            for j in 0..<21 {
                let base = j * 3
                arr[[t, 0, j] as [NSNumber]] = frame[base + 0] as NSNumber
                arr[[t, 1, j] as [NSNumber]] = frame[base + 1] as NSNumber
                arr[[t, 2, j] as [NSNumber]] = frame[base + 2] as NSNumber
            }
        }

        let input = SIBIClassifierInput(poses: arr)
        guard let out = try? classifier.prediction(input: input) else { return }
        DispatchQueue.main.async {
            self.lastPrediction = out.label
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
            let jointPoints: [VNRecognizedPoint]
            if let obs = req.results?.first {
                let points = try obs.recognizedPoints(.all)
                jointPoints = jointNames.compactMap { points[$0] }
                var frameArray = [Float]()
                frameArray.reserveCapacity(21*3)
                for p in jointPoints {
                    frameArray += [Float(p.location.x), Float(p.location.y), Float(p.confidence)]
                }
                poseBuffer.append(frameArray)
            } else {
                jointPoints = []
                poseBuffer.append([Float](repeating: 0, count: 21*3))
            }
            breakBufferIfNeeded()
            delegate?.cameraModel(self, didDetect: jointPoints)
        } catch {
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


