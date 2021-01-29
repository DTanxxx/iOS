//
//  Photo.swift
//  Challenge 5
//
//  Created by David Tan on 9/11/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

class Photo: NSObject, NSCoding {
    
    var filename: String
    var caption: String
    
    init(filename:String, caption:String) {
        self.filename = filename
        self.caption = caption
    }
    
    required init(coder aDecoder: NSCoder) {
        filename = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        caption = aDecoder.decodeObject(forKey: "cap") as? String ?? ""
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(filename, forKey: "name")
        aCoder.encode(caption, forKey: "cap")
    }
    
}
