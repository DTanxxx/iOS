//
//  WhackSlot.swift
//  Whacking penguins
//
//  Created by David Tan on 17/11/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import SpriteKit
import UIKit

class WhackSlot: SKNode {
    
    var charNode: SKSpriteNode!
    var isVisible = false
    var isHit = false
    
    func configure(at position: CGPoint) {
        self.position = position
        
        let sprite = SKSpriteNode(imageNamed: "whackHole")
        addChild(sprite)
        
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 15)  // create a new SKCropNode and position it slightly higher than the slot itself
        cropNode.zPosition = 1
        cropNode.name = "crop"
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")  // 'every child node of the crop node in the region covered by whackMask image dimensions will be visible; outside of them then invisible'
        
        charNode = SKSpriteNode(imageNamed: "penguinGood")
        charNode.position = CGPoint(x: 0, y: -90)
        charNode.name = "character"
        cropNode.addChild(charNode)
        addChild(cropNode)
    }
    
    func show(hideTime: Double, pos: CGPoint) {
        if isVisible { return }
        charNode.xScale = 1
        charNode.yScale = 1
        
        isVisible = true
        isHit = false
        
        if Int.random(in: 0...2) == 0 {
            charNode.texture = SKTexture(imageNamed: "penguinGood")
            charNode.name = "charFriend"
        } else {
            charNode.texture = SKTexture(imageNamed: "penguinEvil")
            charNode.name = "charEnemy"
        }
        
        guard let mudEffect = SKEmitterNode(fileNamed: "MudParticles") else { return }
        mudEffect.position = CGPoint(x: pos.x, y: pos.y - 40)
        mudEffect.zPosition = 1
        
        let showMud = SKAction.run {
            [unowned self] in
            self.addChild(mudEffect)
        }
        let showUp = SKAction.moveBy(x: 0, y: 80, duration: 0.1)
        let noMud = SKAction.run {
            mudEffect.removeFromParent()
        }
        charNode.run(SKAction.sequence([showMud, showUp, noMud]))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (hideTime * 3.5)) {
            [unowned self] in
            self.hide(pos: (self.charNode.parent?.position)!)
        }
    }
    
    func hide(pos: CGPoint) {
        if !isVisible { return }
        
        // create mud effect when goes into hole
        guard let mudEffect = SKEmitterNode(fileNamed: "MudParticles") else { return }
        mudEffect.position = CGPoint(x: pos.x, y: pos.y - 40)
        mudEffect.zPosition = 1
        addChild(mudEffect)
        
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.1)
        let notVisible = SKAction.run {
            [unowned self] in
            self.isVisible = false
            mudEffect.removeFromParent()
        }
        charNode.run(SKAction.sequence([hide, notVisible]))
    }
    
    func hit(pos: CGPoint, pos2: CGPoint) {
        isHit = true
        
        // create the effect at a position (needs CGPoint)
        guard let smokeEffect = SKEmitterNode(fileNamed: "SmokeParticles") else { return }
        smokeEffect.position = pos
        smokeEffect.zPosition = 1
        addChild(smokeEffect)
        guard let mudEffect = SKEmitterNode(fileNamed: "MudParticles") else { return }
        mudEffect.position = CGPoint(x: pos2.x, y: pos2.y - 40)
        mudEffect.zPosition = 1
 
        let delay = SKAction.wait(forDuration: 0.25)
        let makeMud = SKAction.run {
            [unowned self] in
            self.addChild(mudEffect)
        }
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
        let notVisible = SKAction.run {
            [unowned self] in
            self.isVisible = false
            // get rid of the smoke effect
            smokeEffect.removeFromParent()
            mudEffect.removeFromParent()
        }
        charNode.run(SKAction.sequence([delay, makeMud, hide, notVisible]))
    }
    
}


