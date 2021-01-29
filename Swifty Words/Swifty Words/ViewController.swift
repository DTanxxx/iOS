//
//  ViewController.swift
//  Swifty Words
//
//  Created by David Tan on 17/10/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var pleaseWait: UILabel!
    
    var clueString = ""  // stores all the level's clues
    var solutionString = ""  // stores how many letters each answer is (in the same position as the clues)
    var letterBits = [String]()  // stores all letter groups e.g. HA, UNT, ED
    
    var cluesLabel: UILabel!
    var answersLabel: UILabel!
    var currentAnswer: UITextField!
    var scoreLabel: UILabel!
    var letterButtons = [UIButton]()
    
    var activatedButtons = [UIButton]()
    var solutions = [String]()
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
        // By using this property observer we update the score label whenever the score value was changed.
    }
    var level = 1
    var counter = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        performSelector(inBackground: #selector(loadLevel), with: nil)
    }
    
    @objc func letterTapped(_ sender: UIButton) {
        // a safety check to read the title from the tapped button, or exit if it didn’t have one for some reason
        guard let buttonTitle = sender.titleLabel?.text else { return }
        
        // append the button title to the player’s current answer
        currentAnswer.text = currentAnswer.text?.appending(buttonTitle)
        
        // append the button to the activatedButtons array
        activatedButtons.append(sender)
        // This activatedButtons array is being used to hold all buttons that the player has tapped before submitting their answer. This is important because we're hiding each button as it is tapped, so if the user taps "Clear" we need to know which buttons are currently in use so we can re-show them.
        
        // fade the button
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
            sender.alpha = 0.0
        }, completion: nil)
    }
    
    @objc func clearTapped(_ sender: UIButton) {
        currentAnswer.text = ""
        
        for btn in activatedButtons {
            btn.alpha = 1.0
        }
        
        activatedButtons.removeAll()
    }
    
    @objc func submitTapped(_ sender: UIButton) {
        guard let answerText = currentAnswer.text else { return }
        
        if let solutionPosition = solutions.firstIndex(of: answerText) {
            counter += 1
            activatedButtons.removeAll()
            
            // The next three lines replace the answer label's text at a particular position with the solution word.
            var splitAnswers = answersLabel.text?.components(separatedBy: "\n")
            splitAnswers?[solutionPosition] = answerText
            answersLabel.text = splitAnswers?.joined(separator: "\n")
            
            currentAnswer.text = ""
            score += 1
            
            if counter == 7 {
                let ac = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: levelUp))
                present(ac, animated: true)
            }
        }
        else {
            if score > 0 {
                score -= 1
            }
            let ac = UIAlertController(title: "Oopsies!", message: "This is a wrong guess...Try again!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Return", style: .default))
            present(ac, animated: true)
        }
    }
    
    func levelUp(action: UIAlertAction) {
        level += 1
        solutions.removeAll(keepingCapacity: true)
        counter = 0
        
        performSelector(inBackground: #selector(loadLevel), with: nil)
        
        for btn in letterButtons {
            btn.alpha = 1.0
        }
    }
    
    // loadView() is used to create our custom view, while viewDidLoad() is used to initialise some settings AFTER the view has loaded, so if we want to create our own view we need to use loadView().
    override func loadView() {
        // First we create the main view itself as a big and white empty space.
        view = UIView()
        view.backgroundColor = .white
        
        // Next, let’s create and add the score label.
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: 0"
        view.addSubview(scoreLabel)  // UILabel is a subclass of UIView, hence it can be used here.
        
        // Next we’re going to add the clues and answers labels. This will involve similar code to the score label, except we’re going to set two extra properties: font and numberOfLines.
        cluesLabel = UILabel()
        cluesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        cluesLabel.translatesAutoresizingMaskIntoConstraints = false
        cluesLabel.font = UIFont.systemFont(ofSize: 24)
        cluesLabel.text = "CLUES"
        cluesLabel.numberOfLines = 0  // “as many lines as it takes.”
        view.addSubview(cluesLabel)
        
        answersLabel = UILabel()
        answersLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        answersLabel.translatesAutoresizingMaskIntoConstraints = false
        answersLabel.font = UIFont.systemFont(ofSize: 24)
        answersLabel.text = "ANSWERS"
        answersLabel.numberOfLines = 0
        answersLabel.textAlignment = .right
        view.addSubview(answersLabel)
        
        // Next we are going to add an UITextField that will show the user’s answer as they are building it.
        currentAnswer = UITextField()
        currentAnswer.translatesAutoresizingMaskIntoConstraints = false
        currentAnswer.placeholder = "Tap letters to guess"  // This produces a good cosmetic effect.
        currentAnswer.textAlignment = .center
        currentAnswer.font = UIFont.systemFont(ofSize: 44)
        currentAnswer.isUserInteractionEnabled = false  // Setting this to false stops the user from activating the text field and typing into it.
        view.addSubview(currentAnswer)
        
        // Below the text field we’re going to add two buttons: one for the user to submit their answer (when they’ve entered all the letters they want), and one to clear their answer so they can try something else.
        let submit = UIButton(type: .system)
        submit.translatesAutoresizingMaskIntoConstraints = false
        submit.setTitle("SUBMIT", for: .normal)
        view.addSubview(submit)
        submit.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)  // .touchUpInside means the user pressed down on the button and lifted their touch while it was still inside. So, altogether this line means “when the user presses the submit button, call submitTapped() on the current view controller.”

        let clear = UIButton(type: .system)
        clear.translatesAutoresizingMaskIntoConstraints = false
        clear.setTitle("CLEAR", for: .normal)
        view.addSubview(clear)
        clear.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        // Note: we don’t need to store these buttons as properties on the view controller, because we don’t need to adjust them later
        
        // Now let's create another UIView that will act as a container for the 20 buttons.
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.layer.borderWidth = 1
        buttonsView.layer.borderColor = UIColor.lightGray.cgColor
        view.addSubview(buttonsView)
        
        // NSLayoutConstraint.activate() method accepts an array of constraints and puts them all together at once, so that we don't have to set multiple constraints to .isActive = true
        NSLayoutConstraint.activate([scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor), scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            // pin the top of the clues label to the bottom of the score label
            cluesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            
            // pin the leading edge of the clues label to the leading edge of our layout margins, adding 100 for some space
            cluesLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
            
            // make the clues label 60% of the width of our layout margins, minus 100
            cluesLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -100),
            
            // also pin the top of the answers label to the bottom of the score label
            answersLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            
            // make the answers label stick to the trailing edge of our layout margins, minus 100
            answersLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
            
            // make the answers label take up 40% of the available space, minus 100
            answersLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -100),
            
            // make the answers label match the height of the clues label
            answersLabel.heightAnchor.constraint(equalTo: cluesLabel.heightAnchor),
            
            // set the current answer text field to the middle of the view
            currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // set width to 50% of view's width
            currentAnswer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            
            // place text field below the clues label, with 20 points of spacing
            currentAnswer.topAnchor.constraint(equalTo: cluesLabel.bottomAnchor, constant: 20),
            
            // set submit button's top anchor to text field's bottom anchor
            submit.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor),
            
            // set submit button's X position 100 points to the left
            submit.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            
            // set button's height to 44 points
            submit.heightAnchor.constraint(equalToConstant: 44),
            
            // set clear button's Y position the same as submit button's Y
            clear.centerYAnchor.constraint(equalTo: submit.centerYAnchor),
            
            // set clear button's X position 100 points to the right
            clear.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
            
            // set height to 44 points
            clear.heightAnchor.constraint(equalToConstant: 44),
            
            // set width and height of buttonsView
            buttonsView.widthAnchor.constraint(equalToConstant: 750),
            buttonsView.heightAnchor.constraint(equalToConstant: 320),
            
            // centre it horizontally
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // set its top anchor to be 20 points below the submit button
            buttonsView.topAnchor.constraint(equalTo: submit.bottomAnchor, constant: 20),
            
            // pin it to the bottom of the layout margin, with 20 points space
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
            
        ])
        
        // set some values for the width and height of each button
        let width = 150
        let height = 80
        
        // create 20 buttons as a 4x5 grid
        for row in 0..<4 {
            for col in 0..<5 {
                // create a new button
                let letterButton = UIButton(type: .system)  // We’re not going to set translatesAutoresizingMaskIntoConstraints to false for these buttons, which means we can give them a specific position and size and have UIKit figure out the constraints for us.
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                
                // give the button some temporary text so we can see it on-screen
                letterButton.setTitle("WWW", for: .normal)
                
                // calculate the frame of this button using its column and row
                let frame = CGRect(x: col * width, y: row * height, width: width, height: height)
                letterButton.frame = frame
                
                // add it to the buttons view
                buttonsView.addSubview(letterButton)
                
                // and also to our letterButtons array
                letterButtons.append(letterButton)
                
                letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
            }
        }
    }
    
    @objc func loadLevel() {
        
        if let levelFileURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") {
            if let levelContents = try? String(contentsOf: levelFileURL) {
                var lines = levelContents.components(separatedBy: "\n")  // produces an array of lines
                lines.shuffle()
                
                for (index, line) in lines.enumerated() {  // by using enumerated we also know where each item was in the array so we can use that information in our clue string. enumerated() will place the item into the line variable and its position into the index variable.
                    let parts = line.components(separatedBy: ":")
                    let answer = parts[0]
                    let clue = parts[1]
                    clueString += "\(index + 1). \(clue)\n"
                    
                    let solutionWord = answer.replacingOccurrences(of: "|", with: "")  // .replacingOccurrences(of:)--we're asking it to replace all instances of | with an empty string, so HA|UNT|ED will become HAUNTED
                    solutionString += "\(solutionWord.count) letters\n"
                    solutions.append(solutionWord)
                    
                    let bits = answer.components(separatedBy: "|")
                    letterBits += bits
                }
            }
        }
        performSelector(onMainThread: #selector(setUpLevel), with: nil, waitUntilDone: false)
    }
    
    @objc func setUpLevel() {
        
        cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
        answersLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)
        // To get rid of the "\n" newline at the end of the clueString and solutionString. It does not erase the newline characters within the string because, as I have mentioned, they are WITHIN the string; only spaces and newlines at the start and the end of a string get erased.
        
        letterBits.shuffle()
        
        if letterBits.count == letterButtons.count {
            for i in 0 ..< letterButtons.count {
                letterButtons[i].setTitle(letterBits[i], for: .normal)
            }
        }
        
        // Now clear all the strings and letter bits
        clueString = ""
        solutionString = ""
        letterBits = []
    }
}






