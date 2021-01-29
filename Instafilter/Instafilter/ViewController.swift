//
//  ViewController.swift
//  Instafilter
//
//  Created by David Tan on 15/11/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var button: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensity: UISlider!
    @IBOutlet var radius: UISlider!
    var currentImage: UIImage!
    var context: CIContext!  // This is the Core Image component that handles rendering.
    var currentFilter: CIFilter!  // This will store whatever filter the user has activated. The filter will be given various input settings before we ask it to output a result for us to show in the image view.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "YACIFP"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        context = CIContext()  // Creates a default Core Image context.
        currentFilter = CIFilter(name: "CISepiaTone")  // Creates an example filter that will apply a sepia tone effect to images.
        
        button.setTitle("CISepiaTone", for: .normal)
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        dismiss(animated: true)
        
        currentImage = image
        imageView.alpha = 0.0
        
        // Set our currentImage property as the input image for the currentFilter Core Image filter. Then call a method called applyProcessing(), which will do the actual Core Image manipulation.
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)  // We send the CIImage into the current Core Image Filter using the kCIInputImageKey.
        
        applyProcessing()
    }
    
    @IBAction func changeFilter(_ sender: AnyObject) {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = ac.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(ac, animated: true)
    }
    
    // Now we create the setFilter method. This method should update our currentFilter property with the filter that was chosen, and set the kCIInputImageKey key again (because we just changed the filter), then call applyProcessing().
    func setFilter(action: UIAlertAction) {
        // We need the action parameter here because the handler is a closure where UIAlertAction is passed in.
        
        // make sure we have a valid image before continuing!
        guard currentImage != nil else { return }
        
        // safely read the alert action's title
        guard let actionTitle = action.title else { return }
    
        button.setTitle(actionTitle, for: .normal)
        
        currentFilter = CIFilter(name: actionTitle)
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }

    @IBAction func save(_ sender: UIButton) {
        guard let image = imageView.image else {
            let ac = UIAlertController(title: "Error", message: "There's no image to be saved.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Error", style: .default))
            present(ac, animated: true)
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func radiusChanged(_ sender: UISlider) {
        applyProcessing()
    }
    
    @IBAction func intensityChanged(_ sender: UISlider) {
        // Call the applyProcessing() method when the slider is dragged around.
        applyProcessing()
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func applyProcessing() {
        guard let image = currentFilter.outputImage else { return }  // reads the output image from our current filter
        
        // Since not all filters have an intensity setting, we can check inputKeys property of the filter to see if each of our input keys exist, and, if it does, use it (setting the value of an input key that does not exist in a particular filter will cause the app to crash because the filter would not know what to do with the setting--why can you set value to something that doesn't exist in a filter in the first place? Because the forKey parameter accepts ALL String types and places no restrictions on particular strings for different filters.).
        // Not all of the settings expect a value between 0 and 1, so some slider values may be multiplied to make the effect more pronounced.
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)  // uses the value of our intensity slider to set the kCIInputIntensityKey value of our current Core Image filter.
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(radius.value * 200, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
        }
        if inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
        }
        
        // Now we create a new data type called CGImage from the output image of the current filter. We need to specify which part of the image we want to render, but using image.extent means "all of it." Until this method is called, no actual processing is done, so this is the one that does the real work. This returns an optional CGImage so we need to check and unwrap with if let.
        if let cgimg = context.createCGImage(image, from: image.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            imageView.image = processedImage
            
            UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
                self.imageView.alpha = 1.0
            }, completion: nil)
            
        }
    }
    
    
    
    
}

