//
//  ViewController.swift
//  Guess_Flag
//
//  Created by David Tan on 12/09/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    var questionAsked = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countries += ["estonia", "france", "germany", "ireland",
                      "italy", "monaco", "nigeria", "poland", "russia", "spain",
                      "uk", "us"]
        
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
        
        askQuestions()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(displayScoreTapped))
    }
    
    func askQuestions(alert: UIAlertAction! = nil) {
        if questionAsked == 10 {
            return
        }
        
        countries.shuffle()
        
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        correctAnswer = Int.random(in: 0...2)
        title = countries[correctAnswer].uppercased() + "   Score: \(score)"
        
        questionAsked += 1
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String
        
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
        }
        else {
            title = "Wrong! That's the flag of \(countries[sender.tag].uppercased())"
            if score > 0 {
                score -= 1
            }
        }
        
        let ac = UIAlertController(title: title, message: "Your score is \(score).", preferredStyle: .alert)
        if questionAsked == 10 {
            ac.addAction(UIAlertAction(title: "End", style: .default, handler: askQuestions))
        }
        else{
            ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestions))
        }
        present(ac, animated: true)
    }
    
    @objc func displayScoreTapped() {
        let ac = UIAlertController(title: "Your current score is \(score)", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Return", style: .cancel))
        present(ac, animated: true)
    }
}

