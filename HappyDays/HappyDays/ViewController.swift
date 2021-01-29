//
//  ViewController.swift
//  HappyDays
//
//  Created by David Tan on 3/05/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import AVFoundation  // microphone stuff
import Photos  // accessing user photos
import Speech  // speech transcription

class ViewController: UIViewController {

    @IBOutlet var helpLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func requestPhotosPermissions() {
        // request for user's permission to access photos
        PHPhotoLibrary.requestAuthorization { [unowned self] (authStatus) in
            // push to main thread as callback can happen on any thread
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    // user gave permission to access photos
                    self.requestRecordPermissions()
                } else {
                    self.helpLabel.text = "Photos permission was declined; please enable it in settings then tap Continue again."
                }
            }
        }
    }
    
    func requestRecordPermissions() {
        // request for user's permission to access microphone
        AVAudioSession.sharedInstance().requestRecordPermission { [unowned self] (allowed) in
            DispatchQueue.main.async {
                if allowed {
                    // user gave permission to access microphone
                    self.requestTranscribePermissions()
                } else {
                    self.helpLabel.text = "Recording permission was declined; please enable it in settings then tap Continue again."
                }
            }
        }
    }
    
    func requestTranscribePermissions() {
        // request for user's permission to transcribe speech
        SFSpeechRecognizer.requestAuthorization { [unowned self] (authStatus) in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    // user gave permission to transcribe speech
                    self.authorizationComplete()
                } else {
                    self.helpLabel.text = "Transcription permission was declined; please enable it in settings then tap Continue again."
                }
            }
        }
    }
    
    func authorizationComplete() {
        dismiss(animated: true)
    }

    @IBAction func requestPermissions(_ sender: Any) {
        requestPhotosPermissions()
    }
    
}

