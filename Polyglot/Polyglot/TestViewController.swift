//
//  TestViewController.swift
//  Polyglot
//
//  Created by David Tan on 19/05/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet var prompt: UILabel!
    @IBOutlet var stackView: UIStackView!
    
    var words: [String]!
    var questionCounter = 0  // stores which question is currently being asked
    var showingQuestion = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(nextTapped))
        words.shuffle()
        title = "TEST"
        
        // hide the stack view and scale it down to 80% when the test view first loads
        stackView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        stackView.alpha = 0
    }
    
    // used to ask the initial question -> it will wait until the navigation controller's push animation has finished fully before starting
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // the view was just shown - start asking a question now
        askQuestion()
    }
    
    // this method will either show the answer or prepare to show the next question depending on the value of showingQuestion
    @objc func nextTapped() {
        // move between showing question and answer
        showingQuestion = !showingQuestion
        
        if showingQuestion {
            // we should be showing the question - reset!
            prepareForNextQuestion()
        } else {
            // we should be showing the answer - show it now, and set the color to be green
            prompt.text = words[questionCounter].components(separatedBy: "::")[0]
            prompt.textColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1)
        }
    }
    
    // used to advance questionCounter and set up the question prompt
    func askQuestion() {
        // move the question counter one place
        questionCounter += 1
        if questionCounter == words.count {
            // wrap it back to 0 if we've gone beyond the size of the array
            questionCounter = 0
        }
        
        // pull out the French word at the current question position
        prompt.text = words[questionCounter].components(separatedBy: "::")[1]
        
        // make the stack view bounce each question in
        // we use UIViewPropertyAnimator() object for the animation
        let animation = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.5) {
            self.stackView.alpha = 1
            self.stackView.transform = CGAffineTransform.identity
        }
        
        // after you have configured the animator object, call startAnimation() to animate
        animation.startAnimation()
    }
    
    // used to reset the UI
    func prepareForNextQuestion() {
        // animate the answer away ready to be replaced with a new question
        let animation = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
            [unowned self] in
            self.stackView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.stackView.alpha = 0
        }
        
        // we want to execute the set text color code and askQuestion() only after the animation is finished -> we use the animation.addCompletion to pass in a closure
        animation.addCompletion { [unowned self] (position) in
            // reset the prompt back to black
            self.prompt.textColor = UIColor.black
            
            // proceed with the next question
            self.askQuestion()
        }
        
        animation.startAnimation()
    }
    
}
