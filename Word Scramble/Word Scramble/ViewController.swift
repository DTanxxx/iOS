//
//  ViewController.swift
//  Word Scramble
//
//  Created by David Tan on 20/09/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                // try? means "call this code, and if it throws an error just send me back nil instead." This means the code you call will always work, but you need to unwrap the result carefully.
                // Since combining try? with the String object will return String? (may be a string, if not then nil), the if let keyword checks for nil.
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        let defaults = UserDefaults.standard
        if let savedTitle = defaults.string(forKey: "title") {
            title = savedTitle
            if let savedWords = defaults.stringArray(forKey: "words") {
                usedWords = savedWords
                return
            }
        }
        startGame()
    }
    
    @objc func startGame() {
        title = allWords.randomElement()
        let defaults = UserDefaults.standard
        defaults.set([String](), forKey: "words")
        defaults.set(title, forKey: "title")
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
        // Calling reloadData() forces the tableView to call numberOfRowsInSection again, as well as calling cellForRowAt repeatedly
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        // Weak: a weakly owned reference might be nil, so you need to unwrap it or use optional chaining--treat it as a regular optional
        // Unowned: an unowned reference is one you're certifying cannot be nil and so doesn't need to be unwrapped, however you'll hit a problem if you were wrong--treat it as an implicitly unwrapped optional
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        // Here, the 'action' parameter in 'action in' refers to the UIAlertAction object, we can replace it with '_' as we do not make any reference to 'action'.
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        //let errorTitle: String
        //let errorMessage: String
        // Since the constants are inside a function/method, it is ok for them to not be initialised at the start. However if you want to use them in any ways you have to provide some values to the constants.
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    // Add the word to the start of the array, so that the newest words will appear at the top of the table view.
                    usedWords.insert(lowerAnswer, at: 0)
                    let defaults = UserDefaults.standard
                    defaults.set(usedWords, forKey: "words")
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    // Here, although we can just do reloadData() as tableview cells are created from usedWords, we are inserting rows instead.
                    // Because by calling the reloadData() method and have the table do a full reload of all rows, a lot of extra work is needed for one small change, and also causes a jump – the word wasn't there, and now it is.
                    // 'insertRows' provides a trackable animation for the player.
                    // Note: the 'with' parameter lets you specify how the row should be animated in.
                    
                    return
                }
                else {
                    showErrorMessage(title: "Word not recognised", message: "It has to be a valid word!")
                }
            }
            else {
                showErrorMessage(title:  "Word already used", message: "Please be original!")
            }
        }
        else {
            guard let title = title?.lowercased() else { return }
            showErrorMessage(title: "Word not possible", message: "You can't spell that word from \(title)")
        }
    }
    
    func isPossible(word: String) -> Bool {
        // Checking that the word is actually displayed.
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            // Checking the letter is actually in the given word.
            if let letterIndex = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: letterIndex)
            }
            else {
                return false
            }
        }
        
        return true
        // Note: we have told Swift that we are returning a boolean value from this method, and it will check every possible outcome of the code to make sure a boolean value is returned no matter what.
    }
    
    func isOriginal(word: String) -> Bool {
        
        if word == title { return false }

        return !usedWords.contains(word)
        // The '!' here means 'not'.
        // When used before a variable or constant, ! means "not" or "opposite". So if contains() returns true, ! flips it around to make it false, and vice versa. When used after a variable or constant, ! means "force unwrap this optional variable."
    }
    
    func isReal(word: String) -> Bool {
        
        if word.count < 3 {
            return false
        }
        
        let checker = UITextChecker()
        // Creates an UITextChecker object, which is designed to help spotting errors.
        
        let range = NSRange(location: 0, length: word.utf16.count)
        // NSRange stores a string range, which is a value that holds a start position and a length.
        // The utf16.count here is actually used for Objective-C. Objc counts emoji as 2-letter string while Swift strings count emoji as 1-letter string.
        // The rule is: when you’re working with UIKit, SpriteKit, or any other Apple framework, use utf16.count for the character count. If it’s just your own code - i.e. looping over characters and processing each one individually – then use count instead.
        
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        // 'rangeOfMisspelledWord' is another NSRange structure, which tells you where the misspelling was found.
        // If nothing was found our NSRange will have the special location NSNotFound.
        // Usually 'location' tells you where the misspelling started.
        
        return misspelledRange.location == NSNotFound
    }
    
    func showErrorMessage(title:String, message:String) {
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

}
