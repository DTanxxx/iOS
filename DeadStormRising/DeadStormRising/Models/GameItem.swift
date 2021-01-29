//
//  GameItem.swift
//  DeadStormRising
//
//  Created by David Tan on 6/07/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import SpriteKit

// this is the base class that contains common bahaviours for all game items
class GameItem: SKSpriteNode {
    // all game items should have an owner
    var owner = Player.none
}
