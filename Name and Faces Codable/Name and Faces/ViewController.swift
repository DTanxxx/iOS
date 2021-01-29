//
//  ViewController.swift
//  Name and Faces
//
//  Created by David Tan on 31/10/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var people = [Person]()
    var peopleArrayAfterAuthentication = [Person]()  // empty now
    var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        if let savedPeople = defaults.object(forKey: "people") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                people = try jsonDecoder.decode([Person].self, from: savedPeople)
            } catch {
                print("Failed to load people")
            }
        }
        
        createAuthenticationButton()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(lockStuff), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    // MARK: - create an authentication button
    
    func createAuthenticationButton() {
        navigationItem.title = "AUTHENTICATE"
        button = UIButton(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        button.setTitle("AUTHENTICATE", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        view.addSubview(button)
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(authenticateTapped), for: .touchUpInside)
    }
    
    @objc func authenticateTapped() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] (success, authenticationError) in
                
                DispatchQueue.main.async {
                    if success {
                        self?.unlockApp()
                    } else {
                        let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(ac, animated: true)
                    }
                }
            }
        } else {
            // no biometry
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }
    
    func unlockApp() {
        navigationItem.title = nil
        button.isHidden = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        peopleArrayAfterAuthentication = people
        collectionView.reloadData()
    }
    
    @objc func lockStuff() {
        button.isHidden = false
        navigationItem.leftBarButtonItem = nil
        navigationItem.title = "AUTHENTICATE"
        peopleArrayAfterAuthentication.removeAll()
        collectionView.reloadData()
    }
    
    // This method creates the picker controller.
    @objc func addNewPerson() {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) != true {
            let ac = UIAlertController(title: "Error", message: "You don't have a camera.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Return", style: .cancel))
            present(ac, animated: true)
            return
        }
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true  // allows the user to crop the picture they select
        picker.delegate = self
        present(picker, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return peopleArrayAfterAuthentication.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            // Note that we need to typecast our collection view cell as a PersonCell because we'll soon want to access its imageView and name outlets.

            // we failed to get a PersonCell--bail out!
            fatalError("Unable to dequeue PersonCell.")
            // fatalError() escapes from a method that has a return value without sending anything back ie without triggering that return statement
        }
        
        let person = peopleArrayAfterAuthentication[indexPath.item]
        cell.name.text = person.name
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor  // This method is useful when you only want grayscale colors.
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        // if we're still here it means we got a PersonCell, so we can return it
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        let ac1 = UIAlertController(title: "Rename or Delete", message: nil, preferredStyle: .alert)
        ac1.addAction(UIAlertAction(title: "Rename", style: .default, handler: { [weak self] _ in let ac2 = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
            ac2.addTextField()
            ac2.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            ac2.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, weak ac2] _ in guard let newName = ac2?.textFields?[0].text else { return }
            person.name = newName
            self?.collectionView.reloadData()
                self?.save()
            }))
            self?.present(ac2, animated: true)
        }))
        ac1.addAction(UIAlertAction(title: "Delete", style: .default, handler: { [weak self] _ in self?.people.remove(at: indexPath.item)
            self?.peopleArrayAfterAuthentication.remove(at: indexPath.item)
           
            try? FileManager.default.removeItem(atPath: self!.getDocumentsDirectory().appendingPathComponent(person.image).path)
            self?.collectionView.reloadData()
            self?.save()
        }))
        present(ac1, animated: true)
    }
   
    // Here is an optional method for the UIImagePickerControllerDelegate protocol, which instructs what to do after an image is picked. Note that this method does not create a picker controller. It is like didSelectRowAt method for table view controller.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        let imageName = UUID().uuidString  // create an UUID object, and use its uuidString property to extract the unique identifier as a string data type
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)  // Generate a unique filename for the image.
        
        // Now convert the UIImage to a Data object so it can be saved
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)  // write the data object to the unique filename we created earlier
        }
        
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        peopleArrayAfterAuthentication.append(person)
        collectionView.reloadData()
        save()
        
        dismiss(animated: true)  // dismissing the view controller
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(people) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "people")
        } else {
            print("Failed to save people.")
        }
    }
    

}


