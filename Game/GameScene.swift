//
//  GameScene.swift
//  MachineLearningChallenge
//

// GameScene.swift

import SpriteKit

class GameScene: SKScene {
    private var player: SKSpriteNode!
    private var cameraModel: CameraModel?

    init(size: CGSize, cameraModel: CameraModel) {
        self.cameraModel = cameraModel
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        player = SKSpriteNode(imageNamed: "NewSpaceship")
        player.size = CGSize(width: 100, height: 100)
        player.position = .zero
        addChild(player)

        // Start observing predictions
        observeHandSigns()
    }

    private func observeHandSigns() {
        guard let cameraModel = cameraModel else { return }

        // Use a repeating SKAction to poll for changes
        let checkAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { [weak self] in
                    self?.updateSpriteBasedOnPrediction(cameraModel.lastPrediction)
                },
                SKAction.wait(forDuration: 0.3)
            ])
        )

        run(checkAction)
    }

    private func updateSpriteBasedOnPrediction(_ prediction: String) {
        switch prediction {
        case "Aku":
            player.texture = SKTexture(imageNamed: "Spaceship_1")
        case "Kamu":
            player.texture = SKTexture(imageNamed: "NewSpaceship")
        case "Dia":
            player.texture = SKTexture(imageNamed: "Spaceship_1")
        default:
            player.texture = SKTexture(imageNamed: "NewSpaceship")
        }
    }
}

