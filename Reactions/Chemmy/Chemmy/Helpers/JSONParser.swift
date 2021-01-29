//
//  JSONParser.swift
//  Chemmy
//
//  Created by David Tan on 23/09/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

class JSONParser {
    static var parsedActions: [Action]?
    
    // parses the Actions.json file
    public static func parseActions() {
        // get a path to the json file in our app bundle
        let path = Bundle.main.path(forResource: "Actions", ofType: ".json")
        guard path != nil else {
            print("Can't find the json file")
            return
        }
        
        // create an URL object from that string path
        let url = URL(fileURLWithPath: path!)
        // decode that data into instances of the Department Struct
        do {
            // get the data from that URL
            let data = try Data(contentsOf: url)
            // decode the json data
            let decoder = JSONDecoder()
            parsedActions = try decoder.decode([Action].self, from: data)
        }
        catch {
            print("Couldn't create Data object from file")
        }
    }
}
