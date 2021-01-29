//
//  Helper.swift
//  Alarmadillo
//
//  Created by David Tan on 29/05/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import Foundation

struct Helper {
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        return documentsDirectory
    }
}
