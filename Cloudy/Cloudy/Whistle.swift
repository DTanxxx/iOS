//
//  Whistle.swift
//  Cloudy
//
//  Created by David Tan on 25/04/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import CloudKit
import UIKit

class Whistle: NSObject, NSCoding {
    var recordID: CKRecord.ID!
    var genre: String!
    var comments: String!
    var audio: URL!
    
    init(recordID: CKRecord.ID!) {
        self.recordID = recordID
    }
    
    required init?(coder: NSCoder) {
        recordID = coder.decodeObject(forKey: "recordID") as? CKRecord.ID ?? CKRecord.ID(recordName: "")
        genre = coder.decodeObject(forKey: "genre") as? String ?? ""
        comments = coder.decodeObject(forKey: "comments") as? String ?? ""
        audio = coder.decodeObject(forKey: "audio") as? URL ?? URL(string: "")
    }
       
    func encode(with coder: NSCoder) {
        coder.encode(recordID, forKey: "recordID")
        coder.encode(genre, forKey: "genre")
        coder.encode(comments, forKey: "comments")
        coder.encode(audio, forKey: "audio")
    }
}
