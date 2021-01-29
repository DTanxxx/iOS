//
//  Move.swift
//  four_in_a_row
//
//  Created by David Tan on 23/02/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import GameplayKit

class Move: NSObject, GKGameModelUpdate {
    
    var value: Int = 0
    var column: Int
    
    init(column: Int) {
        self.column = column
    }
    
}
