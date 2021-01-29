//
//  CapturePreviewView.swift
//  PaleoCam
//
//  Created by David Tan on 5/11/20.
//

import UIKit
import AVFoundation

class CapturePreviewView: UIView {
    // returns what layer type should be used for drawing - CALayer by default, but we will make it return AVCaptureVideoPreviewLayer
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
