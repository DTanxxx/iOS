//
//  ViewController.swift
//  Animation
//
//  Created by David Tan on 21/11/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var imageView: UIImageView!
    var currentAnimation = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView = UIImageView(image: UIImage(named: "penguin"))
        imageView.center = CGPoint(x: 512, y: 384)
        view.addSubview(imageView)
    }

    // Note that because we want to show and hide the “Tap” button, we need to make the sender parameter to that method be a UIButton rather than Any.
    @IBAction func tapped(_ sender: UIButton) {
        sender.isHidden = true
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], animations: {
            // we don’t need to use [weak self] because there’s no risk of strong reference cycles here – the closures passed to animate(withDuration:) method will be used once then thrown away
            switch self.currentAnimation {
            case 0:
                // make the image twice its default size
                self.imageView.transform = CGAffineTransform(scaleX: 2, y: 2)
                
            case 1:
                // clears our view of any pre-defined transform, resetting any changes that have been applied by modifying its transform property
                self.imageView.transform = .identity
                
            case 2:
                // translate the image
                self.imageView.transform = CGAffineTransform(translationX: -256, y: -256)
                
            case 3:
                self.imageView.transform = .identity
                
            // Time for rotation
            case 4:
                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                
            case 5:
                self.imageView.transform = .identity
                
            case 6:
                self.imageView.alpha = 0.1  // transparency change
                self.imageView.backgroundColor = UIColor.green  // change color
                
            case 7:
                self.imageView.alpha = 1
                self.imageView.backgroundColor = UIColor.clear
            
            default:
                // the default case will handle any values we don't explicitly catch.
                break
            }
        }) { finished in
            sender.isHidden = false
        }
        
        currentAnimation += 1
        
        if currentAnimation > 7 {
            currentAnimation = 0
        }
    }
    
    
    
}

