//
//  GameScene.swift
//  Space Race
//
//  Created by David Tan on 16/12/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let possibleEnemies = ["ball", "hammer", "tv"]
    var isGameOver = false
    var gameTimer: Timer?
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var enemiesCreated = 0
    var interval = 1.0
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        starfield = SKEmitterNode(fileNamed: "starfield")!
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1
        // This is positioned at X:1024 Y:384, so at the right edge of screen. Therefore most of the screen wouldn't start with particles at first and particles would just stream in from the right.
        // By using the advanceSimulationTime() method of the emitter we’re going to ask SpriteKit to simulate 10 seconds passing in the emitter, thus updating all the particles as if they were created 10 seconds ago.
        // So the screen will be filled with particles
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        // Since the spaceship is an irregular shape and the objects in space are also irregular, we're going to use per-pixel collision detection rather than regular shapes.
        // We set the contact test bit mask for our player to be 1. This will match the category bit mask we will set for space debris later on.
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
       
        score = 0
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        // Set the gravity of our physics world to be empty.
        
        physicsWorld.contactDelegate = self
        
        // this timer is started automatically
        gameTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    @objc func createEnemy() {
        
        if player.parent == nil {
            return
        }
        
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        
        enemiesCreated += 1
        if enemiesCreated % 20 == 0 {
            interval -= 0.1
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            // remove the debris node once it has gone past x=-300
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if location.x < player.position.x-50 || location.x > player.position.x+50 || location.y < player.position.y-50 || location.y > player.position.y+50 {
            return
        }
                
        // clamp the y position of user's touch so that the player is restricted within a certain height range
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
    }
    
    // this method handles collision
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        
        isGameOver = true
    }
    
    
}
