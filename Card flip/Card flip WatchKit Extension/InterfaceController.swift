//
//  InterfaceController.swift
//  Card flip WatchKit Extension
//
//  Created by David Tan on 6/03/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var welcomeText: WKInterfaceLabel!
    @IBOutlet var hideButton: WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // set up the WCSession
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func hideWelcomeText() {
        // hide label and button when tapped
        welcomeText.setHidden(true)
        hideButton.setHidden(true)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // make the watch vibrate when it receives a message from the app
        WKInterfaceDevice().play(.click)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
}
