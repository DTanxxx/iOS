//
//  Person.swift
//  Name and Faces
//
//  Created by David Tan on 1/11/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

// NSObject is what's called a universal base class for all Cocoa Touch classes. That means all UIKit classes ultimately come from NSObject, including all of UIKit. You don't have to inherit from NSObject in Swift, but you did in Objective-C and in fact there are some behaviors you can only have if you do inherit from it. More on that in project 12, but for now just make sure you inherit from NSObject.

class Person: NSObject, NSCoding {
    // class instead of struct: working with NSCoding requires you to use objects, or, in the case of strings, arrays and dictionaries, structs that are interchangeable with objects. If we made the Person class into a struct, we couldn't use it with NSCoding.
    // inherit from NSObject: it is required to use NSCoding.
    
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
    
    // NSCoder is responsible for both encoding and decoding data.
    required init(coder aDecoder: NSCoder) {
        // The 'required' keyword means "if anyone tries to subclass this class, they are required to implement this method."
        name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        image = aDecoder.decodeObject(forKey: "image") as? String ?? ""
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(image, forKey: "image")
    }
    
}
