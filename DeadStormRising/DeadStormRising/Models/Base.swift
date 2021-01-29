//
//  Base.swift
//  DeadStormRising
//
//  Created by David Tan on 6/07/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import SpriteKit

// this is a class representing a base in game that can be captured to build things
// it inherits from GameItem class as it is a game item
class Base: GameItem {
    var hasBuilt = false
    
    // this method will reset this game item when a turn ends, so that this base can build another unit next turn
    func reset() {
        hasBuilt = false
    }
    
    // this method will be called by the 'capture' action
    func setOwner(_ owner: Player) {
        // change the 'owner' property
        self.owner = owner
        
        // set hasBuilt to true so that bases can't build a tank the same turn they are captured
        hasBuilt = true
        
        // apply a color blend to the base image so it's visibly owned by one player
        self.colorBlendFactor = 0.9
        
        if owner == .red {
            color = UIColor(red: 1, green: 0.4, blue: 0.1, alpha: 1)
        } else {
            color = UIColor(red: 0.1, green: 0.5, blue: 1, alpha: 1)
        }
    }
    
    // this method will be called by the 'build' action
    func buildUnit() -> Unit? {
        // ensure bases build only one thing per turn
        guard hasBuilt == false else { return nil }
        hasBuilt = true
        
        // create the new unit
        let unit: Unit
        
        if owner == .red {
            unit = Unit(imageNamed: "tankRed")
        } else {
            unit = Unit(imageNamed: "tankBlue")
        }
        
        // mark the new unit as having moved and fired already, so players need to wait for next turn to use them
        unit.hasMoved = true
        unit.hasFired = true
        
        // assign the new unit the same owner and position as this base
        unit.owner = owner
        unit.position = position
        
        // give the unit the correct Z position
        unit.zPosition = zPositions.unit
        
        // send it back to the caller
        return unit
    }
}
