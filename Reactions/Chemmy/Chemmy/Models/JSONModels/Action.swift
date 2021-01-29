//
//  Action.swift
//  Chemmy
//
//  Created by David Tan on 23/09/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import Foundation

struct Action: Decodable {
    var name: String?
    var cost: Int?
    var reactions: [Reaction]?
}
