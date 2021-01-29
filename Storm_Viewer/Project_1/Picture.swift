//
//  PictureCell.swift
//  Project_1
//
//  Created by David Tan on 7/11/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

class Picture: NSObject, Codable, Comparable {

    var name: String
    var viewCount: String
    var intView: Int {
        didSet {
            self.viewCount = "Views: \(intView)"
        }
    }
    
    init(name: String, viewInt: Int) {
        self.name = name
        self.intView = viewInt
        self.viewCount = "Views: \(intView)"
    }
    
    static func < (lhs: Picture, rhs: Picture) -> Bool {
        return true
    }
}
