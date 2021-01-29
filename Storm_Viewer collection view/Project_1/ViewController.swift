//
//  ViewController.swift
//  Project_1
//
//  Created by David Tan on 12/09/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController {
    
    var pictures = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                    self?.pictures.append(item)
                }
            }
            self?.pictures.sort()
            
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
            
            print(self!.pictures)
        }
        
        //performSelector(inBackground: #selector(retrieveImages), with: nil)
        
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Adding a bar button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(recommendedTapped))
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
        collectionView.performSelector(onMainThread: #selector(UICollectionView.reloadData), with: nil, waitUntilDone: false)
    }*/
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Image", for: indexPath) as? ImageCell else {fatalError("shit")}
        cell.picture.text = pictures[indexPath.row]
        cell.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.layer.borderWidth = 2
        cell.layer.cornerRadius = 7
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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
    
    @objc func recommendedTapped() {
        let recommend = "Download this APP now!"
        let vc = UIActivityViewController(activityItems: [recommend], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }

}

