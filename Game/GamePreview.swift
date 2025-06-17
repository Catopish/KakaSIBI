// GamePreview.swift

import SwiftUI
import SpriteKit

struct GamePreview: View {
    @StateObject private var cameraModel = CameraModel()

    var scene: SKScene {
        let s = GameScene(size: CGSize(width: 800, height: 600), cameraModel: cameraModel)
        s.scaleMode = .resizeFill
        return s
    }

    var body: some View {
        ZStack {
            CameraPreview(session: cameraModel.session)
            TransparentSpriteView(scene: scene)
                .ignoresSafeArea()
        }
        .onAppear {
            cameraModel.start()
        }
    }
}


#Preview {
    GamePreview()
}
