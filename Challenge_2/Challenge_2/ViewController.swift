//
//  ViewController.swift
//  Challenge_2
//
//  Created by David Tan on 14/09/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var flagsWithCap = [String]()
    var flagsWithNoCap = [String]()
    // This list has the names of flags only

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasSuffix("png") && item.contains("2x") == true {
                flagsWithCap.append(getTheName(item))
                flagsWithNoCap.append(getTheNameWithNoCap(item))
                
            }
        }
        
        title = "World Flags"
        navigationController?.navigationBar.prefersLargeTitles = true
        
       
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flagsWithCap.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Flag", for: indexPath)
        cell.textLabel?.text = flagsWithCap[indexPath.row]
        cell.imageView?.image = UIImage(named: flagsWithNoCap[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "FlagEnlarged") as? DetailViewController {
            
            vc.flagName = flagsWithNoCap[indexPath.row]
            vc.flagNameForShare = flagsWithCap[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func getTheNameWithNoCap(_ flagName:String) -> String {
        var index = 0
        for letter in flagName {
            if letter == "@" {
                break
            }
            index += 1
        }
        let name = flagName[0...index-1] // up to but not including "@" index and all lower case
        return name
    }
    
    func getTheName(_ flagName:String) -> String {
        var actualName = ""
        var index = 0
        for letter in flagName {
            if letter == "@" {
                break
            }
            index += 1
        }
        let name = flagName[0...index-1] // up to but not including "@" index and all lower case
        if name != "us" && name != "uk" {
            let letter = name[0...0].uppercased()
            actualName = letter + name[1...index-1]
        }
        else {
            actualName = name.uppercased()
        }
        
        return actualName
    }
    
    
}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}
