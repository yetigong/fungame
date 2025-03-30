//
//  GameScene.swift
//  fungame Shared
//
//  Created by Bo Pan on 3/29/25.
//

import SpriteKit

class GameScene: SKScene {
    
    private var player: SKSpriteNode!
    private var moveLeftButton: SKSpriteNode!
    private var moveRightButton: SKSpriteNode!
    private var attackButton: SKSpriteNode!
    private var isMovingLeft = false
    private var isMovingRight = false
    private var playerSpeed: CGFloat = 5.0
    private var attackCooldown = false
    
    // Health and scoring system
    private var playerHealth: Int = 100
    private var score: Int = 0
    private var healthBar: SKShapeNode!
    private var scoreLabel: SKLabelNode!
    private var gameOver = false
    
    // Visual effects
    private var particleEmitter: SKEmitterNode?
    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    func setUpScene() {
        // Set up background with gradient
        let background = SKSpriteNode(color: .black, size: frame.size)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = -1
        addChild(background)
        
        // Add star field effect
        setupStarField()
        
        // Create player with glow effect
        player = SKSpriteNode(color: .blue, size: CGSize(width: 50, height: 50))
        player.position = CGPoint(x: frame.midX, y: frame.midY)
        player.name = "player"
        player.addGlow(radius: 10, color: .blue)
        addChild(player)
        
        // Setup UI elements
        setupUI()
        
        // Create control buttons
        setupControlButtons()
        
        // Start spawning enemies
        startSpawningEnemies()
        
        // Start spawning power-ups
        startSpawningPowerUps()
    }
    
    func setupUI() {
        // Health bar
        healthBar = SKShapeNode(rectOf: CGSize(width: 200, height: 20))
        healthBar.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        healthBar.fillColor = .green
        healthBar.strokeColor = .white
        healthBar.lineWidth = 2
        addChild(healthBar)
        
        // Score label
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 100, y: frame.maxY - 50)
        addChild(scoreLabel)
    }
    
    func setupStarField() {
        for _ in 0...50 {
            let star = SKShapeNode(circleOfRadius: 1)
            star.fillColor = .white
            star.strokeColor = .white
            star.position = CGPoint(
                x: CGFloat.random(in: 0...frame.maxX),
                y: CGFloat.random(in: 0...frame.maxY)
            )
            star.zPosition = -1
            addChild(star)
            
            // Animate stars
            let moveAction = SKAction.moveBy(x: 0, y: -frame.height, duration: 4.0)
            let resetAction = SKAction.moveBy(x: 0, y: frame.height, duration: 0)
            let sequence = SKAction.sequence([moveAction, resetAction])
            star.run(SKAction.repeatForever(sequence))
        }
    }
    
    func setupControlButtons() {
        // Move left button with glow
        moveLeftButton = SKSpriteNode(color: .gray, size: CGSize(width: 60, height: 60))
        moveLeftButton.position = CGPoint(x: 100, y: 100)
        moveLeftButton.name = "moveLeftButton"
        moveLeftButton.alpha = 0.5
        moveLeftButton.addGlow(radius: 5, color: .gray)
        addChild(moveLeftButton)
        
        // Move right button with glow
        moveRightButton = SKSpriteNode(color: .gray, size: CGSize(width: 60, height: 60))
        moveRightButton.position = CGPoint(x: 200, y: 100)
        moveRightButton.name = "moveRightButton"
        moveRightButton.alpha = 0.5
        moveRightButton.addGlow(radius: 5, color: .gray)
        addChild(moveRightButton)
        
        // Attack button with glow
        attackButton = SKSpriteNode(color: .red, size: CGSize(width: 60, height: 60))
        attackButton.position = CGPoint(x: frame.maxX - 100, y: 100)
        attackButton.name = "attackButton"
        attackButton.alpha = 0.5
        attackButton.addGlow(radius: 5, color: .red)
        addChild(attackButton)
    }
    
    func startSpawningEnemies() {
        let spawnAction = SKAction.run { [weak self] in
            self?.spawnEnemy()
        }
        let waitAction = SKAction.wait(forDuration: 2.0)
        let sequence = SKAction.sequence([spawnAction, waitAction])
        run(SKAction.repeatForever(sequence))
    }
    
    func startSpawningPowerUps() {
        let spawnAction = SKAction.run { [weak self] in
            self?.spawnPowerUp()
        }
        let waitAction = SKAction.wait(forDuration: 5.0)
        let sequence = SKAction.sequence([spawnAction, waitAction])
        run(SKAction.repeatForever(sequence))
    }
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(color: .red, size: CGSize(width: 40, height: 40))
        let randomX = CGFloat.random(in: 0...frame.maxX)
        enemy.position = CGPoint(x: randomX, y: frame.maxY + 50)
        enemy.name = "enemy"
        enemy.addGlow(radius: 5, color: .red)
        addChild(enemy)
        
        // Move enemy down
        let moveAction = SKAction.moveBy(x: 0, y: -frame.height - 100, duration: 4.0)
        let removeAction = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    func spawnPowerUp() {
        let powerUp = SKSpriteNode(color: .yellow, size: CGSize(width: 30, height: 30))
        let randomX = CGFloat.random(in: 0...frame.maxX)
        powerUp.position = CGPoint(x: randomX, y: frame.maxY + 50)
        powerUp.name = "powerUp"
        powerUp.addGlow(radius: 5, color: .yellow)
        addChild(powerUp)
        
        // Move power-up down
        let moveAction = SKAction.moveBy(x: 0, y: -frame.height - 100, duration: 3.0)
        let removeAction = SKAction.removeFromParent()
        powerUp.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gameOver { return }
        
        // Handle player movement
        if isMovingLeft {
            player.position.x -= playerSpeed
        }
        if isMovingRight {
            player.position.x += playerSpeed
        }
        
        // Keep player within bounds
        player.position.x = max(player.size.width/2, min(frame.maxX - player.size.width/2, player.position.x))
        
        // Check for collisions
        checkCollisions()
    }
    
    func checkCollisions() {
        enumerateChildNodes(withName: "enemy") { node, _ in
            if let enemy = node as? SKSpriteNode {
                if this.player.frame.intersects(enemy.frame) {
                    this.handleEnemyCollision()
                    enemy.removeFromParent()
                }
            }
        }
        
        enumerateChildNodes(withName: "powerUp") { node, _ in
            if let powerUp = node as? SKSpriteNode {
                if this.player.frame.intersects(powerUp.frame) {
                    this.handlePowerUpCollision()
                    powerUp.removeFromParent()
                }
            }
        }
    }
    
    func handleEnemyCollision() {
        playerHealth -= 20
        updateHealthBar()
        
        // Visual feedback
        player.run(SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
        ]))
        
        if playerHealth <= 0 {
            gameOver()
        }
    }
    
    func handlePowerUpCollision() {
        playerHealth = min(100, playerHealth + 30)
        updateHealthBar()
        
        // Visual feedback
        player.run(SKAction.sequence([
            SKAction.colorize(with: .green, colorBlendFactor: 1.0, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
        ]))
    }
    
    func updateHealthBar() {
        let healthPercentage = CGFloat(playerHealth) / 100.0
        healthBar.xScale = healthPercentage
    }
    
    func updateScore(points: Int) {
        score += points
        scoreLabel.text = "Score: \(score)"
    }
    
    func gameOver() {
        gameOver = true
        
        // Create game over label
        let gameOverLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gameOverLabel.text = "Game Over! Score: \(score)"
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverLabel.addGlow(radius: 10, color: .white)
        addChild(gameOverLabel)
        
        // Add restart button
        let restartButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        restartButton.text = "Tap to Restart"
        restartButton.fontSize = 24
        restartButton.fontColor = .white
        restartButton.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        restartButton.name = "restartButton"
        restartButton.addGlow(radius: 5, color: .white)
        addChild(restartButton)
    }
    
    func performAttack() {
        if attackCooldown { return }
        
        attackCooldown = true
        let attackArea = SKSpriteNode(color: .yellow, size: CGSize(width: 100, height: 50))
        attackArea.position = CGPoint(x: player.position.x + 50, y: player.position.y)
        attackArea.name = "attackArea"
        attackArea.addGlow(radius: 10, color: .yellow)
        addChild(attackArea)
        
        // Remove attack area after animation
        let waitAction = SKAction.wait(forDuration: 0.3)
        let removeAction = SKAction.removeFromParent()
        attackArea.run(SKAction.sequence([waitAction, removeAction]))
        
        // Check for hits
        enumerateChildNodes(withName: "enemy") { node, _ in
            if let enemy = node as? SKSpriteNode {
                if attackArea.frame.intersects(enemy.frame) {
                    enemy.removeFromParent()
                    this.updateScore(points: 10)
                }
            }
        }
        
        // Reset cooldown
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.attackCooldown = false
        }
    }
}

