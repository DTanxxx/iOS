//
//  Tile.swift
//  Chemmy
//
//  Created by David Tan on 25/07/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import SpriteKit

class Tile: SKShapeNode {
    
    public func setTilePhysics(size: CGSize) {
        physicsBody = SKPhysicsBody.init(rectangleOf: size, center: CGPoint(x: size.width / 2.0, y: size.height / 2.0))
        physicsBody?.isDynamic = false
        
        physicsBody?.collisionBitMask = CollisionType.player.rawValue
        physicsBody?.categoryBitMask = CollisionType.tile.rawValue
        physicsBody?.contactTestBitMask = CollisionType.player.rawValue
    }
    
}
