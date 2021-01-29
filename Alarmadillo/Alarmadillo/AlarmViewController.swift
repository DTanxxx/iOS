//
//  AlarmViewController.swift
//  Alarmadillo
//
//  Created by David Tan on 28/05/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

class AlarmViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var name: UITextField!
    @IBOutlet var caption: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var tapToSelectImage: UILabel!
    
    var alarm: Alarm!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = alarm.name
        name.text = alarm.name
        caption.text = alarm.caption
        datePicker.date = alarm.time
        
        if alarm.image.count > 0 {
            // if we have an image, try to load it
            let imageFilename = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
            imageView.image = UIImage(contentsOfFile: imageFilename.path)
            tapToSelectImage.isHidden = true
        }
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        alarm.time = sender.date
        alarm.hasChanged = true
        save()
    }
    
    @IBAction func imageViewTapped(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true)
    }
    
    @objc func save() {
        NotificationCenter.default.post(name: Notification.Name("save"), object: nil)
    }
    
    // MARK: - image picker controller
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // dismiss the image picker
        dismiss(animated: true)
        
        // fetch the image that was picked
        guard let image = info[.originalImage] as? UIImage else { return }
        let fm = FileManager()
        
        if alarm.image.count > 0 {
            // the alarm already has an image, so delete it
            do {
                let currentImage = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
                
                if fm.fileExists(atPath: currentImage.path) {
                    try fm.removeItem(at: currentImage)
                }
            } catch {
                print("Failed to remove current image")
            }
        }
        
        do {
            // generate a new filename for the image
            alarm.image = "\(UUID().uuidString).jpg"
            
            // write the new image to the documents directory
            let newPath = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
            
            let jpeg = image.jpegData(compressionQuality: 0.8)
            try jpeg?.write(to: newPath)
            
            alarm.hasChanged = true
            save()
        } catch {
            print("Failed to save new image")
        }
        
        // update the user interface
        imageView.image = image
        tapToSelectImage.isHidden = true
    }
    
    // MARK: - text field methods
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        alarm.name = name.text!
        alarm.caption = caption.text!
        title = alarm.name
        
        alarm.hasChanged = true
        save()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
   
}
