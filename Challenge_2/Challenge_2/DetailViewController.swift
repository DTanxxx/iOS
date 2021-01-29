//
//  DetailViewController.swift
//  Challenge_2
//
//  Created by David Tan on 16/09/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    var flagName: String?
    var flagNameForShare: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        if let imageToLoad = flagName {
            imageView.image = UIImage(named: imageToLoad)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))

    }
    
    @objc func shareTapped() {
        if let image = imageView.image?.jpegData(compressionQuality: 0.8) {
            let vc = UIActivityViewController(activityItems: [image, flagNameForShare!], applicationActivities: [])
            vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            present(vc, animated: true)
        }
    }
    

   
}
