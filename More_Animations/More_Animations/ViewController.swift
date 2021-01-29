//
//  ViewController.swift
//  More_Animations
//
//  Created by David Tan on 13/07/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var animator: UIViewPropertyAnimator!
    var slider: UISlider!
    var redBox: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSlider()
        createBox()
        createAnimation()
        createBarButtons()
        
        // call sliderChanged() every time the slider is dragged
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
    }
    
    fileprivate func createSlider() {
        slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(slider)
        
        slider.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        slider.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    }
    
    fileprivate func createBox() {
        // this method creates a 128x128 red box, centered vertically and part-way off the left edge of the screen
        redBox = UIView(frame: CGRect(x: -64, y: 0, width: 128, height: 128))
        redBox.translatesAutoresizingMaskIntoConstraints = false
        redBox.backgroundColor = UIColor.red
        redBox.center.y = view.center.y
        view.addSubview(redBox)
        
        // add a gesture recognizer to the red box that lets us detect when it's tapped
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(boxTapped))
        redBox.addGestureRecognizer(recognizer)
    }
    
    fileprivate func createAnimation() {
        guard let redBox = redBox else { return }
        
        // the animation will move the box from left to right, while spinning around and scaling down to nothing, over 2 seconds
        animator = UIViewPropertyAnimator(duration: 20, curve: .easeInOut, animations: {
            [unowned self, redBox] in
            redBox.center.x = self.view.frame.width
            redBox.transform = CGAffineTransform(rotationAngle: CGFloat.pi).scaledBy(x: 0.001, y: 0.001)
        })
        // in this following animation we create a spring effect without scaling
//        animator = UIViewPropertyAnimator(duration: 2, dampingRatio: 0.5, animations: {
//            [unowned self, redBox] in
//            redBox.center.x = self.view.frame.width
//            redBox.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
//        })
        
        animator.addCompletion { [unowned self] (position) in
            if position == .end {
                self.view.backgroundColor = UIColor.green
            } else {
                self.view.backgroundColor = UIColor.black
            }
        }
    }
    
    fileprivate func createBarButtons() {
        let play = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(playTapped))
        let flip = UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(reverseTapped))
        navigationItem.rightBarButtonItems = [play, flip]
    }
    
    @objc func playTapped() {
//        // if the animation has started
//        if animator.state == .active {
//            // if it's currently in motion
//            if animator.isRunning {
//                // pause it
//                animator.pauseAnimation()
//            } else {
//                // continue at the same speed
//                animator.continueAnimation(withTimingParameters: nil, durationFactor: 1)
//            }
//        } else {
//            // not started yet; start it now
//            animator.startAnimation()
//        }
        if animator.state == .active {
            animator.stopAnimation(false)  // if passed in 'false', it will mark the animation as stopped, but you still have the option of completing it later on; if passed in 'true', it will effectively destroy the animation, and your completion block will never be called
            animator.finishAnimation(at: .end)
        } else {
            animator.startAnimation()
//            UIView.animate(withDuration: 20, delay: 0, options: .allowUserInteraction, animations: { [unowned self] in
//                self.redBox.center.x = self.view.frame.width
//            }, completion: nil)
        }
    }
    
    @objc func reverseTapped() {
        animator.isReversed = true
    }
    
    @objc func boxTapped() {
        print("Box tapped!")
    }
    
    @objc func sliderChanged(_ sender: UISlider) {
        animator.fractionComplete = CGFloat(sender.value)
    }
}
// MARK: - pauseAnimation() and stopAnimation()
/*
 - when you animate a view from position A to position B, iOS actually immediately moves it to B, then the interface shows sliding animation
 - the model layer is immediately changed when an animation begins, while the presentation layer smoothly slides across the screen
 - therefore when you pause an animation it means you intend to continue it, so the model and presentation layers will remain different: the model will stay at the end point, and the presentation will stay wherever the view is on the screen right now
 - however when you stop an animation it means it's over, and the model layer will be updated to match the presentation layer
 - when you want to continue a paused animation, you can use continueAnimation() which allows you to also adjust the way the animation works -- you can specify new timing parameters, and a durationFactor parameter which is multiplied against the original animation duration to figure out how fast to make the animation when it continues
 */
