//
//  TableViewController.swift
//  Extension
//
//  Created by David Tan on 5/01/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var dict: [String: String]?
    var array: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        dict = defaults.dictionary(forKey: "dict") as? [String: String] ?? [:]
        array = defaults.array(forKey: "array") as? [String] ?? []
        tableView.reloadData()
        print("If it prints the second time then it works")
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Scripts", style: .plain, target: nil, action: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard array?.count != 0 else { return 0 }
        return array!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard array?.count != 0 else { return UITableViewCell()}
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = array![indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard array?.count != 0 && dict?.count != 0 else { return }
        // instantiate vc
        if let vc = storyboard?.instantiateViewController(identifier: "script") as? ScriptViewController{
            let script = dict![array![indexPath.row]]
            vc.script = script
            vc.index = indexPath.row
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}
