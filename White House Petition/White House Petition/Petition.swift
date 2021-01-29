//
//  Petition.swift
//  White House Petition
//
//  Created by David Tan on 13/10/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import Foundation

struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}
// The advantage of struct here is that it gives us a 'memberwise initializer' – a special function that can create new Petition instances by passing in values for title, body, and signatureCount. This is not achievable with class.
