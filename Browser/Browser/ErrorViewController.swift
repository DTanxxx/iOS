//
//  ErrorViewController.swift
//  Browser
//
//  Created by David Tan on 6/10/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

class ErrorViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ac = UIAlertController(title: "Error", message: "This site cannot be reached!", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Exit", style: .default))
        present(ac, animated: true)
    }
    
}
