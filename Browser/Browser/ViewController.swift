//
//  ViewController.swift
//  Browser
//
//  Created by David Tan on 17/09/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit
import WebKit

@available(iOS 13.0, *)
class ViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var progressView: UIProgressView!
    var websites = [String]()
    var websiteSelected = ""
    var websiteCounter = 0
   
    override func loadView() {
        
        if let websitesUrl = Bundle.main.url(forResource: "websites", withExtension: "txt") {
            if let awebsites = try? String(contentsOf: websitesUrl) {
                websites = awebsites.components(separatedBy: "\n")
            }
        }
        if websites.isEmpty {
            print("Websites array empty!")
        }
        
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    // This method pretty much creates the webView object for use later on and sets up the screen

    override func viewDidLoad() {
        super.viewDidLoad()
        //print(websiteSelectedIndex) // This prints out zero
        let url = URL(string: "https://" + websiteSelected)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        let back = UIBarButtonItem(title: "Back", style: .plain, target: webView, action: #selector(webView.goBack))
        let forward = UIBarButtonItem(title: "Forward", style: .plain, target: webView, action: #selector(webView.goForward))
        
        toolbarItems = [back, forward, progressButton, spacer, refresh]
        // Notice that all the elements in the array have the type 'UIBarButtonItem'
        
        navigationController?.isToolbarHidden = false
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    @objc func openTapped() {
        let ac = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)
        for website in websites {
            ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }
    
    func openPage(action: UIAlertAction) {
        let url = URL(string: "https://" + action.title!)!
        webView.load(URLRequest(url: url))
    }
    // This method takes one parameter, which is the UIAlertAction object that was selected by the user.
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    // This method allows us to decide whether the links are on our safe list
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // '@escaping'--the closure has the potential to escape the current method, and be used at a later date.
        
        let url = navigationAction.request.url
        // Now we check whether the url has a host, or a domain name eg 'apple.com'; not all urls have a domain
        if let host = url?.host {
            for website in websites {
                if host.contains(website) {
                    websiteCounter = 0
                    websiteCounter += 1
                    decisionHandler(.allow)
                    
                    return
                }
            }
        }
        if websiteCounter != 0 {
            decisionHandler(.allow)
            return
        }
        decisionHandler(.cancel)
        // Instantiate an error view controller
        if let errorVC = storyboard?.instantiateViewController(identifier: "ErrorVC") as? ErrorViewController {
            navigationController?.pushViewController(errorVC, animated: true)
        }
    }
}
