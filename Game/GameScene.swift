//
//  GameScene.swift
//  MachineLearningChallenge
//

// GameScene.swift

import SpriteKit

enum GameState {
    case playing
    case gameOver
    case won
}


class GameScene: SKScene {
    private var player: SKSpriteNode!
    private var cameraModel: CameraModel?
    private var road1: SKSpriteNode!
    private var road2: SKSpriteNode!
    private var lives: Int = 3
    private var heartNodes: [SKSpriteNode] = []
    private var gameState: GameState = .playing
    private var points: Int = 0
    private var canShoot = true
    private var lastProcessedPrediction: String = ""
    var previousEnemyLabel = ""
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
        let roadWidth = size.width
        let roadHeight = size.height / 4
        let roadSize = CGSize(width: size.width, height: roadHeight)

        road1 = SKSpriteNode(imageNamed: "Road1")
        road1.size = roadSize
        road1.anchorPoint = CGPoint(x: 0.5, y: 0) // anchor at bottom center
        road1.position = CGPoint(x: 0, y: -size.height / 2 - 70) // flush with bottom
        addChild(road1)

        road2 = SKSpriteNode(imageNamed: "Road2")
        road2.size = roadSize
        road2.anchorPoint = CGPoint(x: 0.5, y: 0)
        road2.position = CGPoint(x: road1.position.x + road1.size.width, y: road1.position.y)
        addChild(road2)

        // Initialize player
        player = SKSpriteNode(imageNamed: "Ninja_1")
        player.size = CGSize(width: 100, height: 100)
        let playerY = road1.position.y + road1.size.height + player.size.height / 2 - 20
        player.position = CGPoint(x: -size.width / 2 + player.size.width - 30, y: playerY)
        
        let texture1 = SKTexture(imageNamed: "Ninja_1")
        let texture2 = SKTexture(imageNamed: "Ninja_2")
        let texture3 = SKTexture(imageNamed: "Ninja_3")
        let texture4 = SKTexture(imageNamed: "Ninja_4")
        
        let textures = [texture1, texture2, texture3, texture4]
        
        let animation = SKAction.animate(with: textures, timePerFrame: 0.1)
        let repeatAnimation = SKAction.repeatForever(animation)
        
        player.run(repeatAnimation, withKey: "walkAnimation")
        addChild(player)
        
        showHearts()
        
