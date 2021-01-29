//
//  SwiftProject.swift
//  Spotlight
//
//  Created by David Tan on 1/02/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

class SwiftProject: NSObject, Codable {
    
    var title: String
    var body: String
    
    init(title: String, body: String) {
        self.title = title
        self.body = body
    }
    
}
