//
//  Reaction.swift
//  Chemmy
//
//  Created by David Tan on 23/09/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import Foundation

struct Reaction: Decodable {
    var name: String?
    var energy: Int?
    var reactants: [Reactant]?
    var catalysts: [String]?
}
