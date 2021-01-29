//
//  ViewController.swift
//  UserDefault test
//
//  Created by David Tan on 7/11/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        defaults.set(25, forKey: "Age")
        defaults.set(true, forKey: "UseTouchID")
        defaults.set(CGFloat.pi, forKey: "Pi")
        
        defaults.set("Paul Hudson", forKey: "Name")
        defaults.set(Date(), forKey: "LastRun")
        // In Swift, strings, arrays and dictionaries are all structs, not objects. But UserDefaults was written for NSString and friends – all of which are 100% interchangeable with Swift their equivalents – which is why this code works.
        let array = ["Hello", "World"]
        defaults.set(array, forKey: "SavedArray")
        let dict = ["Name":"Paul", "Country":"UK"]
        defaults.set(dict, forKey: "SavedDict")
        
        // Now read the stuff
        let readArray = defaults.object(forKey: "SavedArray") as? [String] ?? [String]()
        // ?? is the  nil coalescing operator. This does two things at once: if the object on the left is optional and exists, it gets unwrapped into a non-optional value; if it does not exist, it uses the value on the right instead.
        let readDict = defaults.object(forKey: "SavedDict") as? [String:String] ?? [String:String]()
    }
    
    
    
    


}

