//
//  GameScene.swift
//  Crashed plane
//
//  Created by David Tan on 1/03/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import SpriteKit

enum GameState {
    case showingLogo
    case playing
    case dead
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
    var backgroundMusic: SKAudioNode!
    var logo: SKSpriteNode!
    var gameOver: SKSpriteNode!
    var gameState = GameState.showingLogo  // game state will be showingLogo by default
    // the following three properties are for optimisation (used to store the rock physics body to prevent unnecessary pixel scanning for pixel-perfect collision, and to store the explosion emitter node):
    let rockTexture = SKTexture(imageNamed: "rock")
    var rockPhysics: SKPhysicsBody!
    let explosion = SKEmitterNode(fileNamed: "PlayerExplosion")  // this emitter node won't actually be used in the code later on (it won't be used to create a new emitter node, we still need to create it using the SKEmitterNode(fileNamed:) initialiser), however setting this property now will force SpriteKit to preload the PlayerExplosion file and keep it in memory, so it's already there when it's really needed
    
    override func didMove(to view: SKView) {
        createPlayer()
        createSky()
        createBackground()
        createGround()
        createScore()
        createLogos()
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
        physicsWorld.contactDelegate = self
        
        // create the background music
        if let musicURL = Bundle.main.url(forResource: "music", withExtension: "m4a") {
            backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)  // MARK: - remember to call addChild()
        }
        
        // create the rock physics body
        rockPhysics = SKPhysicsBody(texture: rockTexture, size: rockTexture.size())
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method needs to distinguish between a touch when in showingLogo mode and a touch when in playing mode
        
        switch gameState {  // note that you do not use the name of enum type in switch statement -- you use the name of the PROPERTY that stores the enum type instead
        case .showingLogo:
            // change the game state to be playing (so that further touches move the plane)
            gameState = .playing
            // make the logo fade out and get removed from the game and wait for a moment before activating the player and calling startRocks() (in a sequence)
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            let wait = SKAction.wait(forDuration: 0.5)
            let activatePlayer = SKAction.run {
                [unowned self] in
                self.player.physicsBody?.isDynamic = true
                self.startRocks()
            }
            
            let sequence = SKAction.sequence([fadeOut, wait, activatePlayer, remove])
            logo.run(sequence)
            
        case .playing:
            // neutralise any existing upward velocity the player has before applying the new movement (dx is set to 0 because remember, the plane is not moving, the terrain is) -- this is needed because otherwise the player can tap multiple times quickly and apply a huge upwards force to the plane
            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            // give the player a push upwards
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
            
        case .dead:
            // create a new GameScene scene and present it
            if let scene = GameScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                let transition = SKTransition.moveIn(with: SKTransitionDirection.right, duration: 1)
                view?.presentScene(scene, transition: transition)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard player != nil else { return }
        
        // take 1/1000th of the player's upward velocity and turn that into rotation
        let value = player.physicsBody!.velocity.dy * 0.001
        let rotate = SKAction.rotate(toAngle: value, duration: 0.1)
        
        player.run(rotate)
        
        // MARK: - this method is called every frame, however when we present a new GameScene at the end we do not have a player at the time, so this method will crash since Swift will try to adjust the rotation of a nil property because the player hasn't been created yet (solution: add guard statement at the start)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "scoreDetect" || contact.bodyB.node?.name == "scoreDetect" {
            // remove the red rectangle (the scoreDetect)
            if contact.bodyA.node == player {
                contact.bodyB.node?.removeFromParent()
            } else {
                contact.bodyA.node?.removeFromParent()
            }
            
            // play a sound
            let sound = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
            run(sound)
            
            // increment the score
            score += 1
            
            return
        }
        
        // handle the philosophical case where both "A collided with B" and "B collided with A" occurs
        guard contact.bodyB.node != nil && contact.bodyA.node != nil else { return }
        
