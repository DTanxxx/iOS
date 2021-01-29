//
//  GameScene.swift
//  Throwing bananas
//
//  Created by David Tan on 21/01/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var buildings = [BuildingNode]()
    weak var viewController: GameViewController!  // resolves strong reference cycle
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!
    
    var currentPlayer = 1
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        
        createBuildings()
        createPlayers()
    }
    
    func createBuildings() {
        // Objective: move horizontally across the screen, filling space with buildings of various sizes until it hits the far edge of the screen.
        var currentX: CGFloat = -15
        
        while currentX < 1024 {
            let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))  // make the width a multiple of 40
            currentX += size.width + 2  // make a 2-pixel gap between each building
            
            let building = BuildingNode(color: UIColor.red, size: size)  // set color to red for now (since we are using the parent init()), setup() will configure color correctly later on
            building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)  // Remember: SpriteKit positions nodes based on their center, so we need to do a little division of width and height to place these buildings correctly.
            building.setup()
            addChild(building)  // MARK: - DO NOT FORGET!!
            
            buildings.append(building)
        }
    }
    
    func createPlayers() {
        player1 = SKSpriteNode(imageNamed: "player")
        player1.name = "player1"
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
        player1.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player1.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody?.isDynamic = false
        
        let player1Building = buildings[1]
        player1.position = CGPoint(x: player1Building.position.x, y: player1Building.position.y + ((player1Building.size.height + player1.size.height) / 2))
        addChild(player1)
        
        player2 = SKSpriteNode(imageNamed: "player")
        player2.name = "player2"
        player2.physicsBody = SKPhysicsBody(circleOfRadius: player2.size.width / 2)
        player2.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player2.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody?.isDynamic = false
        
        let player2Building = buildings[buildings.count - 2]
        player2.position = CGPoint(x: player2Building.position.x, y: player2Building.position.y + ((player2Building.size.height + player2.size.height) / 2))
        addChild(player2)
    }
    
    func launch(angle: Int, velocity: Int) {
        // 1. Figure out how hard to throw the banana.
        let speed = Double(velocity) / 10.0
        
        // 2. Convert the input angle to radians.
        let radians = deg2rad(degrees: angle)
        
        // 3. If somehow there's a banana already, we'll remove it then create a new one using circle physics.
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody?.categoryBitMask = CollisionTypes.banana.rawValue
        banana.physicsBody?.collisionBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody?.contactTestBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody?.usesPreciseCollisionDetection = true
        addChild(banana)
        
        if currentPlayer == 1 {
            // 4. If player 1 was throwing the banana, we position it up and to the left of the player and give it some spin.
            banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            banana.physicsBody?.angularVelocity = -20
            
            // 5. Animate player 1 throwing their arm up then putting it down again.
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player1.run(sequence)
            
            // 6. Make the banana move in the correct direction.
            let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        } else {
            // 7. If player 2 was throwing the banana, we position it up and to the right, apply the opposite spin, then make it move in the correct direction.
            banana.position = CGPoint(x: player2.position.x + 30, y:  player2.position.y + 40)
            banana.physicsBody?.angularVelocity = 20
            
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player2.run(sequence)
            
            let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        }
    }
    
    func deg2rad(degrees: Int) -> Double {
        return Double(degrees) * Double.pi / 180
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        
        // using below logic and setting above SKPhysicsBody variables with it will eliminate some of the checks that we need to do in order to determine 'what collided with what'
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            // eg: if bodyA is banana and bodyB is building, then firstBody = banana and secondBody = building
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            // ... if bodyA is building and bodyB is banana, then firstBody = banana and secondBody = building
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        // at this point we no longer need to check for whether 'A collided with B' or 'B collided with A' because for either case we have an universal set of colliding bodies: the one with lower categoryBitMask goes to firstBody and the one with higher categoryBitMask goes to secondBody
        
        // the philosophical situation of 'bodyA x bodyB' and 'bodyB x bodyA' happening at the same time needs to be dealt with, therefore we need to check for nil since banana WILL BE REMOVED IMMEDIATELY after the first collision within the simultaneous set
        guard let firstNode = firstBody.node else { return }
        guard let secondNode = secondBody.node else { return }
        
        if firstNode.name == "banana" && secondNode.name == "building" {
            bananaHit(building: secondNode, atPoint: contact.contactPoint)
        }
        
        if firstNode.name == "banana" && secondNode.name == "player1" {
            destroy(player: player1)
        }
        
        if firstNode.name == "banana" && secondNode.name == "player2" {
            destroy(player: player2)
        }
    }
    
    func destroy(player: SKSpriteNode) {
        if let explosion = SKEmitterNode(fileNamed: "hitPlayer") {
            explosion.position = player.position
            addChild(explosion)
        }
        
        player.removeFromParent()
        banana.removeFromParent()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // create a new scene
            let newGame = GameScene(size: self.size)
            // set newGame's viewController property
            newGame.viewController = self.viewController
            // change GameViewController's currentGame property to newGame
            self.viewController.currentGame = newGame
            // above assigning statements are possible because of object referencing in memory
            
            // change the current player
            self.changePlayer()
            newGame.currentPlayer = self.currentPlayer
            
            // create a transition between scenes that takes place when the game ends
            let transition = SKTransition.doorway(withDuration: 1.5)
            self.view?.presentScene(newGame, transition: transition)
        }
    }
    
    func changePlayer() {
        if currentPlayer == 1 {
            currentPlayer = 2
        } else {
            currentPlayer = 1
        }
        
        viewController.activatePlayer(number: currentPlayer)
    }
    
    // this method creates explosion, deletes the banana and changes players
    func bananaHit(building: SKNode, atPoint contactPoint: CGPoint) {
        guard let building = building as? BuildingNode else { return }
        // change how contactPoint's coordinates are represented by using the coordinate system of a building node instead - so that it's easier to manipulate inside the BuildingNode class
        
        // MARK: - the origin (0,0) of a Scene is at bottom left corner; the origin (0,0) of a SKSpriteNode is at the center
        
        let buildingLocation = convert(contactPoint, to: building)  // collision point is converted such that it is now represented relative to the building sprite node's coordinate system ie (0,0) at the center
        building.hit(at: buildingLocation)
        
        if let explosion = SKEmitterNode(fileNamed: "hitBuilding") {
            explosion.position = contactPoint
            addChild(explosion)
        }
        
        banana.name = ""  // if a banana just so happens to hit two buildings at the same time, then it will explode twice and thus call changePlayer() twice – effectively giving the player another throw - therefore we need to prevent that by setting banana.name to "" to terminate didBegin if statements
        banana.removeFromParent()
        banana = nil
        
        changePlayer()
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard banana != nil else { return }
        
        // if banana's y position is either > 1000 or < -1000 we know it's off screen and we change the player
        if abs(banana.position.y) > 1000 {
            banana.removeFromParent()
            banana = nil
            changePlayer()
        }
    }
    
    
}
// Texture atlas is an image that consists of multiple pictures. To render one of those pictures SpriteKit loads the whole atlas and just draws a small window that represents the image you want.
// Texture atlas allows SpriteKit to draw lots of images without having to load and unload textures - it effectively just crops the big image as needed.
// You can create a texture atlas through the Assets.xcassets tab.
