//
//  ViewController.swift
//  Project_1
//
//  Created by David Tan on 12/09/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var pictures = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let fm = FileManager.default
        // Declares a constant called fm and assigns it the value returned by FileManager.default. This is a data type that lets us work with the filesystem, and in our case we will be using it to look for files
        
        let path = Bundle.main.resourcePath!
        // Declares a constant called path that is set to the resource path of our app's bundle. Remember, a bundle is a directory containing our compiled program and all our assets. So, this line says, "tell me where I can find all those images I added to my app"
        
        let items = try! fm.contentsOfDirectory(atPath: path)
        // Declares a third constant called items that is set to the contents of the directory at a path.  The items constant will be an array of strings containing filenames.
        
        for item in items {
            if item.hasPrefix("nssl") {
                // upload the image
                pictures.append(item)
            }
        }
        pictures.sort()
        
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // The 'section' part is there because table views can be split into sections, like the way the Contacts app separates names by first letter. We only have one section, so we can ignore this number.
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text = pictures[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 1: try loading the "Detail" view controller and typecasting it to be DetailViewController
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            
            // 2: success! Set its selectedImage property
            vc.selectedImage = pictures[indexPath.row]
            vc.total = pictures.count
            vc.index = indexPath.row + 1
            
             // 3: now push it onto the navigation controller
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}

