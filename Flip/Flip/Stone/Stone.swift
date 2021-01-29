//
//  Stone.swift
//  Flip
//
//  Created by David Tan on 28/06/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import SpriteKit

class Stone: SKSpriteNode {
    // create shared properties for the three possible textures stones can have, so that we can change a stone's image just by switching the texture
    static let thinkingTexture = SKTexture(imageNamed: "thinking")
    static let whiteTexture = SKTexture(imageNamed: "white")
    static let blackTexture = SKTexture(imageNamed: "black")
    
    // create a method that will set the stone's texture to match the player's color
    func setPlayer(_ player: StoneColor) {
        switch player {
        case .white:
            texture = Stone.whiteTexture
        case .black:
            texture = Stone.blackTexture
        case .choice:
            texture = Stone.thinkingTexture
        default:
            break
        }
    }
    
    // the row and column this stone belongs to
    var row = 0
    var col = 0
}
