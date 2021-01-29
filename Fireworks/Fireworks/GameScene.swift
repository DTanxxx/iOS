//
//  GameScene.swift
//  Fireworks
//
//  Created by David Tan on 19/12/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var gameTimer: Timer?
    var fireworks = [SKNode]()
    
    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22
    
    var numLaunches = 0
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 100, y: 20)
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
    
    @objc func launchFireworks() {
        numLaunches += 1
        if numLaunches > 30 {
            gameTimer?.invalidate()
            return
        }
        
        let movementAmount: CGFloat = 1800
        
        switch Int.random(in: 0...3) {
        case 0:
            // fire five, straight up
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: 0, x: 512-200, y: bottomEdge)
            createFirework(xMovement: 0, x: 512-100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512+100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512+200, y: bottomEdge)
            
        case 1:
            // fire five, in a fan
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)

        case 2:
            // fire five, from the left to the right
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)
        
        case 3:
            // fire five, from the right to the left
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)
        
        default:
            break
        }
    }
    
    @objc func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        // Create an SKNode that will act as the firework container, and place it at the position that was specified.
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        // Create a rocket sprite node, give it the name "firework" so we know that it's the important thing, adjust its colorBlendFactor property so that we can color it, then add it to the container node.
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)
        
        // Give the firework sprite node one of three random colors: cyan, green or red.
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .cyan
        case 1:
            firework.color = .green
        case 2:
            firework.color = .red
        default:
            break
        }
        
        // Create a UIBezierPath that will represent the movement of the firework.
        let path = UIBezierPath()
        path.move(to: .zero)  // sets the start point of the path to (0,0)--not visually moved, but as a point relative to the addLine() method
        // Note: you have to set a start point for the path since path is newly created and does not have its position set like node
        // Since node will follow the path of path, you need to specify the relative start point of the path--it is also needed for the addLine() method
        path.addLine(to: CGPoint(x: xMovement, y: 1000))  // move relative to the start point (right now is (0,0)) in x direction and y direction at the same time, hence creating a slope path
        
        // Tell the container node to follow that path, turning itself as needed.
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        // asOffset: whether the path coordinates are absolute or are relative to the node's current position. If you specify asOffset as true, it means any coordinates in your path are adjusted to take into account the node's position.
        // orientToPath: when it's set to true, the node will automatically rotate itself as it moves on the path so that it's always facing down the path
        node.run(move)
        
        // Create particles behind the rocket to make it look like the fireworks are lit.
        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 0, y: -22)
            node.addChild(emitter)
        }
        
        // Add the firework to our fireworks array and also to the scene.
        fireworks.append(node)
        addChild(node)
    }
    
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        // 'for case let' lets us attempt some work (typecasting to SKSpriteNode in this case), and run the loop body only for items that were successfully typecast.
        for case let node as SKSpriteNode in nodesAtPoint {
            guard node.name == "firework" else { continue }
            
            // This inner loop needs to ensure that the player can select only one firework color at a time. So if they select red then another red, both are selected. But if they then select a green, we need to deselect the first two because they are red.
            for parent in fireworks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue }
                
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            
            node.name = "selected"
            node.colorBlendFactor = 0  // rocket turns white
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // we remove fireworks from the array past a certain y value
        // we do so backwards so the issues that come with mutable array objects do not occur
        // the y value is set to 900 so that players have a little extra time to tap on other rockets before the first-tapped rocket gets removed
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                // this uses a position high above so that rockets can explode off screen
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    func explode(firework: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitter.position = firework.position
            addChild(emitter)
            let delay = SKAction.wait(forDuration: 3)
            let remove = SKAction.removeFromParent()
            emitter.run(SKAction.sequence([delay, remove]))
        }
        
        firework.removeFromParent()
    }
    
    func explodeFireworks() {
        var numExploded = 0
        
        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }
            
            if firework.name == "selected" {
                // destroy this firework
                explode(firework: fireworkContainer)
                fireworks.remove(at: index)
                
                numExploded += 1
            }
        }
        
        switch numExploded {
        case 0:
            // nothing
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }
    
}


