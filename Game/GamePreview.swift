// GamePreview.swift

import SwiftUI
import SpriteKit

struct GamePreview: View {
    @StateObject private var cameraModel = CameraModel()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CameraPreview(session: cameraModel.session,model:cameraModel)

                TransparentSpriteView(
                    scene: GameScene(size: geometry.size, cameraModel: cameraModel)
                )
                .ignoresSafeArea()
            }
            .onAppear {
                cameraModel.start()
            }
        }
    }
}



#Preview {
    GamePreview()
}
