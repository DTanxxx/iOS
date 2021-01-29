import UIKit

func unique(word: String) -> Bool {
    var letters = [String]()
    var letters2 = [String]()
    for letter in word {
        letters.append(String(letter))
    }
    for letter in letters {
        if letter in letters2 {
            return false
        }
    }
    return true
}

