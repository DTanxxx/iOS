//
//  GameScene.swift
//  Slice Penguins
//
//  Created by David Tan on 6/01/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import SpriteKit
import AVFoundation

enum SequenceType: CaseIterable {
    // We use the CaseIterable protocol here so that it will automatically add an allCases property to the SequenceType enum that lists all its cases as an array.
    // This way we can use randomElement() to pick random sequence types to run our game.
    case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain
}

enum ForceBomb {
    case never, always, random
}

class GameScene: SKScene {
    
    var gameScore: SKLabelNode!
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    var livesImages = [SKSpriteNode]()
    var lives = 3
    var activeSliceBG: SKShapeNode!  // the background slice
    var activeSliceFG: SKShapeNode!  // the foreground slice
    var activeSlicePoints = [CGPoint]()
    var isSwooshSoundActive = false
    var activeEnemies = [SKSpriteNode]()
    var bombSoundEffect: AVAudioPlayer?
    var popupTime = 0.9  // the amount of time to wait between the last enemy being destroyed and a new one being created
    var sequence = [SequenceType]()
    var sequencePosition = 0  // this is where we are right now in the game
    var chainDelay = 3.0  // how long to wait before creating a new enemy when the sequence type is .chain or .fastChain
    var nextSequenceQueued = true  // this is used so we know when all the enemies are destroyed and we're ready to create more
    var isGameEnded = false
    let quarterX = 256
    let halfX = 512
    let threeQuartersX = 768
    weak var viewController: GameViewController!
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        // reduce gravitational acceleration
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        // adjust physics world's speed downwards
        physicsWorld.speed = 0.85
        
        createScore()
        createLives()
        createSlices()
        
        sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]
        
        for _ in 0 ... 1000 {
            if let nextSequence = SequenceType.allCases.randomElement() {
                sequence.append(nextSequence)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            [weak self] in self?.tossEnemies()
        }
    }
    
    func createScore() {
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        gameScore.position = CGPoint(x: 8, y: 8)
        score = 0
    }
    
    func createLives() {
        for i in 0 ..< 3 {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
            addChild(spriteNode)
            
            livesImages.append(spriteNode)
        }
    }
    
    func createSlices() {
        // draw two slice shapes, one in white and one in yellow
        // use zPosition property to make sure the slices go above everything else
        
        // SKShapeNode allows users to draw lines on screen, which may form shapes
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 3  // FG slice has higher zPosition than BG slice
        
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9
        
        activeSliceFG.strokeColor = UIColor.white
        activeSliceFG.lineWidth = 5  // FG slice has thinner line than BG slice
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }
    
    // MARK: - Track all player moves on the screen, recording an array of all their swipe points
   
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameEnded {
            return
        }
        
        // This method needs to figure out where in the scene the user touched, add that location to the slice points array, then redraw the slice shape.
        // touchesMoved() is called whenever the touch on the screen changes location, so it is called when the user moves finger to create a slice.
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !isSwooshSoundActive {
            playSwooshSound()
        }
        
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint {
            if node.name == "enemy" || node.name == "fastEnemy" {
                // 1. Create a particle effect over the penguin.
                if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
                    emitter.position = node.position
                    addChild(emitter)
                }
                
                // 6. Add one to the player's score.
                // MARK: - more points for fast enemy
                if node.name == "enemy" {
                    score += 1
                } else if node.name == "fastEnemy" {
                    score += 3
                }
                
                // 2. Clear its node name so that it can't be swiped repeatedly.
                node.name = ""
                
                // 3. Disable the isDynamic of its physics body so that it doesn't carry on falling.
                node.physicsBody?.isDynamic = false
                
                // 4. Make the penguin scale out and fade out at the same time.
                let scaleOut = SKAction.scale(by: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])  // an action group specifies that all actions inside it should execute simultaneously
                
                // 5. After making the penguin scale out and fade out, we should remove it from the scene.
                let seq = SKAction.sequence([group, .removeFromParent()])
                node.run(seq)
                
                // 7. Remove the enemy from our activeEnemies array.
                if let index = activeEnemies.firstIndex(of: node) {
                    activeEnemies.remove(at: index)
                }
                
                // 8. Play a sound so the player knows they hit the penguin.
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                
            } else if node.name == "bomb" {
                guard let bombContainer = node.parent as? SKSpriteNode else { continue }
                
                if let emitter = SKEmitterNode(fileNamed: "sliceHitBomb") {
                    emitter.position = bombContainer.position
                    addChild(emitter)
                }
                
                node.name = ""
                bombContainer.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(by: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])
                
                let seq = SKAction.sequence([group, .removeFromParent()])
                bombContainer.run(seq)
                
                if let index = activeEnemies.firstIndex(of: bombContainer) {
                    activeEnemies.remove(at: index)
                }
                
                run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                endGame(triggeredByBomb: true)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // This method needs to fade out the slice shapes over a quarter of a second.
        // touchesEnded() is called when the user lifts the finger.
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // This method needs to:
        // 1. Remove all existing points in the activeSlicePoints array.
        guard let touch = touches.first else { return }
        activeSlicePoints.removeAll(keepingCapacity: true)
        
        // 2. Get the touch location and add it to the activeSlicePoints array.
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        
        // 3. Call the redrawActiveSlice() method to clear the slice shapes.
        redrawActiveSlice()
        
        // 4. Remove any actions that are currently attached to the slice shapes (this would be important if they are in the middle of a fadeOut(withDuration:) action.
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        
        // 5. Set both slice shapes to have an alpha value of 1 so they are fully visible. This is needed because we have previously faded out the SKShapeNodes.
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
    }
    
    func redrawActiveSlice() {
        // This method needs to:
        // 1. If we have fewer than two points in our array, we don't have enough data to draw a line so it needs to clear and shapes and exit the method.
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        
        // 2. If we have more than 12 slice points in our array, we need to remove the oldest ones until we have at most 12 - this stops the swipe shapes from becoming too long.
        if activeSlicePoints.count > 12 {
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
        }
        
        // 3. It needs to start its line at the position of the first swipe point, then go through each of the others drawing lines to each point.
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        
        for i in 1 ..< activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        // 4. It needs to update the slice shape paths so they get drawn using their designs - ie line width and color.
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
    }
    
    func playSwooshSound() {
        isSwooshSoundActive = true
        
        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"
        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        run(swooshSound) { [weak self] in
            self?.isSwooshSoundActive = false
        }
    }
    
    // MARK: - Create enemy method
    
    // The method provides a default paramter value.
    func createEnemy(forceBomb: ForceBomb = .random) {
        // This method needs to:
        // 1. Accept a parameter of whether we want to force a bomb, not force a bomb, or just be random.
        // 2. Decide whether to create a bomb or a penguin (based on the parameter input) then create the correct thing.
        // 3. Add the new enemy to the scene, and also to our activeEnemies array.
           
        let enemy: SKSpriteNode
           
        var enemyType = Int.random(in: 0...6)
           
        if forceBomb == .never {
            enemyType = Int.random(in: 3...6)
        } else if forceBomb == .always {
            enemyType = 0
        }
        
        if enemyType == 0 {
            // MARK: - Bomb code
            // 1. Create a new SKSpriteNode that will hold the fuse and the bomb image as children, setting its Z position to be 1.
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            // 2. Create the bomb image, name it "bomb", and add it to the container.
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            // 3. If the bomb fuse sound effect is playing, stop it and destroy it.
            if bombSoundEffect != nil {
                bombSoundEffect?.stop()
                bombSoundEffect = nil
            }
            
            // 4. Create a new bomb fuse sound effect, then play it.
            if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
                if let sound = try? AVAudioPlayer(contentsOf: path) {
                    bombSoundEffect = sound
                    sound.play()
                }
            }
            
            // 5. Create a particle emitter node, position it so that it's at the end of the bomb image's fuse, and add it to the container.
            if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                emitter.position = CGPoint(x: 76, y: 64)
                enemy.addChild(emitter)
            }
        } else if (enemyType == 1) || (enemyType == 2) {
            // MARK: - create fast moving enemy
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "fastEnemy"
        } else {
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemy"
        }
        
        // MARK: - Position code
        // 1. Give the enemy a random position off the bottom edge of the screen.
        let randomPosition = CGPoint(x: Int.random(in: 64...960), y: -128)
        enemy.position = randomPosition
        
        // 2. Create a random angular velocity, which is how fast something should spin.
        let randomAngularVelocity = CGFloat.random(in: -3...3)
        let randomXVelocity: Int
        
        // 3. Create a random X velocity (how far to move horizontally) that takes into account the enemy's position
        if enemy.name == "fastEnemy" {
            // MARK: - x velocity for fast moving enemy
            if randomPosition.x < CGFloat(quarterX) {
                randomXVelocity = 17
            } else if randomPosition.x < CGFloat(halfX) {
                randomXVelocity = 7
            } else if randomPosition.x < CGFloat(threeQuartersX) {
                randomXVelocity = -7
            } else {
                randomXVelocity = -17
            }
        } else {
            if randomPosition.x < CGFloat(quarterX) {
                randomXVelocity = Int.random(in: 8...15)
            } else if randomPosition.x < CGFloat(halfX) {
                randomXVelocity = Int.random(in: 3...5)
            } else if randomPosition.x < CGFloat(threeQuartersX) {
                randomXVelocity = -Int.random(in: 3...5)
            } else {
                randomXVelocity = -Int.random(in: 8...15)
            }
        }
        
        // 4. Create a random Y velocity just to make things fly at different speeds.
        // MARK: - y velocity for fast moving enemy
        let randomYVelocity: Int
        if enemy.name == "fastEnemy" {
            randomYVelocity = 34
        } else {
            randomYVelocity = Int.random(in: 24...32)
        }
        
        // 5. Give all enemies a circular physics body where the collisionBitMask is set to 0 so they don't collide.
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * 40, dy: randomYVelocity * 40)
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask = 0
        
        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    // MARK: - Method to actually show the enemies
    
    func tossEnemies() {
        if isGameEnded {
            return
        }
        
        popupTime *= 0.991
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02
        
        let sequenceType = sequence[sequencePosition]
        
        switch sequenceType {
        case .oneNoBomb:
            createEnemy(forceBomb: .never)
        case .one:
            createEnemy()
        case .twoWithOneBomb:
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)
        case .two:
            createEnemy()
            createEnemy()
        case .three:
            createEnemy()
            createEnemy()
            createEnemy()
        case .four:
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()
        case .chain:
            createEnemy()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0)) {
                [weak self] in self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 2)) {
                [weak self] in self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 3)) {
                [weak self] in self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 4)) {
                [weak self] in self?.createEnemy()
            }
        case .fastChain:
            createEnemy()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0)) {
                [weak self] in self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 2)) {
                [weak self] in self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 3)) {
                [weak self] in self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 4)) {
                [weak self] in self?.createEnemy()
            }
        }
        
        sequencePosition += 1
        nextSequenceQueued = false  // If it's false, it means we don't have a call to tossEnemies() in the pipeline waiting to execute. It gets set to true only in the gap between the previous sequence item finishing (ie previous enemy/enemies destroyed) and tossEnemies() being called, because there is a time delay (the popupTime property) before tossing another enemy, and we want to wait for tossEnemy() to finish and have nextSequenceQueued set to false rather than having tossEnemy() being called non-stop during the popupTime delay (see more detail in update() method).
    }
    
    override func update(_ currentTime: TimeInterval) {
        // This method is called every frame before it's drawn, so we can check the number of bomb containers that exist in our game, and stop the fuse sound if the number is 0.
        var bombCount = 0
        
        for node in activeEnemies {
            if node.name == "bombContainer" {
                bombCount += 1
                break
            }
        }
        
        if bombCount == 0 {
            // no bombs - stop the fuse sound
            bombSoundEffect?.stop()
            bombSoundEffect = nil
        }
        
        // Time to remove enemies.
        // 1. If we have active enemies, we loop through each of them.
        // 2. If any enemy is at or lower than Y position -140, we remove it from the game and our activeEnemies array.
        // 3. If we don't have any active enemies and we haven't already queued the next enemy sequence, we schedule the next enemy sequence and set nextSequenceQueued to be true.
        if activeEnemies.count > 0 {
            for (index, node) in activeEnemies.enumerated().reversed() {
                if node.position.y < -140 {
                    node.removeAllActions()
                    
                    if node.name == "enemy" || node.name == "fastEnemy" {
                        node.name = ""
                        subtractLife()
                        
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    } else if node.name == "bombContainer" {
                        node.name = ""
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    }
                }
            }
        } else {
            if !nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) {
                    [weak self] in self?.tossEnemies()
                }
                
                nextSequenceQueued = true
            }
        }
    }
    
    func subtractLife() {
        lives -= 1
        
        run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
        
        var life: SKSpriteNode
        
        if lives == 2 {
            life = livesImages[0]
        } else if lives == 1 {
            life = livesImages[1]
        } else {
            life = livesImages[2]
            endGame(triggeredByBomb: false)
        }
        
        life.texture = SKTexture(imageNamed: "sliceLifeGone")  // we use SKTexture to modify the contents of a sprite node without having to recreate it
        
        life.xScale = 1.3
        life.yScale = 1.3
        life.run(SKAction.scale(to: 1, duration: 0.1))
    }
    
    func endGame(triggeredByBomb: Bool) {
        if isGameEnded {
            return
        }
        
        isGameEnded = true
        physicsWorld.speed = 0
        isUserInteractionEnabled = false
        
        bombSoundEffect?.stop()
        bombSoundEffect = nil
        
        if triggeredByBomb {
            livesImages[0].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[1].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[2].texture = SKTexture(imageNamed: "sliceLifeGone")
        }
        
        // MARK: - end game edit
        let endGame = SKSpriteNode(imageNamed: "gameOver")
        endGame.position = CGPoint(x: 512, y: 384)
        endGame.zPosition = 3
        addChild(endGame)
        viewController.restartButton.isHidden = false
    }
    
    
    
}
// too much y velocity, too much x velocity
// restart button not wide enough
