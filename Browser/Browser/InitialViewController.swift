//
//  InitialViewController.swift
//  Browser
//
//  Created by David Tan on 19/09/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

class InitialViewController: UITableViewController {
    
    var websites = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let startWebsitesUrl = Bundle.main.url(forResource: "websites", withExtension: "txt") {
            if let startWebsites = try? String(contentsOf: startWebsitesUrl) {
                websites = startWebsites.components(separatedBy: "\n")
            }
        }
        if websites.isEmpty {
            websites = ["google.com"]
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return websites.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Website", for: indexPath)
        cell.textLabel?.text = websites[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if #available(iOS 13.0, *) {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "WebController") as? ViewController {
                vc.websiteSelected = websites[indexPath.row]
                navigationController?.pushViewController(vc, animated: true)
                // Never do present vc at this stage, because nothing will be set up in the other View Controller as the set-up methods are only called when the view loads, but it does not load if you call present.
                // Also, the navigationController.pushViewController is what ACTUALLY PRESENTS the webview controller.
            }
        }
        else {
            // Fallback on earlier versions
        }
        
        
    }
}
