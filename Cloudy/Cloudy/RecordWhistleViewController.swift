//
//  RecordWhistleViewController.swift
//  Cloud_Stuff
//
//  Created by David Tan on 24/04/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import AVFoundation

class RecordWhistleViewController: UIViewController, AVAudioRecorderDelegate {
    
    var stackView: UIStackView!
    var recordButton: UIButton!
    var playButton: UIButton!
    var recordingSession: AVAudioSession!  // ensures we are able to record
    var whistleRecorder: AVAudioRecorder!  // pulls data from the microphone and writes it to disk
    var whistlePlayer: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Record your whistle"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Record", style: .plain, target: nil, action: nil)
        
        configureView()
        setupAudio()
    }
    
    func setupAudio() {
        // grab the built-in system audio session
        recordingSession = AVAudioSession.sharedInstance()
               
        do {
            // ask for play and record privileges
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            // request user permission for audio recording
            recordingSession.requestRecordPermission { [unowned self] (allowed) in
                // the following UI work needs to be pushed onto the main thread because the callback from requestRecordPermission() can happen on any thread
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        self.loadFailUI()
                    }
                }
            }
        } catch {
            self.loadFailUI()
        }
    }
    
    func loadRecordingUI() {
        createRecordButton()
        createPlayButton()
    }
    
    func createRecordButton() {
        recordButton = UIButton()
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.setTitle("Tap to Record", for: .normal)
        // use Dynamic Type -> by using Dynamic Type we don't need to worry about sizing up the button
        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        stackView.addArrangedSubview(recordButton)  // MARK: IMPORTANT
    }
    
    func createPlayButton() {
        playButton = UIButton()
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setTitle("Tap to Play", for: .normal)
        playButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        // hide the button at first -> you need both isHidden=true and alpha=0 because for stack view, a view that is not hidden but has alpha=0 appears hidden but still occupies space in stack view
        playButton.isHidden = true
        playButton.alpha = 0
        stackView.addArrangedSubview(playButton)
    }
    
    func loadFailUI() {
        let failLabel = UILabel()
        // use Dynamic Type again
        failLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        failLabel.text = "Recording failed: please ensure the app has access to your microphone."
        failLabel.numberOfLines = 0
        stackView.addArrangedSubview(failLabel)
    }
    
    func startRecording() {
        // Make the view have a red background color so the user knows they are in recording mode.
        view.backgroundColor = UIColor(red: 0.6, green: 0, blue: 0, alpha: 1)
        
        // Change the title of the record button to say "Tap to Stop".
        recordButton.setTitle("Tap to Stop", for: .normal)
        
        // Use the getWhistleURL() method we just wrote to find where to save the whistle.
        let audioURL = RecordWhistleViewController.getWhistleURL()
        print(audioURL.absoluteString)  // print out the URL to see if it works (we can navigate in Finder to find the file and check)
        
        // Create a settings dictionary describing the format, sample rate, channels and quality.
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            // Create an AVAudioRecorder object pointing at our whistle URL, set ourselves as the delegate, then call its record() method.
            whistleRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            whistleRecorder.delegate = self
            whistleRecorder.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        // change the background color to green to show recording has finished
        view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
        
        // stop recording and destroy the recorder object
        whistleRecorder.stop()
        whistleRecorder = nil
        
        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
            // unhide the play button
            if playButton.isHidden {
                UIView.animate(withDuration: 0.35) { [unowned self] in
                    self.playButton.isHidden = false
                    self.playButton.alpha = 1
                }
            }
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextTapped))
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            
            let ac = UIAlertController(title: "Record failed", message: "There was a problem recording your whistle; please try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @objc func nextTapped() {
        let vc = SelectGenreViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func playTapped() {
        let audioURL = RecordWhistleViewController.getWhistleURL()
        
        do {
            whistlePlayer = try AVAudioPlayer(contentsOf: audioURL)
            whistlePlayer.play()
        } catch {
            let ac = UIAlertController(title: "Playback failed", message: "There was a problem playing your whistle; please try re-recording.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @objc func recordTapped() {
        if whistleRecorder == nil {
            startRecording()
            // hide the play button
            if !playButton.isHidden {
                UIView.animate(withDuration: 0.35) { [unowned self] in
                    self.playButton.isHidden = true
                    self.playButton.alpha = 0
                    // note: the isHidden property normally cannot be animated, since there are no intermediate steps between 'true' and 'false' ('visible' and 'invisible'). However, with stack view, animating the isHidden property will cause the button to slide out of the view
                }
            }
        } else {
            finishRecording(success: true)
        }
    }
    
    // catch the scenario where recording ends with a problem.
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func configureView() {
        view = UIView()
        view.backgroundColor = UIColor.gray
        
        stackView = UIStackView()
        stackView.spacing = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.alignment = .center
        stackView.axis = .vertical
        view.addSubview(stackView)  // MARK: - IMPORTANT
        
        // stack view constraints
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    // MARK: - Note that below methods have the 'class' keyword at the beginning, which means you call them on the class not on instances of the class -> this means we can find the whistle URL from anywhere in our app rather than typing it in everywhere
    
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    class func getWhistleURL() -> URL {
        return getDocumentsDirectory().appendingPathComponent("whistle.m4a")
    }
   
}

// MARK: - How recording works:
/*
• You need to tell iOS where to save the recording. This is done when you create the AVAudioRecorder object because iOS streams the audio to the file as it goes so it can write large files.
• Before recording begins, you need to decide on a format, bit rate, channel number and quality. We'll specify 1 for the number of channels, because we don’t need stereo for these simple recordings.
• If you set your view controller as the delegate of a recording, you'll be told when recording stops and whether it finished successfully or not.
• Recording won't stop if your app goes into the background briefly. Instead, it's things like a call coming in that might make it stop unexpectedly.
*/
