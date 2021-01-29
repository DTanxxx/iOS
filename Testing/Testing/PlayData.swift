//
//  PlayData.swift
//  Testing
//
//  Created by David Tan on 14/03/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import Foundation

class PlayData {
    
    private(set) var filteredWords = [String]()  // this property can be read from anywhere, but only the PlayData class can write to it
    var allWords = [String]()
    var wordCounts: NSCountedSet!  // this is a set data type, which means that items can only be added once; however it is a specialised set object: it keeps track of how many times items you tried to add and remove each item, which means it can handle de-duplicating our words while storing how often they are used
    // all that means NSCountedSet is very fast
    
    init() {
        if let path = Bundle.main.path(forResource: "plays", ofType: "txt") {
            if let plays = try? String(contentsOfFile: path) {
                allWords = plays.components(separatedBy: CharacterSet.alphanumerics.inverted)
                // CharacterSet.alphanumerics.inverted will split the string by any number of characters (ie it will split a string on anything that isn't a letter or number eg punctuations)
                
                // filter the allWords array so that empty strings are removed
                allWords = allWords.filter { $0 != "" }
                
                // create a counted set from all the words, which immediately de-duplicates and counts them all
                wordCounts = NSCountedSet(array: allWords)
                
                // sort the wordCounts array so that the most frequent words appear at the top of the table view
                let sorted = wordCounts.allObjects.sorted {
                    wordCounts.count(for: $0) > wordCounts.count(for: $1)
                }
                
                // update the allWords array to be the words from the sorted set
                allWords = sorted as! [String]
            }
        }
        
        applyUserFilter("swift")
    }
    
    // MARK: - filtering methods
    
    func applyUserFilter(_ input: String) {
        // this method will either show only words that occur at or greater than a certain frequency, or show words that contain a specific string
        // it does that by deciding whether the parameter contains a number or not => a number means frequency, a string means the words that have it
        
        if let userNumber = Int(input) {  // this uses a special Int failable initialiser
            // we got a number
            applyFilter { self.wordCounts.count(for: $0) >= userNumber }
        } else {
            // we got a string
            let input = input.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if input.isEmpty {
                filteredWords = allWords
            } else {
                applyFilter { $0.range(of: input, options: .caseInsensitive) != nil }
            }
        }
    }
    
    func applyFilter(_ filter: (String) -> Bool) {
        // this method has a paramter that is a function which takes a string and returns a boolean => this matches the filter() method
        filteredWords = allWords.filter(filter)
    }
    
    
}


