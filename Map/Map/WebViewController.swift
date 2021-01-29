//
//  WebViewController.swift
//  Map
//
//  Created by David Tan on 16/12/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    var placeName: String?
    var webView: WKWebView!
    var progressView: UIProgressView!

    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatted = placeName?.replacingOccurrences(of: " ", with: "")
        let url = URL(string: "https://en.wikipedia.org/wiki/"+formatted!)!
        webView.load(URLRequest(url: url))
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        toolbarItems = [progressButton]
        navigationController?.isToolbarHidden = false
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    

}
