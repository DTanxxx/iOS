//
//  ContentViewController.swift
//  Bio&Chem
//
//  Created by David Tan on 28/03/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {
    
    @IBOutlet var textView: UITextView!
    
    var topicNum: Int!
    var chapterNum: Int!  // stores the num associated with each chapter
    var fileExtension: String!
    var isBio: Bool!
    var filePrefix: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createBackButton()
        
        view.backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        
        // MARK: - need to change the bio files from rtf to rtfd format
        
        fileExtension = "rtfd"
        
        if isBio { filePrefix = "Topic" } else { filePrefix = "cTopic" }
        
        if let rtfdPath = Bundle.main.url(forResource: "\(filePrefix!)\(topicNum!)Chapter\(chapterNum!+1)", withExtension: fileExtension) {
            do {
                var attributedStringWithRtfd: NSMutableAttributedString = NSMutableAttributedString()
                if fileExtension == "rtfd" {
                    attributedStringWithRtfd = try NSMutableAttributedString(url: rtfdPath, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtfd], documentAttributes: nil)
                } else if fileExtension == "rtf" {
                    attributedStringWithRtfd = try NSMutableAttributedString(url: rtfdPath, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                }
            
                self.textView.attributedText = attributedStringWithRtfd
            } catch let error {
                print("Got an error \(error)")
            }
            
        }
        
    }
    
    func createBackButton() {
        let button = UIButton(frame: CGRect(x: 15, y: 50, width: 70, height: 40))
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    

}
