//
//  ResultsViewController.swift
//  Cloudy
//
//  Created by David Tan on 25/04/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import AVFoundation
import CloudKit

class ResultsViewController: UITableViewController {
    
    var whistle: Whistle!
    var suggestions = [String]()
    var whistlePlayer: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Genre: \(whistle.genre!)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Download", style: .plain, target: self, action: #selector(downloadTapped))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        downloadSuggestions()
    }
    
    @objc func downloadTapped() {
        // Replace the button with a spinner so the user knows the data is being fetched.
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.tintColor = UIColor.black
        spinner.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
        
        // Ask CloudKit to pull down the full record for the whistle, including the audio, using fetch(withRecordID:)
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: whistle.recordID) { [unowned self] (record, error) in
            if let error = error {
                // If something goes wrong, show a meaningful error message and put the Download button back
                DispatchQueue.main.async {
                    let ac = UIAlertController(title: "Download failed", message: "There was a problem downloading this whistle; please try again: \(error.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                    
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Download", style: .plain, target: self, action: #selector(self.downloadTapped))
                }
            } else {
                if let record = record {
                    // If it successfully gets audio for the whistle, attach it to the Whistle object of this view controller.
                    if let asset = record["audio"] as? CKAsset {
                        self.whistle.audio = asset.fileURL
                        
                        // Create a new right bar button item that says "Listen" and will call listenTapped().
                        DispatchQueue.main.async {
                            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Listen", style: .plain, target: self, action: #selector(self.listenTapped))
                        }
                    }
                }
            }
        }
    }
    
    @objc func listenTapped() {
        do {
            whistlePlayer = try AVAudioPlayer(contentsOf: whistle.audio)
            whistlePlayer.play()
        } catch {
            let ac = UIAlertController(title: "Playback failed", message: "There was a problem playing your whistle; please try re-recording.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func downloadSuggestions() {
        // create a CKRecord.Reference that will be used as a filter, by NSPredicate
        let reference = CKRecord.Reference(recordID: whistle.recordID, action: .deleteSelf)
        let pred = NSPredicate(format: "owningWhistle == %@", reference)
        let sort = NSSortDescriptor(key: "creationDate", ascending: true)
        let query = CKQuery(recordType: "Suggestions", predicate: pred)
        query.sortDescriptors = [sort]
        
        // here we won't be using CKQueryOperation, since we want all the fields -> we will be using convenience API here: performQuery()
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { [unowned self] (results, error) in
            if let error = error {
                let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of suggestions; please try again: \(error.localizedDescription)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
            } else {
                if let results = results {
                    self.parseResults(records: results)
                }
            }
        }
    }
    
    func parseResults(records: [CKRecord]) {
        // to make things safer on multiple threads, we'll actually use an intermediate array called newSuggestions - it's never smart to modify data in a background thread that is being used on the main thread
        var newSuggestions = [String]()
        
        for record in records {
            newSuggestions.append(record["text"] as! String)
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.suggestions = newSuggestions
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // provide a title for the second section (the suggestions)
        if section == 1 {
            return "Suggested songs"
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return suggestions.count + 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none  // make cell selection invisible
        cell.textLabel?.numberOfLines = 0
        
        if indexPath.section == 0 {
            // the user's comments about this whistle
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
            
            if whistle.comments.count == 0 {
                cell.textLabel?.text = "Comments: None"
            } else {
                cell.textLabel?.text = whistle.comments
            }
        } else {
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
            
            if indexPath.row == suggestions.count {
                // this is our extra row -> make cell selection visible
                cell.textLabel?.text = "Add suggestion"
                cell.selectionStyle = .gray
            } else {
                cell.textLabel?.text = suggestions[indexPath.row]
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // only continue the method if user taps on the second section, last row ('Add suggestion' row)
        guard indexPath.section == 1 && indexPath.row == suggestions.count else { return }
        
        // deselect the row that was tapped -> making highlight temporary
        tableView.deselectRow(at: indexPath, animated: true)
        
        let ac = UIAlertController(title: "Suggest a song...", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [unowned self, ac] (action) in
            // grab the text field -> remember to capture ac at the start of closure
            if let textField = ac.textFields?[0] {
                // check if there is text
                if textField.text!.count > 0 {
                    self.add(suggestion: textField.text!)
                }
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func add(suggestion: String) {
        let whistleRecord = CKRecord(recordType: "Suggestions")
        // use CKRecord.Reference to link a user's suggestion to the recordID of the whistle they were reading about
        // you pass in a record ID to link to, and a behaviour to trigger when that linked record is deleted
        let reference = CKRecord.Reference(recordID: whistle.recordID, action: .deleteSelf)
        whistleRecord["text"] = suggestion as CKRecordValue
        whistleRecord["owningWhistle"] = reference as CKRecordValue
        
        CKContainer.default().publicCloudDatabase.save(whistleRecord) { [unowned self] (record, error) in
            DispatchQueue.main.async {
                if error == nil {
                    self.suggestions.append(suggestion)
                    self.tableView.reloadData()
                } else {
                    let ac = UIAlertController(title: "Error", message: "There was a problem submitting your suggestion: \(error!.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
    }

   

}
