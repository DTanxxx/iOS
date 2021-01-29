//
//  AuthorCommitsViewController.swift
//  Core_Data
//
//  Created by David Tan on 14/05/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import CoreData

class AuthorCommitsViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var commit: Commit!
    var allCommits: [Commit]!
    var sortedCommits = [Commit]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAllCommitsByAuthor()
    }
    
    func getAllCommitsByAuthor() {
        let authorName = commit.author.name
        let authorEmail = commit.author.email
        
        let filteredCommits = allCommits.filter { currentCommit in
            return (currentCommit.author.name == authorName &&
                currentCommit.author.email == authorEmail)
        }
        
        sortedCommits = filteredCommits.sorted { (c1, c2) -> Bool in
            return (c1.date > c2.date)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedCommits.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commit", for: indexPath)
        
        let commit = sortedCommits[indexPath.row]
        cell.textLabel?.text = commit.message
        cell.detailTextLabel?.text = "By \(commit.author.name) on \(commit.date.description)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            vc.detailItem = sortedCommits[indexPath.row]
            vc.didLoadFromMainVC = false
            navigationController?.pushViewController(vc, animated: true)
        }  
    }

   
}
