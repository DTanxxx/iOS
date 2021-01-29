//
//  TodayViewController.swift
//  Widget
//
//  Created by David Tan on 18/05/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var words = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load the shared user defaults (in an App Group), rather than its own sandboxed user defaults
        if let defaults = UserDefaults(suiteName: "group.com.learnappmaking.Polyglot") {
            if let savedWords = defaults.object(forKey: "Words") as? [String] {
                words = savedWords
            }
        }
        
        // set widget to have expanded mode (compact mode is the default)
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    // this method is called when the user has pressed the "Show More" or "Show Less" button (due to the available expanded mode)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        // change the size of the view controller depending on the current display mode
        if activeDisplayMode == .compact {
            preferredContentSize = CGSize(width: 0, height: 110)  // no need to worry about the width value
        } else {
            preferredContentSize = CGSize(width: 0, height: 440)
        }
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    // MARK: - table view datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        
        let word = words[indexPath.row]
        let split = word.components(separatedBy: "::")
        
        cell.textLabel?.text = split[0]
        
        // clear the detail text label -> if we don't do this, table cell recycling will mean you'll see incorrect words appearing in the table
        cell.detailTextLabel?.text = ""
        
        // change the cell selection style by adding a custom value to the cell's selectedBackgroundView property
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView!.backgroundColor = UIColor(white: 1, alpha: 0.20)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
}
