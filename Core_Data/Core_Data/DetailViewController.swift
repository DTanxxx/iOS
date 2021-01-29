//
//  DetailViewController.swift
//  Core_Data
//
//  Created by David Tan on 11/03/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    
    var detailItem: Commit?
    var didLoadFromMainVC: Bool!
    var allCommits: [Commit]!
    let webView = WKWebView()
    
    override func loadView() {
        self.view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let detail = self.detailItem {
            if let url = URL(string: detail.url) {
                let request = URLRequest(url: url)
                webView.load(request)
            }
            
            if didLoadFromMainVC {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Commit 1/\(detail.author.commits.count)", style: .plain, target: self, action: #selector(showAuthorCommits))
            }
        }
    }
    
    @objc func showAuthorCommits() {
        if let vc = storyboard?.instantiateViewController(identifier: "author") as? AuthorCommitsViewController {
            vc.commit = detailItem
            vc.allCommits = allCommits
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}
