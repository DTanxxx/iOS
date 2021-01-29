//
//  ViewController.swift
//  Project_1
//
//  Created by David Tan on 12/09/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var pictures = [Picture]()
    var viewCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Adding a bar button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(recommendedTapped))
        
        let defaults = UserDefaults.standard
        if let savedPictures = defaults.object(forKey: "pictures") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                pictures = try jsonDecoder.decode([Picture].self, from: savedPictures)
            } catch {
                print("Failed to load picture counts.")
            }
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let fm = FileManager.default
            // Declares a constant called fm and assigns it the value returned by FileManager.default. This is a data type that lets us work with the filesystem, and in our case we will be using it to look for files
            
            let path = Bundle.main.resourcePath!
            // Declares a constant called path that is set to the resource path of our app's bundle. Remember, a bundle is a directory containing our compiled program and all our assets. So, this line says, "tell me where I can find all those images I added to my app"
            
            let items = try! fm.contentsOfDirectory(atPath: path)
            // Declares a third constant called items that is set to the contents of the directory at a path.  The items constant will be an array of strings containing filenames.
            
            for item in items {
                if item.hasPrefix("nssl") {
                    // upload the image
                    let picture = Picture(name: item, viewInt: self!.viewCount)
                    self?.pictures.append(picture)
                }
            }
            self?.pictures.sort()
            self?.save()
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
            
            print(self!.pictures)
        }
        
        //performSelector(inBackground: #selector(retrieveImages), with: nil)
    }
    
    /*@objc func retrieveImages() {
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
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
    }*/
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // The 'section' part is there because table views can be split into sections, like the way the Contacts app separates names by first letter. We only have one section, so we can ignore this number.
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text = pictures[indexPath.row].name
        cell.detailTextLabel?.text = pictures[indexPath.row].viewCount
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        pictures[indexPath.row].intView += 1
        tableView.reloadData()
        save()
        
        // 1: try loading the "Detail" view controller and typecasting it to be DetailViewController
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            
            // 2: success! Set its selectedImage property
            vc.selectedImage = pictures[indexPath.row]
            vc.total = pictures.count
            vc.index = indexPath.row + 1
            vc.picture = pictures
            
             // 3: now push it onto the navigation controller
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func recommendedTapped() {
        let recommend = "Download this APP now!"
        let vc = UIActivityViewController(activityItems: [recommend], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(pictures) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "pictures")
        } else {
            print("Failed to save picture counts.")
        }
    }
    
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

}

