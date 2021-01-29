//
//  MemoriesViewController.swift
//  HappyDays
//
//  Created by David Tan on 3/05/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import Speech
import CoreSpotlight
import MobileCoreServices

class MemoriesViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout, AVAudioRecorderDelegate, UISearchBarDelegate {
    
    var memories = [URL]()  // contains the full path to the root names of memories
    var filteredMemories = [URL]()
    var activeMemory: URL!  // stores which memory activated the long press gesture recognizer
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var recordingURL: URL!  // stores the URL we record to - we'll record the audio to the same file each time, then move it to the correct name once it finishes successfully -> this means if a user starts a re-record that fails for some reason, we don't write over their existing recording
    var searchQuery: CSSearchQuery?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        loadMemories()
        recordingURL = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkPermissions()
    }
    
    @objc func addTapped() {
        let vc = UIImagePickerController()
        // make the controller occupy only part of the screen on iPad
        vc.modalPresentationStyle = .formSheet
        vc.delegate = self
        navigationController?.present(vc, animated: true)
    }
    
    // this method is called when a long press has started or ended
    @objc func memoryLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            // user has pressed to record
            // convert the gesture recognizer's view property to a MemoryCell
            let cell = sender.view as! MemoryCell
            
            // use indexPath() method to find the index path of this cell
            if let index = collectionView?.indexPath(for: cell) {
                activeMemory = filteredMemories[index.row]
                recordMemory()
            }
        } else if sender.state == .ended {
            // user has lifted the finger
            finishRecording(success: true)
        }
    }
    
    // this method is called to perform the microphone recording
    func recordMemory() {
        // if playback is in flight, we stop it before recording begins
        audioPlayer?.stop()
        
        // set the background color to red so the user knows their microphone is recording
        collectionView.backgroundColor = UIColor(red: 0.5, green: 0, blue: 0, alpha: 1)
        
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            // configure the session for recording and playback through the speaker
            try recordingSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try recordingSession.setActive(true)
            
            // set up a high-quality recording session
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            // create the audio recorder, and assign ourselves as the delegate so we know when recording has stopped
            audioRecorder = try AVAudioRecorder(url: recordingURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
        } catch let error {
            // failed to record!
            print("Failed to record: \(error)")
            finishRecording(success: false)
        }
    }
    
    // this method is called when recording has finished, to link the recording to the memory
    func finishRecording(success: Bool) {
        // set the background color back to normal
        collectionView.backgroundColor = UIColor.darkGray
        
        // stop the recording if it isn’t already stopped
        audioRecorder?.stop()
        
        if success {
            do {
                // if the recording was successful, we need to create a file URL out of the active memory URL plus “m4a”
                let memoryAudioURL = activeMemory.appendingPathExtension("m4a")
                let fm = FileManager.default
                
                // if a recording already exists there, we need to delete it because you can’t move a file over one that already exists
                if fm.fileExists(atPath: memoryAudioURL.path) {
                    try fm.removeItem(at: memoryAudioURL)
                }
                
                // move our recorded file (stored at the URL we put in recordingURL) into the memory’s audio URL
                try fm.moveItem(at: recordingURL, to: memoryAudioURL)
                
                // start the transcription process
                transcribeAudio(memory: activeMemory)
            } catch let error {
                print("Failure finishing recording: \(error)")
            }
        }
    }
    
    // this method handles transcribing the narration into text and linking that to the memory
    func transcribeAudio(memory: URL) {
        // get paths to where the audio is, and where the transcription should be
        let audio = audioURL(for: memory)
        let transcription = transcriptionURL(for: memory)
        
        // create a new recognizer and point it at our audio
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: audio)  // responsible for loading one file at a specific URL and transcribing it
        
        // start recognition
        recognizer?.recognitionTask(with: request, resultHandler: {
            // this closure will get called several times, because transcription comes back in chunks as words are matched; we only care about the final transcription
            [unowned self] (result, error) in
            
            // abort if we didn't get any transcription back
            guard let result = result else {
                print("There was an error: \(error!)")
                return
            }
            
            // if we got the final transcription back, we need to write it to disk
            if result.isFinal {
                // pull out the best transcription
                let text = result.bestTranscription.formattedString
                
                // write it to disk at the correct filename for this memory
                do {
                    try text.write(to: transcription, atomically: true, encoding: String.Encoding.utf8)
                    self.indexMemory(memory: memory, topText: text, allText: result.transcriptions)
                } catch {
                    print("Failed to save transcription.")
                }
            }
        })
    }
    
    func indexMemory(memory: URL, topText: String, allText: [SFTranscription]) {
        var arrayOfItems = [CSSearchableItem]()
        var isFirst = true
        
        for transcription in allText {
            // create an instance of CSSearchableItemAttributeSet containing the attributes you want to save, such as a title and description
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
            attributeSet.title = "Happy Days Memory"
            attributeSet.contentDescription = transcription.formattedString
            attributeSet.thumbnailURL = thumbnailURL(for: memory)
            
            if isFirst {
                isFirst = false
                
                // wrap the attribute set in a searchable item, using the memory's name as its unique identifier
                let item = CSSearchableItem(uniqueIdentifier: memory.lastPathComponent, domainIdentifier: "com.hackingwithswift", attributeSet: attributeSet)
                
                // make it never expire
                item.expirationDate = Date.distantFuture
                arrayOfItems.append(item)
            } else {
                // make the unique identifier the name + the index of current transcription in allText
                let item = CSSearchableItem(uniqueIdentifier: memory.lastPathComponent+"*\(allText.firstIndex(of: transcription)!)", domainIdentifier: "com.hackingwithswift", attributeSet: attributeSet)
                item.expirationDate = Date.distantFuture
                arrayOfItems.append(item)
            }
        }
        
        // ask Spotlight to index the item
        CSSearchableIndex.default().indexSearchableItems(arrayOfItems) { (error) in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully indexed: \(arrayOfItems.count)")
                print("Total transcriptions: \(allText.count)")
            }
        }
    }
    
    // catch when the recording got terminated by the system (eg if a phone call came in)
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // dismiss the image picker controller first to return control back to MemoriesViewController
        dismiss(animated: true)
        
        // check if there is a picture in the .originalImage key inside the info dictionary; if there is a picture then we'll create a memory out of it and call loadMemories()
        if let possibleImage = info[.originalImage] as? UIImage {
            saveNewMemory(image: possibleImage)
            loadMemories()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterMemories(text: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // make the keyboard go away
        searchBar.resignFirstResponder()
    }
    
    func filterMemories(text: String) {
        // there are notes about CSSearchQuery at the very end of code block
        
        // check if search text is empty
        guard text.count > 0 else {
            // if it is, reset filteredMemories to the complete memories array
            filteredMemories = memories
            
            // reload the collection view (in a non-animating block, so that the collection view does not fade in and out while the user is typing)
            UIView.performWithoutAnimation {
                collectionView.reloadSections(IndexSet(integer: 1))
            }
            return
        }
        
        var allItems = [String]()
        searchQuery?.cancel()
        
        let queryString = "contentDescription == \"*\(text)*\"c"
        searchQuery = CSSearchQuery(queryString: queryString, attributes: nil)
        
        searchQuery?.foundItemsHandler = { items in
            for item in items {
                var name = ""
                let identifier = item.uniqueIdentifier
                
                if identifier.contains("*") {
                    name = String(identifier.split(separator: "*")[0])
                } else if identifier.lastIndex(of: ".") != identifier.firstIndex(of: ".") {
                    name = String(identifier.split(separator: ".")[0]+"."+identifier.split(separator: ".")[1])
                } else {
                    name = item.uniqueIdentifier
                }
                
                if !allItems.contains(name) { allItems.append(name) }
            }
        }
        
        searchQuery?.completionHandler = { error in
            DispatchQueue.main.async { [unowned self] in
                self.activateFilter(matches: allItems)
            }
        }
        
        searchQuery?.start()
    }
    
    func activateFilter(matches: [String]) {
        // map each element in matches to filteredMemories, so that we add an URL object to filterMemories for each CSSearchableItem
        filteredMemories = matches.map { (item) in
            // check which memory has the name
            for memory in memories {
                if memory.lastPathComponent == item {
                    return memory
                }
            }
            
            print("Nothing in the memories array contains the same name as the elements in the matches array.")
            return memories.last!
        }
        
        UIView.performWithoutAnimation {
            collectionView.reloadSections(IndexSet(integer: 1))
        }
    }
    
    func saveNewMemory(image: UIImage) {
        // create an unique name for this memory
        let memoryName = "memory-\(Date().timeIntervalSince1970)"
        
        // use the unique name to create filenames for the full-size image and the thumbnail
        let imageName = memoryName + ".jpg"
        let thumbnailName = memoryName + ".thumb"
        
        do {
            // create an URL by combining getDocumentsDirectory() with the image name, where we can write the JPEG to
            let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
            
            // convert the UIImage into a JPEG data object
            if let jpegData = image.jpegData(compressionQuality: 0.8) {
                // write that data to the URL we created
                try jpegData.write(to: imagePath, options: [.atomicWrite])
            }
            
            // create a thumbnail for the image
            if let thumbnail = resize(image: image, to: 200) {
                let imagePath = getDocumentsDirectory().appendingPathComponent(thumbnailName)
                if let jpegData = thumbnail.jpegData(compressionQuality: 0.8) {
                    try jpegData.write(to: imagePath, options: [.atomicWrite])
                }
            }
        } catch {
            print("Failed to save to disk.")
        }
    }
    
    func loadMemories() {
        // remove any existing memories. We'll be calling it multiple times, so we don't want duplicates
        memories.removeAll()
        
        // attempt to load all the memories in our documents directory
        guard let files = try? FileManager.default.contentsOfDirectory(at: getDocumentsDirectory(), includingPropertiesForKeys: nil, options: []) else { return }
        
        // loop over every file found
        for file in files {
            // the lastPathComponent here is file's name + type of file (.thumb, .jpg, etc)
            let filename = file.lastPathComponent
            
            // check it ends with ".thumb" (a thumbnail) so we don't count each memory more than once (we don't want to add the .jpg and .thumb for each memory)
            if filename.hasSuffix(".thumb") {
                // get the root name of the memory (ie without its path extension, so we get just the name of the file)
                let noExtension = filename.replacingOccurrences(of: ".thumb", with: "")
                
                // create a full path from the memory
                let memoryPath = getDocumentsDirectory().appendingPathComponent(noExtension)
                
                // add it to our array
                memories.append(memoryPath)
            }
        }
        
        filteredMemories = memories
        
        // reload our list of memories - we are only reloading the second section of collection view, because the first section contains the search bar
        collectionView.reloadSections(IndexSet(integer: 1))
    }
    
    // this method will produce a downsized version of an image, to use as thumbnail
    func resize(image: UIImage, to width: CGFloat) -> UIImage? {
        // calculate how much we need to bring the width down to match our target size
        let scale = width / image.size.width
        
        // bring the height down by the same amount so that the aspect ratio is preserved
        let height = image.size.height * scale
        
        // create a new image context we can draw into
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
        
        // draw the original image into the context
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // pull out the resized version
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // end the context so UIKit can clean up
        UIGraphicsEndImageContext()
        
        // send it back to the caller
        return newImage
    }
    
    func checkPermissions() {
        // check status for all three permissions
        let photosAuthorized = PHPhotoLibrary.authorizationStatus() == .authorized
        let recordingAuthorized = AVAudioSession.sharedInstance().recordPermission == .granted
        let transcribedAuthorized = SFSpeechRecognizer.authorizationStatus() == .authorized
        
        // make a single boolean out of all three
        let authorized = photosAuthorized && recordingAuthorized && transcribedAuthorized
        
        // if we're missing one, show the first run screen
        if authorized == false {
            if let vc = storyboard?.instantiateViewController(identifier: "FirstRun") {
                navigationController?.present(vc, animated: true)
            }
        }
    }
    
    // MARK: - Collection view data source
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            // we have the section header, return 0 rows
            return 0
        } else {
            return filteredMemories.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Memory", for: indexPath) as! MemoryCell
    
        let memory = filteredMemories[indexPath.row]
        let imageName = thumbnailURL(for: memory).path
        let image = UIImage(contentsOfFile: imageName)
        cell.imageView.image = image
        
        // add a long press gesture recognizer to cell if the cell does not already have one
        if cell.gestureRecognizers == nil {
            let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(memoryLongPress))
            // user needs to press down for at least 0.25 seconds to trigger the recognizer
            recognizer.minimumPressDuration = 0.25
            cell.addGestureRecognizer(recognizer)
            
            cell.layer.borderColor = UIColor.white.cgColor
            cell.layer.borderWidth = 3
            cell.layer.cornerRadius = 10
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let memory = filteredMemories[indexPath.row]
        let fm = FileManager.default
        
        do {
            // get the audio and transcription URLs
            let audioName = audioURL(for: memory)
            let transcriptionName = transcriptionURL(for: memory)
            
            // check if audio file exists
            if fm.fileExists(atPath: audioName.path) {
                audioPlayer = try AVAudioPlayer(contentsOf: audioName)
                audioPlayer?.play()
            }
            
            // check if transcription file exists (transcription takes a couple of seconds to complete, so it may not exist when user taps on a cell)
            if fm.fileExists(atPath: transcriptionName.path) {
                let contents = try String(contentsOf: transcriptionName)
                print(contents)
            }
        } catch {
            print("Error loading audio")
        }
    }
    
    // return a header for every section
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
    }
    
    // set the height to zero for the section headers you don't want
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 1 {
            // this is not the search bar section, set the size of header to zero
            return CGSize.zero
        } else {
            return CGSize(width: 0, height: 50)
        }
    }
    
    // MARK: - Helper methods
    
    func imageURL(for memory: URL) -> URL {
        return memory.appendingPathExtension("jpg")
    }
    
    func thumbnailURL(for memory: URL) -> URL {
        return memory.appendingPathExtension("thumb")
    }
    
    func audioURL(for memory: URL) -> URL {
        return memory.appendingPathExtension("m4a")
    }
    
    func transcriptionURL(for memory: URL) -> URL {
        return memory.appendingPathExtension("txt")
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
}
/* MARK: - path component vs path extension
 
 path component is xxx/xxx
 path extension is xxx.xxx
 
*/

/* MARK: - CSSearchQuery
 
 -   mainly functions through two closures -> one is called when it finds a matching item (which will append the item to an array), and one to call when the search finishes, at which point we’re going to update our UI with the search results
 
 -   specifying search criteria -> similar to Core Data, in this case we use  "contentDescription == \"*\(text)*\"c", which means "find things that have a contentDescription value equal to any text", followed by our search text, then any text, using case-insensitive matching

 -   running a CSSearchQuery returns CSSearchableItem items, so we need an array to store that data type
 
 -   we’ll be taking advantage of closure capturing to share that array between the “found items” closure and the “search is finished” handler
 
 -   the closures can be called on any thread, so as we’re manipulating the UI when the search finishes we'll be pushing that work to the main thread
 
 -   you need to explicitly call start() on the search to make it begin
 
 -   in case a user types really fast, we want a way to cancel the existing search before starting a new one -> we’ll be storing the CSSearchQuery object as a property in the class, then calling cancel() on it before searching

 */
