//
//  ViewController.swift
//  Keychain_Biometrics_stuff
//
//  Created by David Tan on 14/03/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {
    
    @IBOutlet var secret: UITextView!
    
    var doneBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nothing to see here"
        
        let notificationCenter = NotificationCenter.default
        // notification center for when keyboard hides
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        // notification center for when keyboard changes frame
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        // notification for when the app has stopped being active (then we want to reset the app so that it is back to locked stage)
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    // MARK: - keyboard adjustment code
    
    @objc func adjustForKeyboard(notification: NSNotification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    // MARK: - load and save secret message
    
    func unlockSecretMessage() {
        // show the text view
        secret.isHidden = false
        title = "Secret stuff!"
        
        // load the keychain's text into it
        secret.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? ""
        
        // show the Done bar button
        doneBarButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(saveSecretMessage))
        navigationItem.rightBarButtonItem = doneBarButton
    }
    
    @objc func saveSecretMessage() {
        // write the text view's text to the keychain
        guard secret.isHidden == false else { return }  // we want to execute this code only if the text view is visible, otherwise if a save happens before the app is unlocked then it will overwrite the saved text
        
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        secret.resignFirstResponder()  // resignFirstResponder() tells our text view that we are finished editing it, so the keyboard can be hidden
        
        // hide the text view
        secret.isHidden = true
        title = "Nothing to see here"
        
        // remove the Done bar button
        navigationItem.rightBarButtonItem = nil
    }
    
    // MARK: - button action
    
    @IBAction func authenticateTapped(_ sender: Any) {
        // check if there is a password stored somewhere in keychain
        let password = KeychainWrapper.standard.string(forKey: "Password") ?? ""
        // if no password, present an alert controller to prompt for password (include a message in controller that says: "This is for in case of failed biometric authentication.")
        if password == "" {
            let ac = UIAlertController(title: "Enter a new password", message: "This is for in case of absence of/failed biometric authentication.", preferredStyle: .alert)
            ac.addTextField()
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                [unowned self] (_) in
                // store the password from the textfield
                if let password = ac.textFields![0].text {
                    KeychainWrapper.standard.set(password, forKey: "Password")
                    // call unlock message and return the method
                    self.unlockSecretMessage()
                }
            }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
            return
        }
        
        let context = LAContext()
        var error: NSError?
        
        // 1. Check whether the device is capable of supporting biometric authentication – that the hardware is available and is configured by the user.
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // 2. If so, request that the biometry system begin a check now, giving it a string containing the reason why we're asking. For Touch ID the string is written in code; for Face ID the string is written into our Info.plist file.
            let reason = "Identify yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] (success, authenticationError) in
                 // when we're told whether Touch ID/Face ID was successful or not, it might not be on the main thread => this means we need to use async() to make sure we execute any UI code on the main thread
                DispatchQueue.main.async {
                    // 3. If we get success back from the authentication request it means this is the device's owner so we can unlock the app, otherwise we show a failure message.
                    if success {
                        self?.unlockSecretMessage()
                    } else {
                        let passwordAC = UIAlertController(title: "Biometric authentication failed", message: "Please enter your password:", preferredStyle: .alert)
                        passwordAC.addTextField()
                        passwordAC.addAction(UIAlertAction(title: "Enter", style: .default, handler: { [unowned self] (_) in
                            // retrieve the text from textfield
                            let entered = passwordAC.textFields![0].text ?? ""
                            // retrieve stored password in keychain
                            let legit = KeychainWrapper.standard.string(forKey: "Password")
                            // compare
                            if legit == entered {
                                // if same, unlock secret message
                                self?.unlockSecretMessage()
                            } else {
                                let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
                                ac.addAction(UIAlertAction(title: "OK", style: .default))
                                self?.present(ac, animated: true)
                            }
                        }))
                        
                        passwordAC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                        self?.present(passwordAC, animated: true)
                    }
                }
            }
        } else {
            // no biometry
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }
       


}

