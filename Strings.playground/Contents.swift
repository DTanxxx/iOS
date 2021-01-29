import UIKit

let name = "Taylor"

// you can loop over strings
for letter in name {
    print("Give me a \(letter)")
}

// but you cannot do this:
//print(name[3])
// because letters in a string are not just alphabetical characters, they can contain accents, combining marks, symbols, or they can even be emojis

// therefore if you want to read the fourth character of name you need to start at the beginning and count through each letter
let letter = name[name.index(name.startIndex, offsetBy: 3)]
print(letter)

// however, you can add an extension to make name[3] valid
extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}
print(name[3])

// tip: if you are looking for an empty string, use someString.isEmpty rather than someString.count == 0



// MARK: - Some methods and extensions for strings

let password = "12345"
password.hasPrefix("123")
password.hasSuffix("345")

extension String {
    // remove a prefix if it exists
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    // remove a suffix if it exists
    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
}
print(password.deletingPrefix("123"))
print(password.deletingSuffix("345"))


let weather = "it's going to rain"
print(weather.capitalized)

extension String {
    var capitalizedFirst: String {
        guard let firstLetter = self.first else { return "" }
        return firstLetter.uppercased() + self.dropFirst()
    }
}
print(weather.capitalizedFirst)

// note: Letters in a string are not instances of String but are instances of Character, so the uppercased() method is actually a method on Character rather than String. However Character.uppercased() actually returns a String, not a Character. Reason: some languages do not have one-to-one mappings between lowercase and uppercase characters, eg in German, "B" becomes "SS" when uppercased, and "SS" is two separate letters, so uppercased() will have to return a string.


let input = "Swift is like Objective-C without the C"
input.contains("Swift")
let languages = ["Python", "Ruby", "Swift"]
languages.contains("Swift")

// how to check whether any string in our array exists in our input string:
// 1st way:
extension String {
    func containsAny(of array: [String]) -> Bool {
        for item in array {
            if self.contains(item) {
                return true
            }
        }
        return false
    }
}
input.containsAny(of: languages)

// 2nd way:
languages.contains(where: input.contains)

// This contains(where:) method of arrays lets us provide a closure that accepts an element from the array as its only parameter and returns true or false depending on whatever condition we decide we want. This closure gets run on all the items in the array until one returns true, at which point it stops.
// So stepping through the code, contains(where:) will call its closure once for every element in the languages array until it finds one that returns true, at which point it stops. We are passing input.contains as the closure that contains(where:) should run. Since the contains() method of strings has the exact same signature that contains(where:) expects (take a string and return a Boolean), this works perfectly.



// MARK: - Formatting strings with NSAttributedString

let string = "This is a test string"
let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white, .backgroundColor: UIColor.red, .font: UIFont.boldSystemFont(ofSize: 36)]

let attributedString = NSAttributedString(string: string, attributes: attributes)

// Above things can also be done with a string placed inside a UILabel, however what labels cannot do is add formatting to different parts of the string.
// We can however do so with NSMutableAttributedString, which is an attributed string that you can modify:
let attributedString2 = NSMutableAttributedString(string: string)
attributedString2.addAttribute(.font, value: UIFont.systemFont(ofSize: 8), range: NSRange(location: 0, length: 4))
attributedString2.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 5, length: 2))
attributedString2.addAttribute(.font, value: UIFont.systemFont(ofSize: 24), range: NSRange(location: 8, length: 1))
attributedString2.addAttribute(.font, value: UIFont.systemFont(ofSize: 32), range: NSRange(location: 10, length: 4))
attributedString2.addAttribute(.font, value: UIFont.systemFont(ofSize: 40), range: NSRange(location: 15, length: 6))

// When you preview above code you'll see the font size get larger with each word.



// MARK: - Challenges
// 1.
extension String {
    func withPrefix(_ prefix: String) -> String {
        if self.contains(prefix) { return self }
        return prefix + self
    }
}
"pet".withPrefix("car")

// 2.
extension String {
    func isNumeric() -> Bool {
        for i in 0 ..< self.count {
            if !self[self.index(self.startIndex, offsetBy: i)].isNumber {
                return false
            }
        }
        return true
    }
}
"12321".isNumeric()

// 3.
extension String {
    var lines: [String] {
        var arrayStrings = [String]()
        let array = self.split(separator: "\n") as [Substring]
        for i in array {
            arrayStrings.append(String(i))
        }
        return arrayStrings
    }
}
"this\nis\na\ntest".lines

