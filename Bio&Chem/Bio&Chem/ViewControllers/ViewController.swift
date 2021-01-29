//
//  ViewController.swift
//  Bio&Chem
//
//  Created by David Tan on 6/02/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import CoreGraphics

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var skyBackgroundImage: UIImageView!
    @IBOutlet var containerViewBio: UIView!
    @IBOutlet var containerViewChem: UIView!
    
    var bioImageInContainer: UIImageView!
    var chemImageInContainer: UIImageView!
    var recogniser: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = Bundle.main.path(forResource: "vector_sky", ofType: "jpg") {
            skyBackgroundImage.image = UIImage(contentsOfFile: path)
        }
        
        createImage(subject: "BIOLOGY")
        createImage(subject: "CHEMISTRY")
        
        createLabel(subject: "BIOLOGY")
        createLabel(subject: "CHEMISTRY")

        // Recognisers
        recogniser = UITapGestureRecognizer(target: self, action: #selector(instantiateVC))
        recogniser.delegate = self
        containerViewBio.addGestureRecognizer(recogniser)
        let recogniser2 = UITapGestureRecognizer(target: self, action: #selector(instantiateVC))
        recogniser2.delegate = self
        containerViewChem.addGestureRecognizer(recogniser2)
        
        
    }
    
    func createLabel(subject: String) {
        
        let label = UILabel()
        label.text = subject
        label.textAlignment = .center
        label.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.4)
        label.frame = CGRect(x: 0, y: 130, width: 185, height: 40)
        
        if subject == "BIOLOGY" {
            label.textColor = UIColor(red: 0.8, green: 0.8, blue: 0, alpha: 1.0)
            label.font = .boldSystemFont(ofSize: 28)
            containerViewBio.addSubview(label)
        } else {
            label.textColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
            label.font = .boldSystemFont(ofSize: 26)
            containerViewChem.addSubview(label)
        }
    }
    
    func createImage(subject: String) {
        switch subject {
        case "BIOLOGY":
            let imagePlaceholder = UIImage(named: "bee")
                
            bioImageInContainer = UIImageView(frame: CGRect(x: 0, y: 0, width: 180, height: 130))
            
            containerViewBio.clipsToBounds = true
            bioImageInContainer.image = imagePlaceholder
            bioImageInContainer.clipsToBounds = true
            containerViewBio.layer.cornerRadius = 30
            containerViewBio.addSubview(bioImageInContainer)
            containerViewBio.layer.borderColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0).cgColor
            containerViewBio.layer.borderWidth = 5
        case "CHEMISTRY":
            let imagePlaceholder = UIImage(named: "atom")
                       
            chemImageInContainer = UIImageView(frame: CGRect(x: 0, y: 0, width: 180, height: 130))
            containerViewChem.clipsToBounds = true
            chemImageInContainer.image = imagePlaceholder
            chemImageInContainer.clipsToBounds = true
            containerViewChem.layer.cornerRadius = 30
            containerViewChem.addSubview(chemImageInContainer)
            containerViewChem.layer.borderColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0).cgColor
            containerViewChem.layer.borderWidth = 5
        default:
            break
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @objc func instantiateVC() {
        if containerViewBio.frame.contains(recogniser.location(in: view)) {
            if let vc = storyboard?.instantiateViewController(identifier: "selection") as? SelectionViewController {
                vc.isBio = true
                navigationController?.pushViewController(vc, animated: true)
            }
//            if let vc = storyboard?.instantiateViewController(identifier: "Topics") as? TopicViewController {
//                navigationController?.pushViewController(vc, animated: true)
//            }
        } else {
            if let vc = storyboard?.instantiateViewController(identifier: "selection") as? SelectionViewController {
                vc.isBio = false
                navigationController?.pushViewController(vc, animated: true)
            }
//            if let vc = storyboard?.instantiateViewController(identifier: "Topic2") as? Topic2TableViewController {
//                navigationController?.pushViewController(vc, animated: true)
//            }
        }
    }
    
    

}

