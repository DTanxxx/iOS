//
//  ViewController.swift
//  Guess_Flag
//
//  Created by David Tan on 12/09/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var titleToPresent = ""
    var shallContinue = true
    var highestScore = 0
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    var questionAsked = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) {
            [weak self] (granted, error) in
            if granted {
                self?.scheduleLocal()
                print("Yay!")
            } else {
                print("Uh oh")
            }
        }
        
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
        
        let defaults = UserDefaults.standard
        let savedScore = defaults.integer(forKey: "HScore")
        highestScore = savedScore
    }
    
    func askQuestions(alert: UIAlertAction! = nil) {
        button1.transform = .identity
        button2.transform = .identity
        button3.transform = .identity
        
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        if questionAsked == 10 {
            title = titleToPresent + "   Score: \(score)"
        } else {
            title = countries[correctAnswer].uppercased() + "   Score: \(score)"
        }
        
        if questionAsked == 10 {
            shallContinue = false
            return
        }
        
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        questionAsked += 1
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String
        
        if shallContinue {
            
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], animations: {
                sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: nil)
            
            titleToPresent = countries[correctAnswer].uppercased()
            if sender.tag == correctAnswer {
                title = "Correct"
                if questionAsked <= 10 {
                    score += 1
                    if score > highestScore {
                        highestScore = score
                        let defaults = UserDefaults.standard
                        defaults.set(highestScore, forKey: "HScore")
                        let ac = UIAlertController(title: "Nice!", message: "You have beaten your highest score so far.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "Continue", style: .default,  handler: { [weak self] _ in
                            self?.askQuestions()
                        }))
                        present(ac, animated: true)
                    }
                }
            } else {
                title = "Wrong! That's the flag of \(countries[sender.tag].uppercased())"
                if score > 0 && questionAsked <= 10 {
                    score -= 1
                }
            }
            if questionAsked == 10 {
                let ac = UIAlertController(title: title, message: "Your score is \(score).", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "End", style: .default, handler: askQuestions))
                present(ac, animated: true)
            } else {
                let ac = UIAlertController(title: title, message: "Your score is \(score).", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestions))
                present(ac, animated: true)
            }
        } else {
            let ac = UIAlertController(title: "Done", message: "You have finished the quiz.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "End", style: .default))
            present(ac, animated: true)
        }
    }
    
    @objc func displayScoreTapped() {
        let ac = UIAlertController(title: "Your highest score is \(highestScore)", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Return", style: .cancel))
        present(ac, animated: true)
    }
    
    func scheduleLocal() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        registerCategories()
        
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 30
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = "Guess flag"
        content.body = "Time to fucking play"
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let reminder = UNNotificationAction(identifier: "remind", title: "Remind me later", options: .init())
        let show = UNNotificationAction(identifier: "show", title: "Play", options: .foreground)
        let category = UNNotificationCategory(identifier: "alarm", actions: [show, reminder], intentIdentifiers: [])
        
        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case "remind":
            scheduleLocal()
        default:
            break
        }
        completionHandler()
    }
}



