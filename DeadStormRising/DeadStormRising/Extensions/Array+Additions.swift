//
//  Array+Additions.swift
//  DeadStormRising
//
//  Created by David Tan on 7/07/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

extension Array where Element: GameItem {
    // we need to determine whether each move square is a move or an attack, and to do that we need to know which units are at a given position/square
    // given an array of GameItem objects, we can provide a CGPoint and use filter() method to create a new array containing only the GameItem object whose position is within range of the CGPoint provided
    // to do that we can add together the absolute differences for x and y values between each unit and the given point -> and we return true if that sum is less than 10 (ie the unit is at the point)
    // note that we provided a range (10 in this case) to allow for subtle differences between the positions, since positions are stored as CGPoint and the x and y values are stored as CGFloat -> floats contain many decimal points which can (and will) vary, for example at the 10th decimal point
    // hence a comparison with '==' would not work
    func itemsAt(position: CGPoint) -> [Element] {
        return filter {
            let diffX = abs($0.position.x - position.x)
            let diffY = abs($0.position.y - position.y)
            return diffX + diffY < 10
        }
    }
    
    // note that here we are creating an extension to the Array class that is only accessible when the Array object contains GameItem elements (or elements that are subclasses of GameItem)
}
