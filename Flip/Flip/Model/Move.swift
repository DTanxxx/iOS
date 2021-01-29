//
//  Move.swift
//  Flip
//
//  Created by David Tan on 28/06/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import GameplayKit

// the Move class stores the row and column of a move
class Move: NSObject, GKGameModelUpdate {
    var row: Int
    var col: Int
    
    var value = 0  // this number gets used internally by GameplayKit to store how good it considers each move to be
    
    init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
}
