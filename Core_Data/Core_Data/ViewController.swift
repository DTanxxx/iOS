//
//  ViewController.swift
//  Core_Data
//
//  Created by David Tan on 11/03/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var container: NSPersistentContainer!
    var commitPredicate: NSPredicate?
    var fetchedResultsController: NSFetchedResultsController<Commit>!
    var rowDeletionImportantNumber: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(changeFilter))
        
        container = NSPersistentContainer(name: "Core_Data")
        
        // load the saved database if it exists, or creates it otherwise
        container.loadPersistentStores { (storeDescription, error) in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy  // this instructs Core Data to allow updates to Commit objects: if an object exists in its data store with message A, and an object with the same unique constraint ("sha" attribute) exists in memory with message B, the in-memory version overwrites the data store version
            
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
        
        // fetch the JSON data form GitHub => this is done on a background thread
        performSelector(inBackground: #selector(fetchCommits), with: nil)
        
        // load the Commit objects saved that match the query
        loadSavedData(commitPredicate)
    }
    
    func saveContext() {
        // this method will save any changes from memory back to the database on disk (the database used is SQLite)
        // it will be called whenever we have made changes that should be saved to disk
        
        if container.viewContext.hasChanges {
            // if the managed object context (an environment where we can manipulate Core Data objects) has been changed since the last save, save it
            do {
                try container.viewContext.save()
            } catch {
                 print("An error occurred while saving: \(error)")
            }
        }
    }
    
    // MARK: - fetching data and creating NSManagedObjects
    
    @objc func fetchCommits() {
        let newestCommitDate = getNewestCommitDate()  // get the date which is set to one second after the most recent commit, so that the data we fetch will either contain only new commits or no commits at all - if no commits are received that means we would just load the previously-saved commits, so that deletions of commits are maintained and carried over to the UI (rather than having data of all the commits again, which would refresh our context and erase the effect of deletions)
        
        // download the contents of the GitHub url into a String object
        if let data = try? String(contentsOf: URL(string: "https://api.github.com/repos/apple/swift/commits?per_page=100&since=\(newestCommitDate)")!) {
            // give the data to SwiftyJSON to parse
            let jsonCommits = JSON(parseJSON: data)
            
            // read the commits back out
            let jsonCommitArray = jsonCommits.arrayValue
            
            print("Received \(jsonCommitArray.count) new commits.")
            
            // go back to the main thread to loop over the array of GitHub commits and save the managed object context when we're done
            DispatchQueue.main.async {
                [unowned self] in
                for jsonCommit in jsonCommitArray {
                    // create a Commit object inside the managed object context
                    let commit = Commit(context: self.container.viewContext)  // note that the Commit object here is the NSManagedObject
                    self.configure(commit: commit, usingJSON: jsonCommit)
                }
                
                self.saveContext()
                
                // load the Commit objects saved that match the query
                self.loadSavedData(self.commitPredicate)
            }
        }
    }
    
    func configure(commit: Commit, usingJSON json: JSON) {
        // edit the Commit object to give its attributes some values (they weren't given any values at the start)
        commit.sha = json["sha"].stringValue
        commit.message = json["commit"]["message"].stringValue
        commit.url = json["html_url"].stringValue
        
        // use a formatter to convert date from ISO-8601 format to Date format
        let formatter = ISO8601DateFormatter()
        commit.date = formatter.date(from: json["commit"]["committer"]["date"].stringValue) ?? Date()
        
        // set the author attribute of a commit:
        var commitAuthor: Author!
        
        // see if this Author object exists in the context already
        let authorRequest = Author.createFetchRequest()
        authorRequest.predicate = NSPredicate(format: "name == %@", json["commit"]["committer"]["name"].stringValue)
        
        if let authors = try? container.viewContext.fetch(authorRequest) {
            if authors.count > 0 {
                // we have this author already
                commitAuthor = authors[0]
            }
        }
        
        if commitAuthor == nil {
            // we didn't find a saved author - create a new one
            let author = Author(context: container.viewContext)
            author.name = json["commit"]["committer"]["name"].stringValue
            author.email = json["commit"]["committer"]["email"].stringValue
            commitAuthor = author
        }
        
        // use the author, either saved or new
        commit.author = commitAuthor
    }
    
    func getNewestCommitDate() -> String {
        let defaults = UserDefaults.standard
        var currentMostRecentDate: Date = Date(timeIntervalSince1970: 0)
        let formatter = ISO8601DateFormatter()
        
        let newest = Commit.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)  // get the newest commit
        newest.sortDescriptors = [sort]
        newest.fetchLimit = 1  // only fetch 1 Commit object
        
        if let commits = try? container.viewContext.fetch(newest) {
            if commits.count > 0 {
                // get the date of the newest commit, plus 1 second
                currentMostRecentDate = commits[0].date.addingTimeInterval(1)
            }
        }
        
        // check if there is a stored date
        if let date = defaults.object(forKey: "mostRecentDate") as? Date {
            // compare this stored date with the most recent date
            // the more recent date is the 'larger' date
            if date >= currentMostRecentDate {
                // stored date is more recent/equally recent
                return formatter.string(from: date)
            } else if date < currentMostRecentDate {
                // stored date is less recent
                defaults.set(currentMostRecentDate, forKey: "mostRecentDate")
                return formatter.string(from: currentMostRecentDate)
            }
        } else {
            // if there isn't a stored date, store the most recent commit's date in defaults, then return that date in string form
            defaults.set(currentMostRecentDate, forKey: "mostRecentDate")
            return formatter.string(from: currentMostRecentDate)
        }
        
        fatalError("This method should have returned already, with a valid string date.")
    }
    
    // MARK: - query for NSManagedObjects
    
    func loadSavedData(reloadTableView: Bool = true, _ predicateToUse: NSPredicate?) {
        // use a fetchedResultsController instead of NSFetchRequest, to improve the performace of fetching process
        if fetchedResultsController == nil {
            let request = Commit.createFetchRequest()
            let sort = NSSortDescriptor(key: "author.name", ascending: true)  // "give an array of commits sorted by author's name ascending, so that names with 'A' come first"
            request.sortDescriptors = [sort]  // you can pass in an array of NSSortDescriptors to the request, so you can say "sort by date descending, then by message ascending"
            request.fetchBatchSize = 20  // only fetch 20 objects at a time
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: "author.name", cacheName: nil)  // sectionNameKeyPath: "author.name" creates number of sections equal to number of different author names in the commits
            fetchedResultsController.delegate = self
        }
        
        fetchedResultsController.fetchRequest.predicate = predicateToUse  // the predicate acts as a filter for the fetch request
        
        do {
            try fetchedResultsController.performFetch()  // get an array of NSManagedObjects matching the request
            if reloadTableView {
                tableView.reloadData()  // reload the table view to make data appear
            }
        } catch {
            print("Fetch failed")
        }
    }
    
    @objc func changeFilter() {
        let ac = UIAlertController(title: "Filter commits...", message: nil, preferredStyle: .actionSheet)
        
        // 1. Predicate for matching an exact string:
        ac.addAction(UIAlertAction(title: "Show only fixes", style: .default, handler: { [unowned self] (_) in
            self.commitPredicate = NSPredicate(format: "message CONTAINS[c] 'fix'")  // "CONTAINS" part ensures this predicate matches only objects that contain the provided string somewhere in their message (in this case, it's the objects that contain the string 'fix'). "[c]" part means 'case-insensitive'.
            self.loadSavedData(self.commitPredicate)
        }))
        
        // 2. Predicate for matching the start of the text with a string:
        ac.addAction(UIAlertAction(title: "Ignore Pull Requests", style: .default, handler: { [unowned self] (_) in
            self.commitPredicate = NSPredicate(format: "NOT message BEGINSWITH 'Merge pull request'")  // this will match objects that DO NOT begin with 'Merge pull request'
            self.loadSavedData(self.commitPredicate)
        }))
        
        // 3. Predicate for matching a date:
        ac.addAction(UIAlertAction(title: "Show only recent", style: .default, handler: { [unowned self] (_) in
            let twelveHoursAgo = Date().addingTimeInterval(-43200)
            self.commitPredicate = NSPredicate(format: "date > %@", twelveHoursAgo as NSDate)  // this will request only commits that took place 43200 seconds ago (12 hours)
            self.loadSavedData(self.commitPredicate)
        }))
        
        // 4. Predicate for matching an Author's name:
        ac.addAction(UIAlertAction(title: "Show only Durian commits", style: .default, handler: { [unowned self] (_) in
            self.commitPredicate = NSPredicate(format: "author.name == 'Joe Groff'")
            self.loadSavedData(self.commitPredicate)
        }))
        
        // 5. Nil Predicate:
        ac.addAction(UIAlertAction(title: "Show all commits", style: .default, handler: { [unowned self] (_) in
            self.commitPredicate = nil  // so we can show all the commits again
            self.loadSavedData(self.commitPredicate)
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    // MARK: - table view methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commit", for: indexPath)
        
        let commit = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = commit.message
        //cell.detailTextLabel?.text = commit.date.description  // this gives a String representation of Date
        cell.detailTextLabel?.text = "By \(commit.author.name) on \(commit.date.description)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            vc.detailItem = fetchedResultsController.object(at: indexPath)
            
            // grab all the commits (using nil for predicate parameter)
            loadSavedData(reloadTableView: false, nil)
            vc.allCommits = fetchedResultsController.fetchedObjects
            vc.didLoadFromMainVC = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // this method handles deletion of Commit objects
        if editingStyle == .delete {
            let commit = fetchedResultsController.object(at: indexPath)
            rowDeletionImportantNumber = fetchedResultsController.sections![indexPath.section].numberOfObjects
            container.viewContext.delete(commit)
            
            // save the changes
            saveContext()
        }
        // We didn't need to delete items from the fetched results controller (and we can't) and we didn't need to use deleteRows(at:) on the table view, because when we delete the commit object from the managed object context, the managed object context will inform the change to our fetched results controller, which will in turn notify our view controller (since we used the managed object context to initialise the fetched results controller, and we set our view controller as the delegate of fetched results controller).
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // set the header text for each section with author's name
        return fetchedResultsController.sections![section].name
    }
    
    //MARK: - adjust table view when a commit object gets deleted
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        // this method gets called by the fetched results controller when an object changes
        // this method can be called from anywhere: if we delete an object in any other way (eg in the detail view), this method will automatically be called and the table will update
        
        switch type {
        case .delete:
            if controller.sections![indexPath!.section].numberOfObjects == 1 &&
                rowDeletionImportantNumber == 1 {
                tableView.deleteSections(IndexSet(integer: indexPath!.section), with: .automatic)
            } else {
                tableView.deleteRows(at: [indexPath!], with: .automatic)
            }
        default:
            break
        }
    }
    

}

// MARK: - Four steps in setting up Core Data:

// 1. Create a data model
// 2. Load the model we just defined, load a persistent store where saved objects can be stored, and also create a managed object context where our objects will live while they are active.
// 3. Create objects inside Core Data so that we can fetch and store data from GitHub (or anywhere of interest).
// 4. Load the Core Data objects saved and use them.

// MARK: - Problems with using attribute constraints and NSFetchedResultsController together:

// Using attribute constraints can cause problems with NSFetchedResultsController because attribute constraints are only enforced as unique when a save happens, which means if you're inserting data then an NSFetchedResultsController may contain duplicates until a save takes place.
// One solution is to save the context before loading the data.


