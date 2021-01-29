//
//  ViewController.swift
//  Polyglot
//
//  Created by David Tan on 18/05/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var words = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // customize the font of our view controller's title
        let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "AmericanTypewriter", size: 22)!]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        title = "POLYGLOT"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewWord))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(startTest))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "End Test", style: .plain, target: nil, action: nil)
        
        // load the shared user defaults (in an App Group), rather than its own sandboxed user defaults
        if let defaults = UserDefaults(suiteName: "group.com.learnappmaking.Polyglot") {
            if let savedWords = defaults.object(forKey: "Words") as? [String] {
                words = savedWords
            } else {
                saveInitialValues(to: defaults)
            }
        }
    }
    
    func saveInitialValues(to defaults: UserDefaults) {
        words.append("bear::l'ours")
        words.append("camel::le chameau")
        words.append("cow::la vache")
        words.append("fox::le renard")
        words.append("goat::la chèvre")
        words.append("monkey::le singe")
        words.append("pig::le cochon")
        words.append("rabbit::le lapin")
        words.append("sheep::le mouton")
        
        defaults.set(words, forKey: "Words")
    }
    
    func saveWords() {
        // write to the shared user defaults (in an App Group), rather than its own sandboxed user defaults
        if let defaults = UserDefaults(suiteName: "group.com.learnappmaking.Polyglot") {
            defaults.set(words, forKey: "Words")
        }
    }
    
    @objc func startTest() {
        guard let vc = storyboard?.instantiateViewController(identifier: "Test") as? TestViewController else { return }
        vc.words = words
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func addNewWord() {
        // create our alert controller
        let ac = UIAlertController(title: "Add new word", message: nil, preferredStyle: .alert)
        
        // add two text fields, one for English and one for French -> provide each addTextField() method a configuration closure that sets some placeholder text
        ac.addTextField { (textField) in
            textField.placeholder = "English"
        }
        
        ac.addTextField { (textField) in
            textField.placeholder = "French"
        }
        
        // create an "Add Word" button that submits the user's input
        let submitAction = UIAlertAction(title: "Add Word", style: .default) {
            [unowned self] (action: UIAlertAction!) in
            // pull out the English and French words, or an empty string if there was a problem
            let firstWord = ac.textFields?[0].text ?? ""
            let secondWord = ac.textFields?[1].text ?? ""
            
            // submit the English and French word to the insertFlashcard() method
            self.insertFlashcard(first: firstWord, second: secondWord)
        }
        
        // add the submit action, plus a cancel button
        ac.addAction(submitAction)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // present the alert controller to the user
        present(ac, animated: true)
    }
    
    func insertFlashcard(first: String, second: String) {
        // ensure it has valid strings for both English and French
        guard first.count > 0 && second.count > 0 else { return }
        
        // create a new IndexPath object based on the number of words in the words property
        let newIndexPath = IndexPath(row: words.count, section: 0)
        
        // add the new word to the words property by combining the English and French parts
        words.append("\(first)::\(second)")
        
        // call insertRows() on the table view to update the UI
        tableView.insertRows(at: [newIndexPath], with: .automatic)
        
        // call saveWords() to write the changed words property to disk
        saveWords()
    }
    
    // MARK: - table view datasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        
        let word = words[indexPath.row]
        let split = word.components(separatedBy: "::")
        
        cell.textLabel?.text = split[0]
        
        // clear the detail text label -> if we don't do this, table cell recycling will mean you'll see incorrect words appearing in the table
        cell.detailTextLabel?.text = ""
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.detailTextLabel?.text == "" {
                let word = words[indexPath.row]
                let split = word.components(separatedBy: "::")
                cell.detailTextLabel?.text = split[1]
            } else {
                cell.detailTextLabel?.text = ""
            }
        }
    }
    
    // this method will handle any deletion of rows
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        words.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        saveWords()
    }


}

