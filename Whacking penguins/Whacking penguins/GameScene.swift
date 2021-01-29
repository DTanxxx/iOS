//
//  GameScene.swift
//  Whacking penguins
//
//  Created by David Tan on 17/11/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    
    var audioPlayer = AVAudioPlayer()
    var numRounds = 0
    var popupTime = 0.85
    var slots = [WhackSlot]()
    var gameScore: SKLabelNode!
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)  // coordinates show the position of the CENTRE of the node
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)  // coordinates show the position of the BOTTOM LEFT CORNER of the node
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 410)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 320)) }
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 230)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 140)) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            [weak self] in
            self?.createEnemy()
        }
        
        // get the gameover music ready
        let sound = Bundle.main.path(forResource: "crabs", ofType: "mp3")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
        }
        catch {
            print("Error")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            guard let whackSlot = node.parent?.parent as? WhackSlot else { continue }  // This line gets the parent of the parent of the node, and typecasts it as a WhackSlot. It is needed because the player has tapped the penguin sprite node, not the slot – we need to get the parent of the penguin, which is the crop node it sits inside, then get the parent of the crop node, which is the WhackSlot object.
            if !whackSlot.isVisible { continue }
            if whackSlot.isHit { continue }
            whackSlot.hit(pos: node.position, pos2: (whackSlot.childNode(withName: "crop")?.position)!)
            
            if node.name == "charFriend" {
                // they shouldn't have whacked this penguin
                score -= 5
                if score < 0 { score = 0 }
                
                run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
            } else if node.name == "charEnemy" {
                // they should have whacked this one
                whackSlot.charNode.xScale = 0.85
                whackSlot.charNode.yScale = 0.85
                score += 1
                
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            }
        }
    }
    
    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
    
    func createEnemy() {
        numRounds += 1
        
        if numRounds > 30 {
            for slot in slots {
                slot.hide(pos: slot.childNode(withName: "crop")!.position)
            }
            
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 512, y: 384)
            gameOver.zPosition = 1
            
            let ggLabel = SKLabelNode(fontNamed: "Marker Felt")
            ggLabel.text = "Your final score: \(score)"
            ggLabel.position = CGPoint(x: 380, y: 480)
            ggLabel.fontSize = 28
            ggLabel.horizontalAlignmentMode = .left
            
            addChild(ggLabel)
            addChild(gameOver)
            
            // play the dope music
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                [unowned self] in
                self.audioPlayer.play()
            }
            return
        }
        popupTime *= 0.991
        
        slots.shuffle()
        
        slots[0].show(hideTime: popupTime, pos: slots[0].childNode(withName: "crop")!.position)
        
        if Int.random(in: 0...12) > 4 { slots[1].show(hideTime: popupTime, pos: slots[1].childNode(withName: "crop")!.position) }
        if Int.random(in: 0...12) > 8 { slots[2].show(hideTime: popupTime, pos: slots[2].childNode(withName: "crop")!.position) }
        if Int.random(in: 0...12) > 10 { slots[3].show(hideTime: popupTime, pos: slots[3].childNode(withName: "crop")!.position) }
        if Int.random(in: 0...12) > 11 { slots[4].show(hideTime: popupTime, pos: slots[4].childNode(withName: "crop")!.position) }
        
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2
        let delay = Double.random(in: minDelay...maxDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            [weak self] in
            self?.createEnemy()
        }
    }
    
}
