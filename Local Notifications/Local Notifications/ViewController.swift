//
//  ViewController.swift
//  Local Notifications
//
//  Created by David Tan on 30/12/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
    }
    
    @objc func registerLocal() {
        // Ask for user's permission to post messages to lock screen.
        let center = UNUserNotificationCenter.current()
        
        // Request an alert which asks user to adjust setting.
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("Uh oh")
            }
        }
    }
    
    @objc func scheduleLocal() {
        // Configure all the data needed to schedule a notification: content, trigger (when to show it), request (combination of content and trigger).
        // Request is split into two smaller components because they are interchangeable--eg the trigger, can be either calendar-based, interval-based, or geofence (location-based).
        
        registerCategories()
        
        let center = UNUserNotificationCenter.current()
        
        //center.removeAllPendingNotificationRequests()
        
        // In order to do calendar-based, we need to use DateComponents object.
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 30
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        // So notification triggers everyday at 10:30am
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        // For the content, we use the UNMutableNotificationContent class.
        let content = UNMutableNotificationContent()
        content.title = "Title goes here"
        content.body = "Main text goes here"
        content.categoryIdentifier = "alarm"  // a text string that identifies a type of alert (not a built-in type, but like an identifier string eg storyboard identifier)
        content.userInfo = ["customData": "fizzbuzz"]  // to attach custom data to the notification
        content.sound = UNNotificationSound.default  // to specify a sound
        
        // Each notification requires an unique identifier.
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self  // "any alert-based messages that get sent will be routed to our view controller to be handled"
        
        let reminder = UNNotificationAction(identifier: "remind", title: "Remind me later", options: .init())
        let show = UNNotificationAction(identifier: "show", title: "Tell me more...", options: .foreground)  // creates a button
        // the options parameter specifies what happens when user taps the button, in this case the user gets directed to the app
        let category = UNNotificationCategory(identifier: "alarm", actions: [show, reminder], intentIdentifiers: [])  // groups button(s) together under a single identifier
        // the identifier here must be the same as the one set for content.categoryIdentifier
        
        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // pull out the buried userInfo dictionary
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")
            let ac = UIAlertController(title: "You are in", message: nil, preferredStyle: .alert)
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // the user swiped to unlock
                ac.addAction(UIAlertAction(title: "You swiped to unlock.", style: .default))
            
            // this enum case "show" is defined above in the initialiser of UNNotificationAction(identifier:)
            // the identifier in initialising a notification action gets appended to the switch cases of response.actionIdentifier
            case "show":
                // the user tapped our "show more info..." button
                ac.addAction(UIAlertAction(title: "You pressed button to unlock.", style: .default))
                
            case "remind":
                scheduleLocal()
                return
                
            default:
                break
            }
            
            present(ac, animated: true)
        }
        
        // you must call the completion handler when you're done
        completionHandler()
    }
    
    // TIPS FOR TESTING NOTIFICATIONS:
    // 1. You can cancel pending notifications--ie notifications you have schedules that have yet to be delivered because their trigger hasn't been met. For example if you press schedule button 50 times, you don't want 50 notifications popping up at the same time, therefore you would cancel pending notifications in the first line of code, then carry on with the rest ie creating a notificatoin request.
    // 2. You would want to use interval trigger to test rather than calendar trigger.

}

