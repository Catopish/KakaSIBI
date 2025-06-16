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


