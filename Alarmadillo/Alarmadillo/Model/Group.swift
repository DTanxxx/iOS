//
//  Group.swift
//  Alarmadillo
//
//  Created by David Tan on 28/05/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

class Group: NSObject, NSCoding {
    var id: String  // unique identifier for this group
    var name: String  // group's name
    var playSound: Bool  // whether alarms in this group should trigger a sound
    var enabled: Bool  // whether this group of alarms is enabled
    var alarms: [Alarm]  // array of Alarm objects that belong to this group
    
    init(name: String, playSound: Bool, enabled: Bool, alarms: [Alarm]) {
        self.id = UUID().uuidString
        self.name = name
        self.playSound = playSound
        self.enabled = enabled
        self.alarms = alarms
    }
    
    // load data from a saved state
    required init?(coder: NSCoder) {
        self.id = coder.decodeObject(forKey: "id") as! String
        self.name = coder.decodeObject(forKey: "name") as! String
        self.playSound = coder.decodeBool(forKey: "playSound")
        self.enabled = coder.decodeBool(forKey: "enabled")
        self.alarms = coder.decodeObject(forKey: "alarms") as! [Alarm]
    }
    
    // create a saved state from an existing object
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(name, forKey: "name")
        coder.encode(playSound, forKey: "playSound")
        coder.encode(enabled, forKey: "enabled")
        coder.encode(alarms, forKey: "alarms")
    }
}
