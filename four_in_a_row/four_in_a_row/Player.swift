//
//  Player.swift
//  four_in_a_row
//
//  Created by David Tan on 22/02/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import GameplayKit

class Player: NSObject, GKGameModelPlayer {
    
    var chip: ChipColor
    var color: UIColor  // the drawing color of the player; this is needed because we need an UIColor representation of the color - ChipColor type has limitations
    var name: String  // the name will be either 'Red' or 'Black'
    var playerId: Int  // required by GKGameModelPlayer protocol: this will hold the raw value of the player's chip type - thus it identifies every player uniquely
    var opponent: Player {
        if chip == .red {
            return Player.allPlayers[1]
        } else {
            return Player.allPlayers[0]
        }
    }
    
    static var allPlayers = [Player(chip: .red), Player(chip: .black)]
    
    init(chip: ChipColor) {
        self.chip = chip
        self.playerId = chip.rawValue
        
        if chip == .red {
            color = .red
            name = "Red"
        } else {
            color = .black
            name = "Black"
        }
        
        super.init()  // MARK: - this must be invoked in order to initialise the subclass properly
    }
    
}
