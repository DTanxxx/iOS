//
//  Player.swift
//  Chemmy
//
//  Created by David Tan on 25/07/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import SpriteKit

class Player: SKNode {
    
    public var ragDollState: Bool = true

    private var _player: SKSpriteNode!
    
    public func setPlayerPhysics() {
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: _player.texture!.size().width-PlayerInfo.collisionBoxSizeOffsetWidth, height: _player.texture!.size().height-PlayerInfo.collisionBoxSizeOffsetHeight))
        self.physicsBody?.isDynamic = true
        
        self.physicsBody?.collisionBitMask = CollisionType.tile.rawValue | CollisionType.stand.rawValue 
        self.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        self.physicsBody?.contactTestBitMask = CollisionType.tile.rawValue | CollisionType.cannon.rawValue
        // MARK: - remove later
        let box = SKSpriteNode(texture: nil, color: .red, size: CGSize(width: _player.texture!.size().width-PlayerInfo.collisionBoxSizeOffsetWidth, height: _player.texture!.size().height-PlayerInfo.collisionBoxSizeOffsetHeight))
        addChild(box)
    }
    
    public func createPlayerSprite(texture: SKTexture?) {
        _player = SKSpriteNode(texture: texture!)
        _player.name = "player"
        _player.position = PlayerInfo.playerPos
        
        self.addChild(_player)
    }
}
