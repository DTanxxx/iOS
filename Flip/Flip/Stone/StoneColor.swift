//
//  StoneColor.swift
//  Flip
//
//  Created by David Tan on 28/06/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import Foundation

// MARK: - IMPORTANT: you need to have the ': Int' after declaring an enum!!!

enum StoneColor: Int {
    case black, white, empty, choice
    // black and white used to mark player control
    // empty means no player owns it yet
    // choice marks where the AI intends to go
}
