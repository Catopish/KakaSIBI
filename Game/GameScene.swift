//
//  GameScene.swift
//  MachineLearningChallenge
//

// GameScene.swift

import SpriteKit

class GameScene: SKScene {
    private var player: SKSpriteNode!
    private var cameraModel: CameraModel?
    private var road1: SKSpriteNode!
    private var road2: SKSpriteNode!
    

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
        let roadHeight: CGFloat = size.height / 5
        let roadSize = CGSize(width: size.width, height: roadHeight)
        let roadY = -size.height / 2 + roadHeight / 2// align to bottom, with some padding


        // 🛣️ Add road1
        road1 = SKSpriteNode(color: .gray, size: roadSize) // Use any color here
        road1.position = CGPoint(x: 0, y: roadY)
        road1.zPosition = 0
        addChild(road1)

        road2 = SKSpriteNode(color: .blue, size: roadSize) // Same color to match
        road2.position = CGPoint(x: road1.position.x + road1.size.width, y: roadY)
        road2.zPosition = 0
        addChild(road2)

        // 🚀 Player
        player = SKSpriteNode(imageNamed: "NewSpaceship")
        player.size = CGSize(width: 100, height: 100)
        player.position = .zero
        addChild(player)

        observeHandSigns()
        startScrollingRoad()
    }

    
    private func startScrollingRoad() {
        let scrollSpeed: CGFloat = 100.0 // pixels per second

        let updateAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            let deltaTime: CGFloat = 1.0 / 60.0
            let moveAmount = scrollSpeed * deltaTime

            self.road1.position.x -= moveAmount
            self.road2.position.x -= moveAmount

            // Reposition when offscreen to the left
            if self.road1.position.x <= -self.road1.size.width {
                self.road1.position.x = self.road2.position.x + self.road2.size.width
            }

            if self.road2.position.x <= -self.road2.size.width {
                self.road2.position.x = self.road1.position.x + self.road1.size.width
            }
        }

        let loop = SKAction.repeatForever(SKAction.sequence([
            updateAction,
            SKAction.wait(forDuration: 1.0 / 60.0)
        ]))

        run(loop)
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

