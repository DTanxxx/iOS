//
//  GameScene.swift
//  Marble Maze
//
//  Created by David Tan on 16/01/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import SpriteKit
import CoreMotion

enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
    case teleport = 32
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    var lastTouchPosition: CGPoint?
    var motionManager: CMMotionManager!
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var isGameOver = false
    var currentLevel = 1
    var spawnPoint: CGPoint!
    var teleportPoints = [SKSpriteNode]()
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsWorld.gravity = .zero
        spawnPoint = CGPoint(x: 96, y: 672)
        
        loadLevel()
        createPlayer(at: spawnPoint)
        // note: although zPosition has been set correctly, you must create the player after the level, otherwise the player will appear below vortexes and other level objects
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
    }
    
    func loadLevel() {
        guard let levelURL = Bundle.main.url(forResource: "level\(currentLevel)", withExtension: "txt") else {
            fatalError("Could not find level\(currentLevel).txt in the app bundle.")
        }
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not load level\(currentLevel).txt from the app bundle.")
        }
        
        let lines = levelString.components(separatedBy: "\n")
        
        // reversed() is used to make an exact copy of the level1.txt maze (we want the bottom string first, then move upwards)
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                // calculate the position of each 64x64 square (to be placed in maze); the +32 serves to fit with the fact that SpriteKit calculates a position from the center of the object
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
                
                if letter == "x" {
                    // load wall
                    loadWall(at: position)
                } else if letter == "v" {
                    // load vortex
                    loadVortex(at: position)
                } else if letter == "s" {
                    // load star
                    loadStar(at: position)
                } else if letter == "f" {
                    // load finish
                    loadFinish(at: position)
                } else if letter == "t" {
                    // load teleport
                    loadTeleport(at: position)
                } else if letter == " " {
                    // this is an empty space - do nothing!
                } else {
                    fatalError("Unknown level letter: \(letter)")
                }
            }
        }
    }
    
    func loadWall(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "block")
        node.position = position
        
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        node.physicsBody?.isDynamic = false
        addChild(node)
    }
    
    func loadVortex(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "vortex")
        node.name = "vortex"
        node.position = position
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
        // set both contact test and collision bitmasks - by default collision is set to "everything" and contact test is set to "nothing"
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        addChild(node)
    }
    
    func loadStar(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "star")
        node.name = "star"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        addChild(node)
    }
    
    func loadFinish(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "finish")
        node.name = "finish"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
                           
        node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        addChild(node)
    }
    
    // MARK: - create a teleport point
    func loadTeleport(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "vortex")
        node.name = "teleport"
        node.colorBlendFactor = 0.5
        node.color = UIColor.green
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionTypes.teleport.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        
        node.position = position
        addChild(node)
        teleportPoints.append(node)
    }
    
    func createPlayer(at position: CGPoint) {
        player = SKSpriteNode(imageNamed: "player")
        player.position = position
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5
        
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue | CollisionTypes.teleport.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        addChild(player)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameOver == false else { return }
        
        #if targetEnvironment(simulator)
            if let currentTouch = lastTouchPosition {
                let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
                physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
            }
        #else
            if let accelerometerData = motionManager.accelerometerData {
                physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
                // note: accelerometer Y is passed into CGVector's X and vice versa, because the device is rotated to landscape: coordinates need to be flipped around
                // moreover there is this direction switch between portrait's y and landscape right's x
            }
        #endif
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }
    
    func playerCollided(with node: SKNode) {
        if node.name == "vortex" {
            player.physicsBody?.isDynamic = false
            isGameOver = true  // this stops update() from moving the ball, imitating a sucked-in appearance
            score -= 1
            
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            
            player.run(sequence) {
                [weak self] in
                self?.createPlayer(at: self!.spawnPoint)
                self?.isGameOver = false
            }
        } else if node.name == "teleport" {
            // MARK: - if teleport sends player to start point then there is a bug
            var nextPoint = CGPoint(x: 96, y: 672)
            
            player.physicsBody?.isDynamic = false
            isGameOver = true
            
            for teleport in teleportPoints {
                if node.position != teleport.position {
                    nextPoint = teleport.position
                }
            }
            
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            
            
            player.run(sequence) {
                [weak self] in
                self?.isGameOver = false
                self?.createPlayer(at: nextPoint)
            }
        } else if node.name == "star" {
            node.removeFromParent()
            score += 1
        } else if node.name == "finish" {
            // next level
            // MARK: - setting spawnpoints
            currentLevel += 1
            switch currentLevel {
            case 2:
                spawnPoint = CGPoint(x: 96, y: 672)
            case 3:
                spawnPoint = CGPoint(x: 96, y: 549)
            case 4:
                spawnPoint = CGPoint(x: 96, y: 672)
            default:
                return
            }
            player.position = spawnPoint
            lastTouchPosition = nil
            isGameOver = false
            
            loadLevel()  // MARK: - see if this creates a new level covering the last one
        }
    }
    
}
// categoryBitMask: defines the type of object this is for considering collisions
// collisionBitMask: defines what categories of object this node should collide with
// contactTestBitMask: defines which collisions we want to be notified about

// Every node we want to reference in our collision bitmasks or our contact test bitmasks must have a category attached.
// If you give a node a collision bitmask but not a contact test bitmask, it means they will bounce off each other but you won't be notified.
// If you do the opposite (contact test but not collision) it means they won't bounce off each other but you will be told when they overlap.
