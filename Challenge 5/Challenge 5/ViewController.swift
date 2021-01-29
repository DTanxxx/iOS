//
//  ViewController.swift
//  Challenge 5
//
//  Created by David Tan on 9/11/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var photos = [Photo]()
    var modPhotos: [Photo]?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPhoto))
        let defaults = UserDefaults.standard
        if let savedPhotos = defaults.object(forKey: "photos") as? Data {
            if let decodedPhotos = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPhotos) as? [Photo] {
                photos = decodedPhotos
            }
        }
    }
    
    // MARK: - Table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Photo", for: indexPath) as? PhotoCell else { fatalError("Failed to dequeue cell") }
        let photo = photos[indexPath.row]
        let path = getDocumentsDirectory().appendingPathComponent(photo.filename)
        cell.imageView?.image = UIImage(contentsOfFile: path.path)
        cell.captionLabel.text = photo.caption
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            let photo = photos[indexPath.row]
            vc.photoSelected = photo
            vc.caption = photo.caption
            vc.photos2 = photos
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - Picking photos
    @objc func addNewPhoto() {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) != true {
            let ac = UIAlertController(title: "Error", message: "You don't have a camera.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Return", style: .cancel))
            present(ac, animated: true)
            return
        }
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        dismiss(animated: true)
        
        let ac = UIAlertController(title: "Set Caption", message: "", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak self, weak ac] _ in guard let caption = ac?.textFields?[0] else { return }
            let photo = Photo(filename: imageName, caption: caption.text!)
            self?.photos.insert(photo, at: 0)
            self?.tableView.reloadData()
            self?.save()
        }))
        present(ac, animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func save() {
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: photos, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "photos")
        }
    }
    
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                let defaults = UserDefaults.standard
                if let savedPhotos = defaults.object(forKey: "photos") as? Data {
                    if let decodedPhotos = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPhotos) as? [Photo] {
                        self.photos = decodedPhotos
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

}





