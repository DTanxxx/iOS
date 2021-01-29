//
//  ActionViewController.swift
//  Extension
//
//  Created by David Tan on 21/12/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    @IBOutlet var script: UITextView!
    
    var pageTitle = ""
    var pageURL = ""
    var dict = [String: String]()
    var names = [String]()
    var scriptToUse = ""

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // extensionContext lets us control how it interacts with the parent app
        // inputItems is an array of data the parent app is sending to our extension to use
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            // one inputItem contains an array of attachments, which are wrapped up as an NSItemProvider
            if let itemProvider = inputItem.attachments?.first {
                // loadItem(...) asks the item provider to actually provide us with its item
                // a closure is used--code executes asynchronously, that is, the method will carry on executing while the item provider is busy loading and sending us its data
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] (dict, error) in
                    // NSDictionary is like dictionary but you do not need to declare it or even know what data types it holds.
                    // In this case, the itemDictionary contains all the information Apple wants us to have about the extension.
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    // The information in this case takes a JavaScript form (because we made it so), and is stored in the NSExtensionJavaScriptPreprocessingResultsKey key.
                    // Since in Action.js we asked for the data to be a dictionary, javaScriptValues is typecasted as NSDictionary.
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    print(javaScriptValues)
                    // If a dictionary with keys "URL" and "title" is printed, it means that Safari has successfully sent data to our extension.
                    
                    // nil coalescing
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                    
                    // sets the view controller's title property on the main queue
                    // this is needed because the closure being executed as a result of loadItem() could be called on any thread, and we want to change the UI only if we are on the main thread
                    DispatchQueue.main.async {
                        // no [weak self] needed because [weak self] already declared in loadItem()'s closure
                        self?.title = self?.pageTitle
                        // load saved script
                        let defaults = UserDefaults.standard
                        
                        // MARK: - removing user defaults data to reset
                        //defaults.removeObject(forKey: "dict")
                        //defaults.removeObject(forKey: "array")
                        
                        let url = URL(string: self!.pageURL)
                        //defaults.removeObject(forKey: url!.host!)
                        
                        if (self?.scriptToUse.isEmpty)! {
                            if let host = url?.host {
                                let javaScript = defaults.object(forKey: host) as? String ?? "NO JAVASCRIPT"
                                self?.script.text = javaScript
                            }
                        } else {
                            self?.script.text = self?.scriptToUse
                        }
                        
                        // MARK: - load saved dict
                        let namedScripts = defaults.dictionary(forKey: "dict") as? [String: String] ?? [:]
                        let namesArray = defaults.array(forKey: "array") as? [String] ?? []
                        self?.dict = namedScripts
                        self?.names = namesArray
                        //assert(self?.dict.count != 0, "Dict not saved")
                    }
                }
            }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        // fix the keyboard stuff using notification center and making ourselves the observer for notifications
        let notificationCenter = NotificationCenter.default
        // addObserver() parameters: the object that should receive notification, method to be called, notification we want to receive, the object we want to watch
        // setting the last parameter to nil means "we don't care who sends the notification"
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showScripts))
    }
    
    // adjustForKeyboard has one parameter because it is said to be required in Apple's documentation
    // The Notification type/object has the name of the notification as well as a Dictionary containing notification-specific information called userInfo
    @objc func adjustForKeyboard(notification: Notification) {
        // the frame of the keyboard after it has finished animating is stored in the key UIResponder.keyboardFrameEndUserInfoKey, and it is of type NSValue
        // NSValue is in turn of type CGRect
        // CGRect struct holds both a CGPoin and a CGSize--used to describe a rectangle
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        // Since arrays and dictionaries couldn't contain structures (eg CGRect), Apple uses a special NSValue class to wrap around structures so they could be put into dictionaries and arrays.
        // Therefore we can use the cgRectValue property of NSValue to read the CGRect value.
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        // convert the keyboard frame to our view's coordinates
        // this is needed because rotation isn't factored into the frame, so if the user is in landscape we'll have the width and height flipped
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        if notification.name == UIResponder.keyboardWillHideNotification {
            // no keyboard visible (in the case of a connected hardware keyboard), set edges of text view to that of the view
            script.contentInset = .zero
        } else {
            // keyboard visible, set bottom edge of text view to the top edge of keyboard frame
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        // set the edges of the scroll indicator to be that of the text view
        script.scrollIndicatorInsets = script.contentInset
        
        // make the text view scroll
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }

    @IBAction func done() {
        // completeRequest() causes the extension to be closed, returning back to the parent app
        // it will also pass back to the parent app any items that we specify
        // the items ie data we return will be passed in to the finalize() function in Action.js
        //self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
        
        // if script is saved in user default then don't ask for name
        for name in names {
            guard let text = dict[name] else { continue }
            if text == script.text {
                javaScriptStuff()
                return
            }
        }
        
        // MARK: - alert vc prompting for name
        let ac = UIAlertController(title: "Enter", message: "Create a name for your script:", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            [weak self] _ in
            guard ac.textFields?.first?.text?.isEmpty != true else { return }
            let text = ac.textFields!.first!.text!
            // check if there's repeats when appending name
            if !(self?.names.contains(text))! {
                // append to a dictionary (with script)
                self?.dict[text] = self?.script.text
                self?.names.append(text)
                // save the dictionary to user default
                let defaults = UserDefaults.standard
                defaults.set(self?.dict, forKey: "dict")
                defaults.set(self?.names, forKey: "array")
                self?.javaScriptStuff()
            } else {
                // show an alert saying name already chosen
                let ac2 = UIAlertController(title: "Error", message: "Name already chosen!", preferredStyle: .alert)
                ac2.addAction(UIAlertAction(title: "Return", style: .default, handler: {
                    _ in
                    self?.done()
                }))
                self?.present(ac2, animated: true)
            }
        }))
        present(ac, animated: true)
    }
    
    func javaScriptStuff() {
        // create a new NSExtensionItem object that will host our items
        let item = NSExtensionItem()
        // create a dictionary containing the key "customJavaScript" and the value of our script
        let argument: NSDictionary = ["customJavaScript" : script.text!]
        // put that dictionary into another dictionary with NSExtensionJavaScriptFinalizeArgumentKey key
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey : argument]
        // wrap the big dictionary inside an NSItemProvider object the type identifier kUTTypePropertyList
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        // place that NSItemProvider into our NSExtensionItem as its attachments
        item.attachments = [customJavaScript]
        // call completeRequest(), returning our NSExtensionItem
        extensionContext?.completeRequest(returningItems: [item])
        
        // Save the JavaScript script.
        save()
    }
    
    @objc func showScripts() {
        /*let ac = UIAlertController(title: "Example scripts", message: nil, preferredStyle: .actionSheet)
        let scripts = ["alert(document.title);", "alert(document.URL);", "alert('Hello');", "alert('Sup');", "alert('JavaScript');"]
        for script in scripts {
            ac.addAction(UIAlertAction(title: script, style: .default, handler: {
                [weak self] _ in
                self?.script.text = script
                self?.done()
            }))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)*/
        
        // MARK: - instantiate table view vc
        if let vc = storyboard?.instantiateViewController(identifier: "table") as? TableViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func save() {
        let defaults = UserDefaults.standard
        let url = URL(string: pageURL)
        if let host = url?.host {
            defaults.set(script.text, forKey: host)
        }
    }
    
}
