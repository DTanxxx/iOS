//
//  Alarm.swift
//  Alarmadillo
//
//  Created by David Tan on 28/05/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

class Alarm: NSObject, NSCoding {
    var id: String  // unique identifier for this alarm
    var name: String  // alarm's name
    var caption: String  // alarm's description
    var time: Date  // the time the alarm should be triggered
    var image: String  // name of the image that is attached to this alarm
    var hasChanged: Bool
    
    init(name: String, caption: String, time: Date, image: String, changed: Bool) {
        self.id = UUID().uuidString
        self.name = name
        self.caption = caption
        self.time = time
        self.image = image
        self.hasChanged = changed
    }
    
    // load data from a saved state
    required init?(coder: NSCoder) {
        self.id = coder.decodeObject(forKey: "id") as! String
        self.name = coder.decodeObject(forKey: "name") as! String
        self.caption = coder.decodeObject(forKey: "caption") as! String
        self.time = coder.decodeObject(forKey: "time") as! Date
        self.image = coder.decodeObject(forKey: "image") as! String
        self.hasChanged = coder.decodeBool(forKey: "changed") 
    }
    
    // create a saved state from an existing object
    func encode(with coder: NSCoder) {
        coder.encode(self.id, forKey: "id")
        coder.encode(self.name, forKey: "name")
        coder.encode(self.caption, forKey: "caption")
        coder.encode(self.time, forKey: "time")
        coder.encode(self.image, forKey: "image")
        coder.encode(self.hasChanged, forKey: "changed")
    }
}
