//
//  ViewController.swift
//  Multibrowser
//
//  Created by David Tan on 28/01/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var addressBar: UITextField!
    @IBOutlet var stackView: UIStackView!
    weak var activeWebView: WKWebView?  // it is weak because it might go away at any time if the user deletes it
    var placeHolder: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaultTitle()
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWebView))
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteWebView))
        navigationItem.rightBarButtonItems = [delete, add]
    }
    
    func setDefaultTitle() {
        if placeHolder != nil {
            placeHolder.removeFromSuperview()
            placeHolder = nil
        }
        
        addressBar.text = ""
        
        let frame = CGRect(x: 18, y: 0, width: (navigationController?.navigationBar.frame.width)! / 2.5, height: (navigationController?.navigationBar.frame.height)!)
        placeHolder = UILabel(frame: frame)
        placeHolder.textAlignment = .left
        placeHolder.text = "Press the plus button, select a cell, then enter any url into below text field"
        placeHolder.isUserInteractionEnabled = false
        placeHolder.textColor = UIColor.red
        placeHolder.numberOfLines = 0
        navigationController?.navigationBar.addSubview(placeHolder)
        title = "Multibrowser"
    }

    @objc func addWebView() {
        let webView = WKWebView()
        webView.navigationDelegate = self
        
        stackView.addArrangedSubview(webView)  // MARK: - you do not call addSubview() on UIStackView.
        
        let url = URL(string: "https://www.hackingwithswift.com")!
        webView.load(URLRequest(url: url))
        
        webView.layer.borderColor = UIColor.blue.cgColor
        selectWebView(webView)  // make every newly added webView activated
    
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(webViewTapped))
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)  // add the new recognizer to the webView, which already has a set of gesture recognizers itself
    }
    
    @objc func deleteWebView() {
        // safely unwrap our webview
        if let webView = activeWebView {
            if let index = stackView.arrangedSubviews.firstIndex(of: webView) {
                // we found the webview - remove it from the stack view and destroy it
                webView.removeFromSuperview()
                
                if stackView.arrangedSubviews.count == 0 {
                    // go back to our default UI
                    setDefaultTitle()
                } else {
                    // convert the Index value into an integer
                    var currentIndex = Int(index)
                    
                    // if that was the last web view in the stack, go back one
                    if currentIndex == stackView.arrangedSubviews.count {
                        currentIndex = stackView.arrangedSubviews.count - 1
                    }
                    
                    // find the web view at the new index and s
                    if let newSelectedWebView = stackView.arrangedSubviews[currentIndex] as? WKWebView {
                        selectWebView(newSelectedWebView)
                    }
                }
            }
        }
    }
    
    func selectWebView(_ webView: WKWebView) {
        // objective: activate the webView selected, so that the user can use that webView to navigate to any URL user requests; also highlight the selected webView
        
        // loop through array of web views belonging to the stack view
        for view in stackView.arrangedSubviews {
            // set width of border to 0
            view.layer.borderWidth = 0
        }
        
        activeWebView = webView
        // set newly selected web view to have a border width of 3
        webView.layer.borderWidth = 3
        updateUI(for: webView)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // check for any activated web view
        if let webView = activeWebView, let address = addressBar.text {
            // check for any valid url
            if !address.contains("https://") {
                if let url = URL(string: "https://" + address) {
                    webView.load(URLRequest(url: url))
                }
            } else {
                if let url = URL(string: address) {
                    webView.load(URLRequest(url: url))
                }
            }
        }
        
        textField.resignFirstResponder()  // hides the keyboard
        return true
    }
    
    @objc func webViewTapped(_ recognizer: UITapGestureRecognizer) {
        if let selectedView = recognizer.view as? WKWebView {
            selectWebView(selectedView)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView == activeWebView {
            updateUI(for: webView)
        }
    }
    
    func updateUI(for webView: WKWebView) {
        title = webView.title
        addressBar.text = webView.url?.absoluteString ?? ""
        placeHolder.isHidden = true
    }
    
    // MARK: - tell iOS we want these gesture recognizers to trigger alongside the recognizers built into the WKWebView
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - iPad multitasking configurations
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // set stack view to arrange items vertically if split view has the app occupying less than 70% of the screen
        if traitCollection.horizontalSizeClass == .compact {
            stackView.axis = .vertical
        } else {
            // arrange horizontally
            stackView.axis = .horizontal
        }
    }
    
}

