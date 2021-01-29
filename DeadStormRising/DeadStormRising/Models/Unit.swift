//
//  Unit.swift
//  DeadStormRising
//
//  Created by David Tan on 6/07/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import SpriteKit

// this is a class representing a movable tank unit in game
// it inherits from GameItem class as it is a game item
class Unit: GameItem {
    var isAlive = true  // if a unit is dead, it should not be selectable
    var hasMoved = false  // used to ensure that each unit moves only once per turn
    var hasFired = false  // used to ensure that each unit fires only once per turn
    
    // give each unit 3 health points by default
    var health = 3 {
        didSet {
            // when a unit becomes damaged, we will make it flash
            // the more damaged a unit is, the faster it flashes
            // we will make a unit flash at a rate of 0.25 * health (so lower health means faster flashing)
            // if a unit reaches a health of 0, we will remove the flashing and make it dead
            
            // remove any existing flashing for this unit
            removeAllActions()
            
            // if we still have health...
            if health > 0 {
                // make fade out and fade in actions
                let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.25 * Double(health))
                let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.25 * Double(health))
                
                // put them together and make them repeat forever
                let sequence = SKAction.sequence([fadeOut, fadeIn])
                let repeatForever = SKAction.repeatForever(sequence)
                run(repeatForever)
            } else {
                // if the tank is destroyed, change its texture to a burnt out tank
                texture = SKTexture(imageNamed: "tankDead")
                
                // force it to have 100% alpha
                alpha = 1
                
                // mark it as dead so it can't be moved any more
                isAlive = false
            }
        }
    }
    
    // this method will reset this game item when a turn ends
    func reset() {
        if isAlive == true {
            // if the unit is alive, reset its hasFired and hasMoved properties to false so they can move and fire the following turn
            hasFired = false
            hasMoved = false
        } else {
            // if the unit is dead, make it fade away then be destroyed so the map doesn't end up cluttered with dozens of ex-tanks
            let fadeAway = SKAction.fadeOut(withDuration: 0.5)
            let sequence = [fadeAway, SKAction.removeFromParent()]
            run(SKAction.sequence(sequence))
        }
    }
    
    // MARK: - Movement
    
    func move(to target: SKNode) {
        // if the unit has moved already, return immediately; otherwise, set hasMoved to true
        guard hasMoved == false else { return }
        hasMoved = true
        
        // since we will generate an SKAction for movement in each of X and Y axes, we will store them in an array that can be executed as an SKAction sequence
        var sequence = [SKAction]()
        
        // if the unit's current X position is different to its target X position, we will create an SKAction to make it follow a path from current to target X
        if position.x != target.position.x {
            // we will move the unit along a path using UIBezierPath
            let path = UIBezierPath()
            
            // move UIBezierPath to our starting point
            // IMPORTANT: the move(to:) method takes in a starting position RELATIVE to the node it was called from, because in our SKAction.follow() we pass in 'true' to 'asOffset' parameter, therefore if we want our unit to travel from current position to a target position, we pass in CGPoint.zero, indicating a starting location centered at our node/unit (SpriteKit's coordinate system has origin at the center of a node)
            path.move(to: CGPoint.zero)
            
            // add a line to our finishing point, again the CGPoint passed in is relative to the node from which the method is called, because of 'asOffset' parameter being passed in 'true'
            path.addLine(to: CGPoint(x: target.position.x - position.x, y: 0))
            
            sequence.append(SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200))
        }
        
        // if the unit's Y position needs to change, we will do the same thing for the Y axis
        if position.y != target.position.y {
            let path = UIBezierPath()
            path.move(to: CGPoint.zero)
            path.addLine(to: CGPoint(x: 0, y: target.position.y - position.y))
            sequence.append(SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200))
        }
        
        // run the complete sequence of moves
        run(SKAction.sequence(sequence))
    }
    
    // MARK: - Attack
    
    func attack(target: Unit) {
        // make sure this unit hasn't fired already
        guard hasFired == false else { return }
        hasFired = true
        
        // turn the tank to face its target using the rotate() method we wrote
        rotate(toFace: target)
        
        // create a new bullet sprite and give it the same color as this tank
        let bullet: SKSpriteNode
        
        if owner == .red {
            bullet = SKSpriteNode(imageNamed: "bulletRed")
        } else {
            bullet = SKSpriteNode(imageNamed: "bulletBlue")
        }
        
        // place the bullet underneath the tank so it looks like it's fired from the barrel
        bullet.zPosition = zPositions.bullet
        
        // add the bullet to the unit's parent node - i.e. the game scene, because we want to use the actual scene positions for our UIBezierPath
        parent?.addChild(bullet)
        
        // draw a path from the unit's position to the target
        let path = UIBezierPath()
        path.move(to: position)
        path.addLine(to: target.position)
        
        // create an action for that movement
        // note that here we are passing 'false' to the 'asOffset' parameter, because we are using exact positions
        let move = SKAction.follow(path.cgPath, asOffset: false, orientToPath: true, speed: 500)
        
        // create an action that makes the target take damage
        let damageTarget = SKAction.run { [unowned target] in
            target.takeDamage()
        }
        
        // create an action for the smoke and fire particle emitters
        let createExplosion = SKAction.run { [unowned self] in
            // create the smoke emitter
            if let smoke = SKEmitterNode(fileNamed: "Smoke") {
                smoke.position = target.position
                smoke.zPosition = zPositions.smoke
                self.parent?.addChild(smoke)
            }
            
            // create the fire emitter over the smoke emitter
            if let fire = SKEmitterNode(fileNamed: "Fire") {
                fire.position = target.position
                fire.zPosition = zPositions.fire
                self.parent?.addChild(fire)
            }
        }
        
        // create a combined sequence: bullet moves, target takes damage, explosion is created, then the bullet is removed from the game
        // note that here we added an SKAction.removeFromParent() static method to the array of SKActions -> this method will be called on whatever runs this sequence of SKActions, therefore here it will destroy the bullet
        let sequence = [move, damageTarget, createExplosion, SKAction.removeFromParent()]
        
        // run that sequence on the bullet
        bullet.run(SKAction.sequence(sequence))
    }
    
    func takeDamage() {
        health -= 1
    }
    
    // this method is responsible for turning the tank to face its target when attacking
    func rotate(toFace node: SKNode) {
        // pass in delta Y and delta X to the atan2() method to get the new angle in radians, starting from horizontal axis in anticlockwise direction
        let angle = atan2(node.position.y - position.y, node.position.x - position.x)
        
        // since our sprite is already vertical (ie "rotated" by pi/2 radians), we subtract pi/2 from our new angle, to find the amount to rotate by (positive angle = anticlockwise rotation, negative angle = clockwise rotation)
        zRotation = angle - (CGFloat.pi / 2)
    }
}
