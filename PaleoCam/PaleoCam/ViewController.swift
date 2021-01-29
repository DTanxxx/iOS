//
//  ViewController.swift
//  PaleoCam
//
//  Created by David Tan on 5/11/20.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    let session = AVCaptureSession()  // stores our app-wide configuration for using the camera
    let photoOutput = AVCapturePhotoOutput()  // stores what we use to take photos with a specific configuration
    var capturePreview: CapturePreviewView!  // holds our UIView subclass

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new capture preview
        capturePreview = CapturePreviewView()
        capturePreview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(capturePreview)
        
        // make it fill the screen
        capturePreview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        capturePreview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        capturePreview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        capturePreview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        // typecast its layer and connect its session to ours
        (capturePreview.layer as! AVCaptureVideoPreviewLayer).session = session
        
        // create a new button
        let takePhoto = UIButton(type: .custom)
        takePhoto.translatesAutoresizingMaskIntoConstraints = false
        takePhoto.setTitle("Take Photo", for: [])
        takePhoto.setTitleColor(UIColor.red, for: [])
        view.addSubview(takePhoto)
        
        // align it to 20 points up from the bottom
        takePhoto.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        takePhoto.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        
        // make it call capturePhoto() when tapped
        takePhoto.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
    }
    
    // taking photos:
    /*
     - when "Take Photo" is tapped, we are going to configure settings for the picture -> each picture must be configured FROM SCRATCH
     - when we tell the AVCapturePhotoOutput object to take a photo, we will get a callback saying that our settings have been evaluated and resolved -> either means we got what we asked for, or that iOS had to make changes
     - we also get callbacks when the picture has been taken -> one for raw photos, and another for JPEG photos
     */
    @objc func capturePhoto() {
        // create a new AVCapturePhotoSettings object to configure each picture -> requires a raw photo pixel format
        guard let rawFormat = photoOutput.supportedRawPhotoPixelFormatTypes(for: .dng).first else { return }
        let photoSettings = AVCapturePhotoSettings(rawPixelFormatType: rawFormat.uint32Value)
        
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
        
        // call capturePhoto() on the AVCapturePhotoOutput object
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    // here is callback telling us what settings got selected
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        // update the UI?
    }
    
    // here is callback for receiving the photo once it's taken
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // pull the DNG raw file out of the sample buffer
        let data = photo.fileDataRepresentation()
        
        // convert the raw file into an image that gets saved to user's camera roll
        let context = CIContext(options: nil)
        let filter = CIFilter(imageData: data)
        
        if let result = filter?.outputImage {
            if let cgImage = context.createCGImage(result, from: result.extent) {
                let image = UIImage(cgImage: cgImage)
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
    }
    
    // configuring a session:
    /*
     - give it a sensible preset (eg AVCaptureSessionPresetPhoto)
     - create a video capture device and adding it to the session
     - add our existing AVCapturePhotoOutput property, photoOutput, to the session, so that we save photos
     */
    /*
     The last two of those steps will throw exceptions if they fail, and we also need to use the canAddInput() and canAddOutput() methods before even trying. Furthermore, if we are going to make multiple changes to a session, we need to wrap the whole thing inside calls to session.beginConfiguration() and session.commitConfiguration()
     */
    func configureSession() -> Bool {
        // prepare to make changes
        session.beginConfiguration()

        // apply the most useful preset for our needs
        session.sessionPreset = AVCaptureSession.Preset.photo
        
        do {
            // create a video capture device
            let videoCaptureDevice = AVCaptureDevice.default(for: .video)
            
            // try creating a device input for the video capture device - note: this might throw an exception!
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoCaptureDevice!)
            
            // check whether we can add this device input to our session
            if session.canAddInput(videoDeviceInput) {
                // we can - add it!
                session.addInput(videoDeviceInput)
            } else {
                // we can't - escape!
                print("Failed to add video device input")
                session.commitConfiguration()
                return false
            }
            
            // check whether we can add our photo output
            if session.canAddOutput(photoOutput) {
                // we can - add it!
                session.addOutput(photoOutput)
                
                // request high-res photo support
                photoOutput.isHighResolutionCaptureEnabled = true
            } else {
                // we can't - escape!
                print("Failed to add photo output")
                session.commitConfiguration()
                return false
            }
        } catch {
            // something went wrong - escape!
            print("Failed to create device input: \(error)")
            session.commitConfiguration()
            return false
        }
        
        // if we made it here then everything went well - commit the configuration
        session.commitConfiguration()
        
        // start the capture session
        session.startRunning()
        
        // return success
        return true
    }
}

