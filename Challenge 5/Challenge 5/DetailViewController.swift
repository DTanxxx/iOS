//
//  DetailViewController.swift
//  Challenge 5
//
//  Created by David Tan on 9/11/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    var photoSelected: Photo?
    var caption: String?
    var photos2: [Photo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imageToLoad = photoSelected {
            let paths = getDocumentsDirectory().appendingPathComponent(imageToLoad.filename)
            imageView.image = UIImage(contentsOfFile: paths.path)
        }
        if let title1 = caption {
            title = title1
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(deletePhoto))
    }
    
    func getDocumentsDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    @objc func deletePhoto() {
        let vc = ViewController()  // Note that vc here is an object, so changes done to this object does not influence the actual view controller class ie properties do not change.
        if let photo = photoSelected {
            let indexToDel = photos2!.firstIndex(of: photo)
            let _ = photos2!.remove(at: indexToDel!)  // Compared to project 1, in this case the changes done to the ARRAY ITSELF here is NOT saved in main view controller, so when you call performSegue the changes are not saved and you will have to load user default again in the segue method (in view controller).
            vc.photos = photos2!
            vc.save()
            self.performSegue(withIdentifier: "ABC", sender: self)
        }
    }

    
}