        let scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.name = "scoreLabel"
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 0, y: size.height / 2 - 40)
        scoreLabel.zPosition = 999
        addChild(scoreLabel)
        
        observeHandSigns()
        
        let spawnAction = SKAction.repeatForever(SKAction.sequence([
            SKAction.run { [weak self] in self?.spawnEnemy() },
            SKAction.wait(forDuration: 3.0)
        ]))
        
        run(spawnAction, withKey: "spawnEnemies")
        
        
    }
    
    private func spawnEnemy() {
        guard gameState == .playing else { return }
        guard var label = enemyLabels.randomElement() else { return }

        // Make sure label is not the same as previous
        if enemyLabels.count > 1 {
            while label == previousEnemyLabel {
                label = enemyLabels.randomElement() ?? ""
            }
        }
        previousEnemyLabel = label
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
        
        let move = SKAction.move(to: CGPoint(x: player.position.x, y: enemyY), duration: 8.0)
        let remove = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([move, remove])
        enemy.run(sequence)
        
        // Collision detection
        let checkCollision = SKAction.repeatForever(SKAction.sequence([
            SKAction.run { [weak self, weak enemy] in
                guard let self = self, let enemy = enemy else { return }

                // Don't do anything if enemy is exploding or already hit
                let hasCollided = enemy.userData?["hasCollided"] as? Bool ?? false
                let isExploding = enemy.userData?["isExploding"] as? Bool ?? false

                if enemy.frame.intersects(self.player.frame),
                   !hasCollided,
                   !isExploding {
                    
                    enemy.userData?["hasCollided"] = true
                    enemy.removeAllActions()
                    enemy.removeFromParent()
                    self.loseLife()
                }
            },
            SKAction.wait(forDuration: 0.1)
        ]))
        enemy.run(checkCollision)

        
        enemy.userData = NSMutableDictionary()
        enemy.userData?["hasCollided"] = false
    }
    
    
    private func gameOver() {
        gameState = .gameOver
        removeAllActions()
        
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
        
        if prediction != lastProcessedPrediction {
            canShoot = true
        }
        
        // Allow shooting once per new prediction
        if canShoot {
            destroyEnemy(named: prediction)
            canShoot = false
        }
        
        // Track current prediction for future comparison
        lastProcessedPrediction = prediction
    }
    
    private func destroyEnemy(named name: String) {
        let matchingEnemies = children.compactMap { $0 as? SKSpriteNode }
            .filter {
                $0.name == name &&
                $0.position.x >= player.position.x &&
                enemyLabels.contains($0.name ?? "")
            }

        guard let closest = matchingEnemies.min(by: {
            $0.position.x < $1.position.x
        }) else { return }

        // Optional: Add a range check to prevent far enemies being destroyed
        let maxRange: CGFloat = 800
        if closest.position.x - player.position.x > maxRange {
            return // too far, don't shoot
        }

//        let fade = SKAction.fadeOut(withDuration: 0.3)
        
        closest.userData = closest.userData ?? NSMutableDictionary()
        closest.userData?["isExploding"] = true

        let explosionTexture1 = SKTexture(imageNamed: "Explosion_1")
        let explosionTexture2 = SKTexture(imageNamed: "Explosion_2")
        let explosionTexture3 = SKTexture(imageNamed: "Explosion_3")
        let explosionTexture4 = SKTexture(imageNamed: "Explosion_4")
        let explosionTexture5 = SKTexture(imageNamed: "Explosion_5")
        let explosionTexture6 = SKTexture(imageNamed: "Explosion_6")
        let explosionTexture7 = SKTexture(imageNamed: "Explosion_7")
        

        let explosionTextures: [SKTexture] = [explosionTexture1, explosionTexture2, explosionTexture3, explosionTexture4, explosionTexture5, explosionTexture6, explosionTexture7]
        
        let Explodinganimation = SKAction.animate(with: explosionTextures, timePerFrame: 0.1)
        
        let remove = SKAction.removeFromParent()
        closest.run(SKAction.sequence([Explodinganimation, remove, ]))

        points += 1

        print("Enemy distance: \(closest.position.x - player.position.x)")

        if let scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode {
            scoreLabel.text = "Score: \(points)"
        }

        if points >= 15 {
            endGameWithWin()
        }
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
    
    private func loseLife() {
        lives = lives - 1
        updateHeartsDisplay()
        
        if lives <= 0 {
            gameOver()
        }
    }
    
    private func showHearts() {
        for i in 0..<lives {
            let heart = SKSpriteNode(imageNamed: "Heart") // 🖼 Make sure to add a heart image to Assets
            heart.size = CGSize(width: 40, height: 40)
            heart.position = CGPoint(x: -size.width / 2 + CGFloat(i) * 50 + 30, y: size.height / 2 - 50)
            heart.zPosition = 999
            heartNodes.append(heart)
            addChild(heart)
        }
    }
    
    private func updateHeartsDisplay() {
        for (index, heart) in heartNodes.enumerated() {
            heart.isHidden = index >= lives
        }
    }
    
    private func endGameWithWin() {
        gameState = .won
        removeAction(forKey: "spawnEnemies")
        removeAllActions()
        
        for child in children {
            if enemyLabels.contains(child.name ?? "") {
                child.removeAllActions()
            }
        }
        
        showVictoryOverlay()
    }
    
    
    private func showVictoryOverlay() {
        let overlay = SKShapeNode(rectOf: CGSize(width: size.width * 0.8, height: size.height * 0.4), cornerRadius: 20)
        overlay.fillColor = .green
        overlay.alpha = 0.8
        overlay.position = CGPoint.zero
        overlay.zPosition = 1000
        overlay.name = "victoryOverlay"
        addChild(overlay)
        
        let victoryLabel = SKLabelNode(text: "You Win!")
        victoryLabel.fontSize = 40
        victoryLabel.fontColor = .white
        victoryLabel.position = CGPoint(x: 0, y: 60)
        overlay.addChild(victoryLabel)
        
        let menuLabel = SKLabelNode(text: "Main Menu")
        menuLabel.name = "mainMenu"
        menuLabel.fontSize = 30
        menuLabel.fontColor = .yellow
        menuLabel.position = CGPoint(x: 0, y: -40)
        overlay.addChild(menuLabel)
    }
    
}
