//
//  SubmitViewController.swift
//  Cloud_Stuff
//
//  Created by David Tan on 25/04/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import CloudKit

class SubmitViewController: UIViewController {
    
    var genre: String!
    var comments: String!
    
    var stackView: UIStackView!
    var status: UILabel!
    var spinner: UIActivityIndicatorView!
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.gray
        
        configureStackView()
        configureLabel()
        configureSpinner()
        
        stackView.addArrangedSubview(status)
        stackView.addArrangedSubview(spinner)
    }
    
    func configureStackView() {
        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.alignment = .center
        stackView.axis = .vertical
        view.addSubview(stackView)
        
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func configureLabel() {
        status = UILabel()
        status.translatesAutoresizingMaskIntoConstraints = false
        status.text = "Submitting..."
        status.textColor = UIColor.white
        status.font = UIFont.preferredFont(forTextStyle: .title1)
        status.numberOfLines = 0
        status.textAlignment = .center
    }
    
    func configureSpinner() {
        spinner = UIActivityIndicatorView()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "You're all set!"
        // hide the back button so the user can't back out of the view controller until submission has finished
        navigationItem.hidesBackButton = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        doSubmission()
    }
    
    func doSubmission() {
        // create a CKRecord with a record type -> a record type is a string which identifies the particular type of data you're trying to save
        let whistleRecord = CKRecord(recordType: "Whistles")
        whistleRecord["genre"] = genre as CKRecordValue  // typecasting to CKRecordValue
        whistleRecord["comments"] = comments as CKRecordValue
        
        let audioURL = RecordWhistleViewController.getWhistleURL()
        let whistleAsset = CKAsset(fileURL: audioURL)  // construct a CKAsset to store URL object, since URL is not one of the default dictionary value types
        whistleRecord["audio"] = whistleAsset
        
        // use the save() method of the CloudKit public database, which sends a CKRecord off to iCloud and tell us how it went in a trailing closure
        CKContainer.default().publicCloudDatabase.save(whistleRecord) { [unowned self] (record, error) in
            // this trailing closure can be called on any thread, so jump to main thread first before UI work
            DispatchQueue.main.async {
                if let error = error {
                    self.status.text = "Error: \(error.localizedDescription)"
                    self.spinner.stopAnimating()
                } else {
                    self.view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
                    self.status.text = "Done!"
                    self.spinner.stopAnimating()
                    
                    // set the isDirty flag to true, indicating that there has been a change in iCloud (ie a new CKRecord is added)
                    ViewController.isDirty = true
                }
                
                // show a 'Done' button regardless of whether the submission has succeeded or failed, so that user can escape the screen
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneTapped))
            }
        }
    }
    
    @objc func doneTapped() {
        _ = navigationController?.popToRootViewController(animated: true)
        // calling this method pops off all the view controllers on a navigation controller's stack, returning us to the original view controller
    }

    
}
/*
 Write to iCloud:
 
 • You create CKRecord objects to contain keys and values. They are like a dictionary, just with some extra smarts built in.
 • You create CKAsset objects to hold binary blobs like our audio recording. You can attach these to a CKRecord just like any other value.
 • Each app has its own CloudKit container (CKContainer), and each container has two databases (CKDatabase) called the public and the private database.
 • The private database is for storing private user data. Any thing you upload there gets taken out of that user's iCloud quota. The public database is for storing data anyone can read. Any thing you upload there gets taken out of your CloudKit quota.
 • When you write data to CloudKit it automatically figures out how to store it based on all the keys and values you provide, and their data types. You can change this later if you want.
 • All CloudKit calls are asynchronous, so you provide completion blocks to be executed when the call finishes. This will tell you what went wrong if anything, but the block can be called on any thread so be careful!
 
 */
