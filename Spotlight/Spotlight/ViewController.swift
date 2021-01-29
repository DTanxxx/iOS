//
//  ViewController.swift
//  Spotlight
//
//  Created by David Tan on 30/01/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import SafariServices
import CoreSpotlight
import MobileCoreServices

class ViewController: UITableViewController {
    
    var projects = [SwiftProject]()
    var favorites = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        projects.append(SwiftProject(title: "Project 1: Storm Viewer", body: "Constants and variables, UITableView, UIImageView, FileManager, storyboards"))
        projects.append(SwiftProject(title: "Project 2: Guess the Flag", body: "@2x and @3x images, asset catalogs, integers, doubles, floats, operators (+= and -=), UIButton, enums, CALayer, UIColor, random numbers, actions, string interpolation, UIAlertController"))
        projects.append(SwiftProject(title: "Project 3: Social Media", body: "UIBarButtonItem, UIActivityViewController, the Social framework, URL"))
        projects.append(SwiftProject(title: "Project 4: Easy Browser", body: "loadView(), WKWebView, delegation, classes and structs, URLRequest, UIToolbar, UIProgressView., key-value observing"))
        projects.append(SwiftProject(title: "Project 5: Word Scramble", body: "Closures, method return values, booleans, NSRange"))
        projects.append(SwiftProject(title: "Project 6: Auto Layout", body: "Get to grips with Auto Layout using practical examples and code"))
        projects.append(SwiftProject(title: "Project 7: Whitehouse Petitions", body: "JSON, Data, UITabBarController"))
        projects.append(SwiftProject(title: "Project 8: 7 Swifty Words", body: "addTarget(), enumerated(), count, index(of:), property observers, range operators"))
        
        let defaults = UserDefaults.standard
        if let savedFavorites = defaults.object(forKey: "favorites") as? [Int] {
            favorites = savedFavorites
        }
        
        // set the table view to be in editing mode
        tableView.isEditing = true
        // allows user to tap on cells while table view is in editing mode
        tableView.allowsSelectionDuringEditing = true
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(updateUI), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let project = projects[indexPath.row]
        cell.textLabel?.attributedText = makeAttributedString(title: project.title, subtitle: project.body)
        
        if favorites.contains(indexPath.row) {
            // cell.accessoryType isn't shown when table view is in editing mode, so we use .editingAccessoryType instead
            cell.editingAccessoryType = .checkmark
        } else {
            cell.editingAccessoryType = .none
        }
        
        return cell
    }
    
    // MARK: - add the 'insert' icon for some cells and 'delete' icon for others
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if favorites.contains(indexPath.row) {
            return .delete
        } else {
            return .insert
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .insert {
            // if adding a favorite:
            favorites.append(indexPath.row)
            index(item: indexPath.row)
        } else {
            if let index = favorites.firstIndex(of: indexPath.row) {
                favorites.remove(at: index)
                deindex(item: indexPath.row)
            }
        }
        
        let defaults = UserDefaults.standard
        defaults.set(favorites, forKey: "favorites")
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func index(item: Int) {
        // get the project
        let project = projects[item]
        // create a CSSearchableItemAttributeSet object from it, which can store lots of information for search
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)  // kUTTypeText as String tells iOS we want to store text in our indexed record
        attributeSet.title = project.title
        attributeSet.contentDescription = project.body
        
        // wrap up the attribute set inside a CSSearchableItem object
        let item = CSSearchableItem(uniqueIdentifier: "\(item)", domainIdentifier: "com.hackingwithswift", attributeSet: attributeSet)  // the uniqueIdentifier must identify the item absolutely uniquely
        // the domainIdentifier is a way to group items together
        
        item.expirationDate = Date.distantFuture  // make the item that you index never expire
        
        // index the array of item(s) passed in
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully indexed!")
            }
        }
    }
    
    func deindex(item: Int) {
        // de-index the item
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(item)"]) { error in
            if let error = error {
                print("Deindexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully removed!")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showTutorial(indexPath.row)
    }
    
    func makeAttributedString(title: String, subtitle: String) -> NSAttributedString {
        // create a font that can be changed later on by user using preferredFont() - it's called Dynamic Type
        let titleAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline), NSAttributedString.Key.foregroundColor: UIColor.purple, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.double.rawValue, NSAttributedString.Key.underlineColor: UIColor.red] as [NSAttributedString.Key: Any]
        
        let subtitleAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)]
        
        let titleString = NSMutableAttributedString(string: "\(title)\n", attributes: titleAttributes)
        let subtitleString = NSMutableAttributedString(string: subtitle, attributes: subtitleAttributes)
        
        titleString.append(subtitleString)
        
        return titleString
    }
    
    func showTutorial(_ which: Int) {
        if let url = URL(string: "https://www.hackingwithswift.com/read/\(which + 1)") {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
    
    @objc func updateUI() {
        tableView.reloadData()
    }

}
// Note: when you tap on an item in Spotlight search a method in SceneDelegate.swift is called.


