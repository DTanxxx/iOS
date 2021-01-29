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
    
    var total: Int?
    var index: Int?
    var selectedImage: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let imageToLoad = selectedImage {
            imageView.image = UIImage(named: imageToLoad)
        }
        
        navigationItem.largeTitleDisplayMode = .never
        
        guard total != nil && index != nil
        else {
            title = selectedImage
            return
        }
        title = "Picture \(index!) of \(total!)"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    
    @objc func shareTapped() {
        
        guard let canvasSize = imageView.image?.size else { return }
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: canvasSize.width, height: canvasSize.height))
        let img = renderer.image { (ctx) in
            let storm = imageView.image
            storm?.draw(at: .zero)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 20), .paragraphStyle: paragraphStyle]
            
            let string = "From Storm Viewer"
            let attributedString = NSAttributedString(string: string, attributes: attrs)
            
            attributedString.draw(in: CGRect(x: 0, y: 0, width: 300, height: 300))
        }
            
        guard let imageToShare = img.jpegData(compressionQuality: 0.8) else {
            print("Initialisation of img has not yet completed")
            return
        }
        
        let vc = UIActivityViewController(activityItems: [imageToShare, selectedImage!], applicationActivities: [])
        // We create a UIActivityViewController, which is the iOS method of sharing content with other apps and services.
        // We're passing in [image]. This is the JPEG data that describes the user’s selected image, and iOS understands that it’s an image so it can post it to Twitter, Facebook, and other places.
        
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        // We tell iOS where the activity view controller should be anchored – where it should appear from.
        
        present(vc, animated: true)
    }
    
    
}