// Extension for glow effect
extension SKSpriteNode {
    func addGlow(radius: Float, color: SKColor) {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": radius])
        
        let spriteCopy = SKSpriteNode(texture: self.texture)
        spriteCopy.color = color
        spriteCopy.colorBlendFactor = 0.5
        
        effectNode.addChild(spriteCopy)
        self.addChild(effectNode)
    }
}

extension SKLabelNode {
    func addGlow(radius: Float, color: SKColor) {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": radius])
        
        let labelCopy = SKLabelNode(fontNamed: self.fontName)
        labelCopy.text = self.text
        labelCopy.fontSize = self.fontSize
        labelCopy.fontColor = color
        labelCopy.position = self.position
        
        effectNode.addChild(labelCopy)
        self.addChild(effectNode)
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = nodes(at: location).first
            
            if gameOver {
                if touchedNode?.name == "restartButton" {
                    restartGame()
                }
                return
            }
            
            switch touchedNode?.name {
            case "moveLeftButton":
                isMovingLeft = true
            case "moveRightButton":
                isMovingRight = true
            case "attackButton":
                performAttack()
            default:
                break
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = nodes(at: location).first
            
            switch touchedNode?.name {
            case "moveLeftButton":
                isMovingLeft = false
            case "moveRightButton":
                isMovingRight = false
            default:
                break
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    func restartGame() {
        // Remove all existing nodes
        removeAllChildren()
        
        // Reset game state
        playerHealth = 100
        score = 0
        gameOver = false
        
        // Set up new game
        setUpScene()
    }
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let touchedNode = nodes(at: location).first
        
        if gameOver {
            if touchedNode?.name == "restartButton" {
                restartGame()
            }
            return
        }
        
        switch touchedNode?.name {
        case "moveLeftButton":
            isMovingLeft = true
        case "moveRightButton":
            isMovingRight = true
        case "attackButton":
            performAttack()
        default:
            break
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        let location = event.location(in: self)
        let touchedNode = nodes(at: location).first
        
        switch touchedNode?.name {
        case "moveLeftButton":
            isMovingLeft = false
        case "moveRightButton":
            isMovingRight = false
        default:
            break
        }
    }
}
#endif

