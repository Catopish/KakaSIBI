import SwiftUI
import AppKit       // for NSView
import AVFoundation // for AVCaptureSession

struct ContentView: View {
    @StateObject private var camera = CameraModel()

    var body: some View {
        VStack {
            // 1) The live preview
            CameraPreview(session: camera.session)
                .frame(width: 640, height: 480)
                .cornerRadius(8)
                .shadow(radius: 4)
            
            // 2) The last predicted label
            Text(camera.lastPrediction)
                .font(.title)
                .padding(.top, 8)
        }
        .padding()
        .onAppear { camera.start() }
    }
}

/// Bridges an AVCaptureVideoPreviewLayer into SwiftUI on macOS
struct CameraPreview: NSViewRepresentable {
    let session: AVCaptureSession

    func makeNSView(context: Context) -> NSView {
        // a blank NSView that hosts the preview layer
        let view = NSView(frame: .zero)
        view.wantsLayer = true
        
        // attach the video preview
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        previewLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        view.layer?.addSublayer(previewLayer)
        
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        // keep the preview layer filling the view on resize
        guard let previewLayer = nsView.layer?.sublayers?.first as? AVCaptureVideoPreviewLayer else {
            return
        }
        previewLayer.frame = nsView.bounds
    }
}
