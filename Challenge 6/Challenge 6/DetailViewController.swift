//
//  DetailViewController.swift
//  Challenge 6
//
//  Created by David Tan on 17/12/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    
    var country: Country?
    var webView: WKWebView!
    var foodString = ""
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let country = country else { return }
        for food:String in country.food {
            foodString.append(food+", ")
        }
        foodString = foodString.trimmingCharacters(in: .whitespaces)
        foodString = foodString.trimmingCharacters(in: .punctuationCharacters)
        let html = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style> body { font-size: 150%; } </style>
        </head>
        <body>
        Capital City: \(country.capital)
        <br>
        Poplation: \(country.population)
        <br>
        Size: \(country.size)
        <br>
        Currency: \(country.currency)
        <br>
        Food: \(foodString)
        <br>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
    }
    
    @objc func share() {
        guard let country = country else { return }
        let vc = UIActivityViewController(activityItems: [country.food.joined(separator: "\n")], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    
}
