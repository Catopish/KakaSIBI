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

    private let enemyLabels = ["Aku", "Kamu", "Dia", "Kita", "Mereka", "Kami"]

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
        
        // Initialize road
        let roadHeight: CGFloat = size.height / 5
        let roadSize = CGSize(width: size.width, height: roadHeight)
        let roadY = -size.height / 2 + roadHeight / 2

        road1 = SKSpriteNode(color: .gray, size: roadSize)
        road1.position = CGPoint(x: 0, y: roadY)
        addChild(road1)

        road2 = SKSpriteNode(color: .gray, size: roadSize)
        road2.position = CGPoint(x: road1.position.x + road1.size.width, y: roadY)
        addChild(road2)

        // Initialize player
        player = SKSpriteNode(imageNamed: "NewSpaceship")
        player.size = CGSize(width: 100, height: 100)
        let playerY = road1.position.y + road1.size.height / 2 + player.size.height / 2 + 10
        let playerX = -size.width / 2 + player.size.width
        player.position = CGPoint(x: playerX, y: playerY)
        addChild(player)

        observeHandSigns()

        let spawnAction = SKAction.repeatForever(SKAction.sequence([
            SKAction.run { [weak self] in self?.spawnEnemy() },
            SKAction.wait(forDuration: 2.0)
        ]))
        run(spawnAction)
    }

    private func spawnEnemy() {
        guard let label = enemyLabels.randomElement() else { return }

        let enemy = SKSpriteNode(color: .red, size: CGSize(width: 80, height: 80))
        enemy.name = label

        let labelNode = SKLabelNode(text: label)
        labelNode.fontSize = 20
        labelNode.fontColor = .white
        labelNode.verticalAlignmentMode = .center
        enemy.addChild(labelNode)

        let startX = size.width / 2 + enemy.size.width
        let enemyY = player.position.y
        enemy.position = CGPoint(x: startX, y: enemyY)
        enemy.zPosition = 1
        addChild(enemy)

        let move = SKAction.move(to: CGPoint(x: player.position.x, y: enemyY), duration: 4.0)
        let remove = SKAction.removeFromParent()

        let sequence = SKAction.sequence([move, remove])
        enemy.run(sequence)

        // Collision detection
        let checkCollision = SKAction.repeatForever(SKAction.sequence([
            SKAction.run { [weak self, weak enemy] in
                guard let self = self, let enemy = enemy else { return }
                if enemy.frame.intersects(self.player.frame) {
                    self.gameOver()
                }
            },
            SKAction.wait(forDuration: 0.1)
        ]))
        enemy.run(checkCollision)
    }

    private func gameOver() {
        removeAllActions()

        // Stop all enemy actions
        for child in children {
            if enemyLabels.contains(child.name ?? "") {
                child.removeAllActions()
            }
        }

        showGameOverOverlay()
    }

    private func showGameOverOverlay() {
        let overlay = SKShapeNode(rectOf: CGSize(width: size.width * 0.8, height: size.height * 0.4), cornerRadius: 20)
        overlay.fillColor = .black
        overlay.alpha = 0.8
        overlay.position = CGPoint.zero
        overlay.zPosition = 1000
        overlay.name = "gameOverOverlay"
        addChild(overlay)

        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontSize = 40
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: 0, y: 60)
        overlay.addChild(gameOverLabel)

        let retryLabel = SKLabelNode(text: "Retry")
        retryLabel.name = "retry"
        retryLabel.fontSize = 30
        retryLabel.fontColor = .green
        retryLabel.position = CGPoint(x: 0, y: 10)
        overlay.addChild(retryLabel)

        let menuLabel = SKLabelNode(text: "Main Menu")
        menuLabel.name = "mainMenu"
        menuLabel.fontSize = 30
        menuLabel.fontColor = .yellow
        menuLabel.position = CGPoint(x: 0, y: -40)
        overlay.addChild(menuLabel)
    }

    private func observeHandSigns() {
        guard let cameraModel = cameraModel else { return }

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
        case "Aku", "Dia", "Kita", "Mereka", "Kami":
            player.texture = SKTexture(imageNamed: "Spaceship_1")
        default:
            player.texture = SKTexture(imageNamed: "NewSpaceship")
        }

        destroyEnemy(named: prediction)
    }

    private func destroyEnemy(named name: String) {
        let matchingEnemies = children.filter { $0.name == name }
        guard let closest = matchingEnemies.min(by: {
            $0.position.distance(to: player.position) < $1.position.distance(to: player.position)
        }) else { return }

        let fade = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        closest.run(SKAction.sequence([fade, remove]))
    }

    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let nodesAtPoint = nodes(at: location)

        for node in nodesAtPoint {
            if node.name == "retry" {
                restartGame()
            } else if node.name == "mainMenu" {
                goToMainMenu()
            }
        }
    }


    private func restartGame() {
        let newScene = GameScene(size: size, cameraModel: cameraModel!)
        newScene.scaleMode = scaleMode
        view?.presentScene(newScene, transition: .fade(withDuration: 1.0))
    }

    private func goToMainMenu() {
        let menuScene = SKScene(size: size)
        menuScene.scaleMode = scaleMode
        menuScene.backgroundColor = .black

        let label = SKLabelNode(text: "Main Menu")
        label.fontSize = 50
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: 0)
        menuScene.addChild(label)

        view?.presentScene(menuScene, transition: .fade(withDuration: 1.0))
    }
}

