//
//  Player.swift
//  Flip
//
//  Created by David Tan on 28/06/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import GameplayKit

// the Player class stores the stone color for each player, an array of both players, and also a computed property to read the player’s opponent
class Player: NSObject, GKGameModelPlayer {
    // create two players, black and white, and store them in a static array
    static let allPlayers = [Player(stone: .black), Player(stone: .white)]
    
    // a property to store this player's color
    var stoneColor: StoneColor
    
    // a property that distinguishes players uniquely -> required by GameplayKit AI
    var playerId: Int
    
    init(stone: StoneColor) {
        stoneColor = stone
        playerId = stone.rawValue
    }
    
    // computed property to return the player's opponent
    var opponent: Player {
        if stoneColor == .black {
            return Player.allPlayers[1]
        } else {
            return Player.allPlayers[0]
        }
    }
}
