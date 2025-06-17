//
//  GameCameraViews.swift
//  MachineLearningChallenge
//

import Foundation
import AVFoundation
import AppKit
import SwiftUI
import SpriteKit

// Camera live preview using AVCaptureVideoPreviewLayer
struct GameCameraViews: NSViewRepresentable {
    let session: AVCaptureSession

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        view.wantsLayer = true

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.setAffineTransform(CGAffineTransform(scaleX: -1, y: 1)) // Mirror front camera
        previewLayer.frame = view.bounds
        previewLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        view.layer?.addSublayer(previewLayer)

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard let previewLayer = nsView.layer?.sublayers?.first as? AVCaptureVideoPreviewLayer else {
            return
        }
        previewLayer.frame = nsView.bounds
    }
}

// Transparent SpriteKit view that overlays on top
struct TransparentSpriteView: NSViewRepresentable {
    let scene: SKScene

    func makeNSView(context: Context) -> SKView {
        let skView = SKView()
        skView.allowsTransparency = true
        skView.presentScene(scene)
        return skView
    }

    func updateNSView(_ nsView: SKView, context: Context) {
        // No need to update scene here
    }
}
