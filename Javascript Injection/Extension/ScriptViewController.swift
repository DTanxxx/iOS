//
//  ScriptViewController.swift
//  Extension
//
//  Created by David Tan on 5/01/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

class ScriptViewController: UIViewController {
    
    @IBOutlet var textView: UITextView!
    var script: String?
    var index: Int?
    var actionVC: ActionViewController!
    var tableVC: TableViewController!
    var backButtonPressed = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let script = script {
            textView.text = script
        }
        let button1 = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveScript))
        let button2 = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteScript))
        let button3 = UIBarButtonItem(title: "Use", style: .plain, target: self, action: #selector(useScript))
        navigationItem.rightBarButtonItems = [button3, button2, button1]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !backButtonPressed { return }
        let defaults = UserDefaults.standard
        let dict = defaults.dictionary(forKey: "dict") as? [String: String] ?? [:]
        let names = defaults.array(forKey: "array") as? [String] ?? []
        tableVC = (navigationController?.viewControllers[1] as! TableViewController)
        CATransaction.begin()
        //let _ = navigationController?.popViewController(animated: true)
        CATransaction.setCompletionBlock {
            [weak self] in
            self?.tableVC.dict = dict
            self?.tableVC.array = names
            self?.tableVC.viewDidLoad()
        }
        CATransaction.commit()
    }
    
    // MARK: - Buttons functionalities
    @objc func saveScript() {
        backButtonPressed = true
        // get the dict
        let defaults = UserDefaults.standard
        var dict = defaults.dictionary(forKey: "dict") as? [String: String] ?? [:]
        for key in dict.keys {
            if dict[key]!.contains(script!) {
                dict[key] = textView.text!
            }
        }
        // save
        defaults.set(dict, forKey: "dict")
    }

    @objc func deleteScript() {
        backButtonPressed = false
        // get the dict and array
        let defaults = UserDefaults.standard
        var dict = defaults.dictionary(forKey: "dict") as? [String: String] ?? [:]
        var names = defaults.array(forKey: "array") as? [String] ?? []
        // delete the corresponding elements
        dict[names[index!]] = nil
        names.remove(at: index!)
        // save
        defaults.set(dict, forKey: "dict")
        defaults.set(names, forKey: "array")
        
        tableVC = (navigationController?.viewControllers[1] as! TableViewController)
        CATransaction.begin()
        let _ = navigationController?.popViewController(animated: true) 
        CATransaction.setCompletionBlock {
            [weak self] in
            self?.tableVC.dict = dict
            self?.tableVC.array = names
            self?.tableVC.viewDidLoad()
        }
        CATransaction.commit()
    }
    
    @objc func useScript() {
        saveScript()
        backButtonPressed = false
        actionVC = (navigationController?.viewControllers[0] as! ActionViewController)
        CATransaction.begin()
        let _ = navigationController?.popToViewController((navigationController?.viewControllers[0]) as! ActionViewController, animated: true)
        CATransaction.setCompletionBlock {
            [weak self] in
            self?.actionVC.scriptToUse = (self?.textView.text)!
            self?.actionVC.viewDidLoad()
        }
        CATransaction.commit()
    }
    
   

}
