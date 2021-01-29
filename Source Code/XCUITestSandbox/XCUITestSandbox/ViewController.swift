//
//  ViewController.swift
//  XCUITestSandbox
//
//  Created by Paul Hudson on 24/10/2018.
//  Copyright © 2018 Hacking with Swift. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var textField: UITextField!
    @IBOutlet var label: UILabel!
    @IBOutlet var slider: UISlider!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var segmentedControl: UISegmentedControl!

    @IBAction func textChanged(_ sender: UITextField) {
        label.text = textField.text
    }

    @IBAction func sliderDragged(_ sender: UISlider) {
        progressView.progress = 1 - slider.value
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        title = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)
    }

    @IBAction func colorSelected(_ sender: UIButton) {
        let alert = UIAlertController(title: sender.titleLabel?.text, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

