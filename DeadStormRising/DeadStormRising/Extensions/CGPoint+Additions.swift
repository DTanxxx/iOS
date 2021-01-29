//
//  CGPoint+Additions.swift
//  DeadStormRising
//
//  Created by David Tan on 6/07/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

extension CGPoint {
    // we calculate the distance between two points using the Manhattan Distance
    // Manhattan Distance is the distance to travel between two points if we can only move vertically or horizontally -- no diagonals allowed
    // therefore we can just take the absolute difference in x and absolute difference in y, and add them together
    func manhattanDistance(to: CGPoint) -> CGFloat {
        return (abs(x - to.x) + abs(y - to.y))
    }
}
