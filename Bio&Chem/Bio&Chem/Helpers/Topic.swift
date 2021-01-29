//
//  Topic.swift
//  Bio&Chem
//
//  Created by David Tan on 27/03/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import Foundation

struct Topic: Codable {
    var topic: String?
    var chapters: [String: Int]?
}
