//
//  Person.swift
//  Name and Faces
//
//  Created by David Tan on 1/11/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

// NSObject is what's called a universal base class for all Cocoa Touch classes. That means all UIKit classes ultimately come from NSObject, including all of UIKit. You don't have to inherit from NSObject in Swift, but you did in Objective-C and in fact there are some behaviors you can only have if you do inherit from it. More on that in project 12, but for now just make sure you inherit from NSObject.

class Person: NSObject, Codable {
    
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
    
}
