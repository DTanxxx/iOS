//
//  GameScene.swift
//  Pachinko
//
//  Created by David Tan on 5/11/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ballCountLabel: SKLabelNode!
    var ballCount = 5 {
        didSet {
            ballCountLabel.text = "Ball Count: \(ballCount)"
        }
    }
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var editLabel: SKLabelNode!
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    // didMove is equivalent to viewDidLoad
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")  // SKSpriteNode = UIImage, which can be used to load any picture from the app bundle.
        background.position = CGPoint(x: 512, y: 384)  // Place image at the centre of the screen.
        background.blendMode = .replace  // Blend modes determine how a node is drawn. The .replace option means "just draw it, ignoring any alpha values," which makes it fast for things without gaps such as our background.
        background.zPosition = -1  // This means "draw this behind everything else".
        addChild(background)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)  // This adds a physics body to the whole scene. That is a line on each edge, effectively acting like a container for the scene.
        physicsWorld.contactDelegate = self
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        // Make a ball count label
        ballCountLabel = SKLabelNode(fontNamed: "Marker Felt")
        ballCountLabel.text = "Ball Count: 5"
        ballCountLabel.horizontalAlignmentMode = .center
        ballCountLabel.position = CGPoint(x: 512, y: 700)
        addChild(ballCountLabel)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        // Add rectangle physics to our slots.
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func makeBouncer(at position: CGPoint) {
        // Create a bouncer for the balls to bounce off.
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // It's possible a user started touching with multiple fingers at the same time, so we get passed a new data type called Set. This is just like an array, except each object can appear only once.
        
        // UITouch is a UIKit class that is also used in SpriteKit, and provides information about a touch such as its position and when it happened.
        
        // We want to know where the screen was touched, so we use a conditional typecast plus if let to pull out any of the screen touches from the touches set, then use its location(in:) method to find out where the screen was touched in relation to self - i.e., the game scene.
        // This method gets passed a set of touches that represent the user’s fingers on the screen, but in the game we don’t really care about multi-touch support so we just say touches.first.
        if let touch = touches.first {
            // touches.first is optional, because the set of touches that gets passed in doesn’t have any special way of saying “I contain at least one thing”.
            let location = touch.location(in: self)
            let objects = nodes(at: location)  // ask SpriteKit to give us a list of all the nodes at the point that was tapped
            
            if objects.contains(editLabel) {
                editingMode.toggle()
            } else {
                if editingMode {
                    // create a box
                    let size = CGSize(width: Int.random(in: 16...128), height: 16)
                    let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                    box.zRotation = CGFloat.random(in: 0...3)
                    box.position = location
                    
                    box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                    box.physicsBody?.isDynamic = false
                    box.name = "box"
                    
                    addChild(box)
                } else {
                    // create a ball
                    if ballCount == 0 { return }
                    let colorArray = ["Red", "Blue", "Yellow", "Purple", "Grey", "Cyan", "Green"]
                    let indexToUse = Int.random(in: 0...6)
                    let ball = SKSpriteNode(imageNamed: "ball" + colorArray[indexToUse])
                    ball.name = "ball"
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)  // This adds a physics body to the ball.
                    ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask  // The collisionBitMask bitmask means "which nodes should I bump into?" By default, it's set to everything, which is why our ball are already hitting each other and the bouncers. The contactTestBitMask bitmask means "which collisions do you want to know about?" and by default it's set to nothing. So by setting contactTestBitMask to the value of collisionBitMask we're saying, "tell me about every collision."
                    ball.physicsBody?.restitution = 0.4
                    let xPos = location.x
                    let yPos:CGFloat = 650
                    ball.position = CGPoint(x: xPos, y: yPos)
                    addChild(ball)
                    ballCount -= 1
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }
    
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(object: ball)
            score += 1
            ballCount += 1
        } else if object.name == "bad" {
            destroy(object: ball)
            if score > 0 {
                score -= 1
            }
        } else if object.name == "box" {
            destroy(object: object)
        }
    }
    
    func destroy(object: SKNode) {
        if object.name == "ball" {
            if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
                fireParticles.position = object.position
                addChild(fireParticles)
            }
            object.removeFromParent()
        } else if object.name == "box" {
            // make a different fire particle--copy the file and adjust it?
            if let fireParticles = SKEmitterNode(fileNamed: "FireParticles2") {
                fireParticles.position = object.position
                addChild(fireParticles)
            }
            object.removeFromParent()
        }
    }
    
    
    
}
