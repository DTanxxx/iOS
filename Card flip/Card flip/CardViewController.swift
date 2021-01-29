//
//  CardViewController.swift
//  Card flip
//
//  Created by David Tan on 6/03/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {
    
    weak var delegate: ViewController!
    
    var front: UIImageView!
    var back: UIImageView!
    
    var isCorrect = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. Give the view a precise size of 100x140
        view.bounds = CGRect(x: 0, y: 0, width: 100, height: 140)
        // 2. Add two image views, one for the card back and one for the front.
        front = UIImageView(image: UIImage(named: "cardBack"))
        back = UIImageView(image: UIImage(named: "cardBack"))
        
        view.addSubview(front)
        view.addSubview(back)
        // 3. Set the front image view to be hidden by default.
        front.isHidden = true
        // 4. Set the back image view to have an alpha value of 0 by default, fading up to 1 with an animation.
        back.alpha = 0
        
        UIView.animate(withDuration: 0.2) {
            self.back.alpha = 1
        }
        
        // tap detection using UITapGestureRecogniser instead of touchesBegan() because we want the 'hoax effect' where you run your finger over the cards to 'feel' for the star -- using touchesBegan() will cause problems
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(tap)
        
        // start the wiggle
        perform(#selector(wiggle), with: nil, afterDelay: 1)
    }
    
    @objc func cardTapped() {
        delegate.cardTapped(self)
        // we are giving the ViewController the control for handling card taps because we want to make sure that only one card responds to touch at a time (if user taps two cards at the same time we only want one to flip)
    }
    
    @objc func wasntTapped() {
        // make the card zoom down and fade away
        UIView.animate(withDuration: 0.7) {
            self.view.transform = CGAffineTransform(scaleX: 0.00001, y: 0.00001)
            self.view.alpha = 0
        }
    }
    
    @objc func wasTapped() {
        UIView.transition(with: view, duration: 0.7, options: [.transitionFlipFromRight], animations: {
            [unowned self] in
            self.back.isHidden = true
            self.front.isHidden = false
        })
        // transition(with:) method takes a view to operate on as it first parameter, and all the animations you perform meed to be done on subviews of this container view (in this case, front and back image views are the subviews)
        // .transitionFlipFromRight creates the flip effect
    }
    
    @objc func wiggle() {
        if Int.random(in: 0...3) == 1 {
            UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction, animations: {
                // scale the card back up by 1%
                self.back.transform = CGAffineTransform(scaleX: 1.01, y: 1.01)
            }) { _ in
                // after animation has completed, return the card back to original size
                self.back.transform = CGAffineTransform.identity
            }
            
            // make this method call itself
            perform(#selector(wiggle), with: nil, afterDelay: 8)
        } else {
            // make this method call itself
            perform(#selector(wiggle), with: nil, afterDelay: 2)
        }
    }
    
    
}
