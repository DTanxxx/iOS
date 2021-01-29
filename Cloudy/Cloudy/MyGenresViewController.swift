//
//  MyGenresViewController.swift
//  Cloudy
//
//  Created by David Tan on 26/04/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import CloudKit

class MyGenresViewController: UITableViewController {
    
    var myGenres: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard
        if let savedGenres = defaults.object(forKey: "myGenres") as? [String] {
            myGenres = savedGenres
        } else {
            myGenres = [String]()
        }
        
        title = "Notify me about..."
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    @objc func saveTapped() {
        // save the array to UserDefaults
        let defaults = UserDefaults.standard
        defaults.set(myGenres, forKey: "myGenres")
        
        let database = CKContainer.default().publicCloudDatabase
        
        // remove any existing subscriptions so that we don't get duplicate errors, using fetchAllSubscriptions() and removing them one by one
        database.fetchAllSubscriptions { [unowned self] (subscriptions, error) in
            if error == nil {
                if let subscriptions = subscriptions {
                    for subscription in subscriptions {
                        database.delete(withSubscriptionID: subscription.subscriptionID) { (str, error) in
                            if error != nil {
                                let ac = UIAlertController(title: "Delete failed", message: "There was a problem deleting a subscription; please try again: \(error!.localizedDescription)", preferredStyle: .alert)
                                ac.addAction(UIAlertAction(title: "OK", style: .default))
                                self.present(ac, animated: true)
                            }
                        }
                    }
                    
                    // for each genre in myGenres, create a CKQuerySubscription
                    for genre in self.myGenres {
                        // create a predicate that searches for this particular genre in whistles records
                        let predicate = NSPredicate(format: "genre = %@", genre)
                        // create a subscription, which gets informed when any record is created that matches our genre predicate
                        let subscription = CKQuerySubscription(recordType: "Whistles", predicate: predicate, options: .firesOnRecordCreation)
                        
                        // create a push notification with a visible message attached
                        let notification = CKSubscription.NotificationInfo()
                        notification.alertBody = "There's a new whistle in the \(genre) genre."
                        notification.soundName = "default"
                        subscription.notificationInfo = notification
                        
                        // send the subscription off to iCloud
                        database.save(subscription) { (result, error) in
                            if let error = error {
                                let ac = UIAlertController(title: "Save failed", message: "There was a problem saving your selected genres; please try again: \(error.localizedDescription)", preferredStyle: .alert)
                                ac.addAction(UIAlertAction(title: "OK", style: .default))
                                self.present(ac, animated: true)
                            }
                        }
                    }
                }
            } else {
                let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of subscriptions; please try again: \(error!.localizedDescription)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SelectGenreViewController.genres.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let genre = SelectGenreViewController.genres[indexPath.row]
        cell.textLabel?.text = genre
        
        // if myGenres contains the particular genre, include a checkmark on the cell
        if myGenres.contains(genre) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let selectedGenre = SelectGenreViewController.genres[indexPath.row]
            
            if cell.accessoryType == .none {
                cell.accessoryType = .checkmark
                myGenres.append(selectedGenre)
            } else {
                cell.accessoryType = .none
                
                if let index = myGenres.firstIndex(of: selectedGenre) {
                    myGenres.remove(at: index)
                }
            }
        }
        
        // deselect the row
        tableView.deselectRow(at: indexPath, animated: false)
    }

}
/*
 CKQuerySubscription lets you configure a query to run on the iCloud servers, and as soon as that query matches something it will automatically trigger a push message.
 */
