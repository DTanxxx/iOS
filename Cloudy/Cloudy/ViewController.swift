//
//  ViewController.swift
//  Cloudy
//
//  Created by David Tan on 25/04/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UITableViewController {
    
    static var isDirty = true  // the flag is initially set to true because initially when we load the app, we want to reload data from iCloud in case any other users have made changes to iCloud
    
    var whistles = [Whistle]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "What's that Whistle?"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWhistle))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Genres", style: .plain, target: self, action: #selector(selectGenre))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: nil, action: nil)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    // MARK: - This method is called every time the view controller is about to show its view -> useful as it is called when 'back' button is tapped, but viewDidLoad() is not called when 'back' button is tapped
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // clear the table view's selection if it has one
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        // refresh our data from iCloud only if it's needed, depending on the isDirty flag -> if isDirty=true, that means there has been a change in iCloud (new CKRecord added), which means we need to reload data from iCloud
        if ViewController.isDirty {
            loadWhistles()
        }
    }
    
    func loadWhistles() {
        let pred = NSPredicate(value: true)  // grab all records of a record type (no filter applied)
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        let query = CKQuery(recordType: "Whistles", predicate: pred)
        query.sortDescriptors = [sort]
        
        let operation = CKQueryOperation(query: query)
        // only grab the record keys we want
        operation.desiredKeys = ["genre", "comments"]
        // specify how many results we want to receive from iCloud
        operation.resultsLimit = 50
        
        var newWhistles = [Whistle]()
        
        // set a recordFetchedBlock closure on our CKQueryOperation object -> this closure will be given one CKRecord value for every record that gets downloaded, and we will create a corresponding Whistle object for each record
        operation.recordFetchedBlock = { record in
            let whistle = Whistle(recordID: record.recordID)
            whistle.genre = record["genre"]
            whistle.comments = record["comments"]
            newWhistles.append(whistle)
        }
        
        // set a queryCompletionBlock closure -> this closure will be called when all records have been downloaded, and will be given 2 parameters: a query cursor and an error if there was one
        operation.queryCompletionBlock = { [unowned self] (cursor, error) in
            // push UI work onto main thread, as this closure might be run on any thread
            DispatchQueue.main.async {
                if error == nil {
                    // clear the flag
                    ViewController.isDirty = false
                    // overwrite our current whistles array with the newWhistles array
                    self.whistles = newWhistles
                    // reload table view
                    self.tableView.reloadData()
                } else {
                    let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of whistles; please try again: \(error!.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [unowned self] (_) in
                        self.loadWhistles()
                    }))
                    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    self.present(ac, animated: true)
                }
            }
        }
        
        // run the CKQueryOperation object
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    func makeAttributedString(title: String, subtitle: String) -> NSAttributedString {
        // this method will produce a nicely formatted string to be used in table view cells' labels
        let titleAttributes = [
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline),
            NSAttributedString.Key.foregroundColor: UIColor.purple
        ]
        let subtitleAttributes = [
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)
        ]
        
        let titleString = NSMutableAttributedString(string: "\(title)", attributes: titleAttributes)
        
        if subtitle.count > 0 {
            let subtitleString = NSAttributedString(string: "\n\(subtitle)", attributes: subtitleAttributes)
            titleString.append(subtitleString)
        }
        
        return titleString
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.whistles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.attributedText = makeAttributedString(title: whistles[indexPath.row].genre, subtitle: whistles[indexPath.row].comments)
        cell.textLabel?.numberOfLines = 0  // make the cell size dynamic
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ResultsViewController()
        vc.whistle = whistles[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func addWhistle() {
        let vc = RecordWhistleViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func selectGenre() {
        let vc = MyGenresViewController()
        navigationController?.pushViewController(vc, animated: true)
    }


}
/*
 Read from iCloud:
 
 • NSPredicate describes a filter that we'll use to decide which results to show.
 • NSSortDescriptor tells CloudKit which field we want to sort on, and whether we want it
 ascending or descending.
 • CKQuery combines a predicate and sort descriptors with the name of the record type we
 want to query. That will be "Whistles" for us, if you remember.
 • CKQueryOperation is the work horse of CloudKit data fetching, executing a query and
 returning results.
 
 */