        // destroy the player if the method still runs (because it means the player has collided with something else)
        if contact.bodyA.node == player || contact.bodyB.node == player {
            // initiate explosion particle effect
            if let explosion = SKEmitterNode(fileNamed: "PlayerExplosion") {
                explosion.position = player.position
                addChild(explosion)
            }
            
            // play a sound
            let sound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
            run(sound)
            
            // set the end-game, remove the player, and change the game's speed property to 0
            gameOver.alpha = 1  // make the game over label visible
            gameState = .dead  // adjust the game state
            backgroundMusic.run(SKAction.stop())  // terminate the music
            
            player.removeFromParent()
            speed = 0
            // the speed property is a time multiplier that lets you adjust how fast actions attached to a node should run -- it's 1.0 by default (1 second in game = 1 second in real time)
            // if you set it to 2.0 then actions in game happen twice as fast -- eg "fade out over 5 seconds" that is set in code will become "fade out over 2.5 seconds" in game
        }
    }
    
    // MARK: - logo creation
    
    func createLogos() {
        logo = SKSpriteNode(imageNamed: "logo")
        logo.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(logo)
        
        gameOver = SKSpriteNode(imageNamed: "gameover")
        gameOver.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOver.alpha = 0  // hide the game over logo
        addChild(gameOver)
    }

    // MARK: - obstacle creation
    
    func createRocks() {
        // 1. Create top and bottom rock sprites. Rotate the top one so the two rocks form a spiky gap.
        let rockTexture = SKTexture(imageNamed: "rock")
        
        let topRock = SKSpriteNode(texture: rockTexture)
        // set up physics for the top rock
        topRock.physicsBody = rockPhysics.copy() as? SKPhysicsBody  // we need to use copy() on our original physics body to create a new instance, because SpriteKit needs all its physics bodies to be unique (so you can't assign the same physics body object to two sprites)
        topRock.physicsBody?.isDynamic = false
        
        topRock.zRotation = .pi
        topRock.xScale = -1.0  // xScale is used to stretch sprites horizontally; setting it to -1.0 however flips the sprite in the y-axis (it stretches the sprite by -100%, essentially inverting it)
    
        let bottomRock = SKSpriteNode(texture: rockTexture)
        // set up physics for the bottom rock
        bottomRock.physicsBody = rockPhysics.copy() as? SKPhysicsBody
        bottomRock.physicsBody?.isDynamic = false
        
        topRock.zPosition = -20
        bottomRock.zPosition = -20
        
        // 2. Create a third sprite that is a large red rectangle. This will be positioned just after the rocks and will be used to track when the player has passed through the rocks safely -- if they touch that red rectangle, they should score a point. The red rectangle will be made invisible after testing.
        let rockCollision = SKSpriteNode(color: UIColor.clear/*UIColor.red*/, size: CGSize(width: 32, height: frame.height))
        // set up physics for the red rectangle
        rockCollision.physicsBody = SKPhysicsBody(rectangleOf: rockCollision.size)
        rockCollision.physicsBody?.isDynamic = false
        
        rockCollision.name = "scoreDetect"
        
        addChild(topRock)
        addChild(bottomRock)
        addChild(rockCollision)
        
        // 3. Use random number generator to generate a number in a range. This will be used to determine where the safe gap in the rocks should be (high, low or middle).
        let xPositiion = frame.width + topRock.frame.width
        
        let max = CGFloat(frame.height / 3)
        let yPosition = CGFloat.random(in: -50...max)
        
        // this next value affects the width of the gap between rocks
        let rockDistance: CGFloat = 70
        
        // 4. Position the rocks just off the right edge of the screen, then animate them across to the left edge. When they are safely off the left edge, remove them from the game.
        topRock.position = CGPoint(x: xPositiion, y: yPosition + topRock.size.height + rockDistance)
        bottomRock.position = CGPoint(x: xPositiion, y: yPosition - rockDistance)
        rockCollision.position = CGPoint(x: xPositiion + (rockCollision.size.width * 2), y: frame.midY)
        
        let endPosition = frame.width + (topRock.frame.width * 2)
        
        let moveAction = SKAction.moveBy(x: -endPosition, y: 0, duration: 6.2)
        let moveSequence = SKAction.sequence([moveAction, SKAction.removeFromParent()])
        topRock.run(moveSequence)
        bottomRock.run(moveSequence)
        rockCollision.run(moveSequence)
    }
    
    func startRocks() {
        let create = SKAction.run {
            [unowned self] in
            self.createRocks()
        }
        
        let wait = SKAction.wait(forDuration: 3)
        let sequence = SKAction.sequence([create, wait])
        let repeatForever = SKAction.repeatForever(sequence)
        
        run(repeatForever)
    }
    
    // MARK: - set up the game scene
    
    func createPlayer() {
        let playerTexture = SKTexture(imageNamed: "player-1")
        player = SKSpriteNode(texture: playerTexture)
        player.zPosition = 10
        // set the player position to top-left
        player.position = CGPoint(x: frame.width / 6, y: frame.height * 0.75)
        
        addChild(player)
        
        // set the physics for the player
        // first set up a pixel-perfect physics using the sprite of the plane
        player.physicsBody = SKPhysicsBody(texture: playerTexture, size: playerTexture.size())
        // then make SpriteKit tell us whenever the player collides with anything
        // note that if the player's contactTestBitMask is set to 'everything' then you don't need to set the contactTestBitMask for other nodes that the player collides with; however if you only set the bit mask of player to a specific node (which requires categoryBitMask to be set to identify this node) then you also need to set the bit mask of that specific node to player
        player.physicsBody!.contactTestBitMask = player.physicsBody!.collisionBitMask
        player.physicsBody?.isDynamic = false
        // at last make the plane bounce off nothing
        player.physicsBody?.collisionBitMask = 0
        
        let frame2 = SKTexture(imageNamed: "player-2")
        let frame3 = SKTexture(imageNamed: "player-3")
        // use animate(with:) to animate the player through an array of SKTexture provided
        let animation = SKAction.animate(with: [playerTexture, frame2, frame3, frame2], timePerFrame: 0.01)
        let runForever = SKAction.repeatForever(animation)
        
        player.run(runForever)
    }
    
    func createSky() {
        let topSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.14, brightness: 0.97, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.67))
        // adjust the anchor point of topSky -- by default it is X:0.5, Y:0.5, which means the (0,0) point of the node is at its centre
        // we change it to X:0.5, Y:1 so that the (0,0) point is at the center-top
        topSky.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        let bottomSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.16, brightness: 0.96, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.33))
        bottomSky.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        topSky.position = CGPoint(x: frame.midX, y: frame.height)
        bottomSky.position = CGPoint(x: frame.midX, y: bottomSky.frame.height)
        
        addChild(topSky)
        addChild(bottomSky)
        
        bottomSky.zPosition = -40
        topSky.zPosition = -40
    }
    
    func createBackground() {
        // this method will create the endless background scrolling animations using two background sprite nodes -- make them both moving to the left; when one moves off the screen completely we are going to reset both nodes to their original positions (ie one on screen and one to the right off screen)
        // since the two nodes are identical, the reset will produce an endless scrolling effect
        
        let backgroundTexture = SKTexture(imageNamed: "background")
        
        // create two background sprite nodes
        for i in 0 ... 1 {
            let background = SKSpriteNode(texture: backgroundTexture)
            background.zPosition = -30
            // set the (0,0) point to the bottom left of node
            background.anchorPoint = CGPoint.zero
            // set the X position of each background -- the first one will be 0, the second one will be the width of the texture minus 1 (to avoid any tiny gaps in the backgrounds)
            background.position = CGPoint(x: (backgroundTexture.size().width * CGFloat(i)) - CGFloat(1 * i), y: 100)
            
            addChild(background)
            
            // move to the left for 20 seconds
            // note that although the duration of this animation is 20 seconds, it does not wait for 20 seconds before the next instruction is called; instead, the animations run asynchronously to the instructions (ie the animations take place for 20 seconds, but the program continues to run lines of code during that time)
            let moveLeft = SKAction.moveBy(x: -backgroundTexture.size().width, y: 0, duration: 20)
            // move back over to the right for 0 seconds (immediately)
            let moveReset = SKAction.moveBy(x: backgroundTexture.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            background.run(moveForever)
        }
    }
    
    func createGround() {
        // same animation mechanics as createBackground(), however: 1. we can't adjust the anchor point of the sprite because it causes problems with physics and 2. we need to make the ground move much faster than the background
        
        let groundTexture = SKTexture(imageNamed: "ground")
        
        for i in 0 ... 1 {
            let ground = SKSpriteNode(texture: groundTexture)
            ground.zPosition = -10
            ground.position = CGPoint(x: (groundTexture.size().width / 2.0 + (groundTexture.size().width * CGFloat(i))), y: groundTexture.size().height / 2)
            
            // set the physics of the ground
            ground.physicsBody = SKPhysicsBody(texture: ground.texture!, size: ground.texture!.size())
            ground.physicsBody?.isDynamic = false
            
            addChild(ground)
            
            let moveLeft = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
            let moveReset = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let runForever = SKAction.repeatForever(moveLoop)
            
            ground.run(runForever)
        }
    }
    
    func createScore() {
        scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        scoreLabel.fontSize = 24
        
        scoreLabel.text = "SCORE: 0"
        scoreLabel.fontColor = UIColor.black
        scoreLabel.position = CGPoint(x: frame.width * 2 / 3, y: frame.maxY - 60)
        
        addChild(scoreLabel)
    }
    
    
}
