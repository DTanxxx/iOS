//
//  DetailViewController.swift
//  Project_1
//
//  Created by David Tan on 12/09/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    
    var picture: [Picture]?
    var total: Int?
    var index: Int?
    var selectedImage: Picture?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(selectedImage != nil, "No image selected")

        if let imageToLoad = selectedImage {
            imageView.image = UIImage(named: imageToLoad.name)
        }
        
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(clearView))
        
        guard total != nil && index != nil
        else {
            title = selectedImage?.name
            return
        }
        title = "Picture \(index!) of \(total!)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    
    @objc func clearView() {
        let vc = ViewController()
        let indexToUse = picture!.firstIndex(of: selectedImage!)
        picture![indexToUse!].intView = 0  // Compared to challenge 5, in this case the changes done to a property of an ELEMENT of the array here is saved in main view controller as well, so when you call performSegue the changes are saved and you don't have to load user default again in the segue method (in view controller).
        vc.pictures = picture!
        vc.save()
        self.performSegue(withIdentifier: "ABC", sender: self)
    }
    
    
}

