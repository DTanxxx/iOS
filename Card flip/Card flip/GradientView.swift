//
//  GradientView.swift
//  Card flip
//
//  Created by David Tan on 7/03/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

@IBDesignable class GradientView: UIView {
    
     // we want this class to have a top and bottom color for our gradient, but we also want those values to be visible and editable inside InterfaceBuilder
    
    @IBInspectable var topColor: UIColor = UIColor.white
    @IBInspectable var bottomColor: UIColor = UIColor.black
    
    // when iOS asks what kind of layer to use for drawing, return CAGradientLayer
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    // when iOS tells the view to layout its subviews it should apply the top and bottom colors to the gradient
    override func layoutSubviews() {
        (layer as! CAGradientLayer).colors = [topColor.cgColor, bottomColor.cgColor]
    }

    // @IBDesignable means that Xcode should build the class and make it draw inside Interface Builder whenever changes are made
    
    // @IBInspectable exposes a property from your class as an editable value inside Interface Builder
    
}
// The use of this gradient view is that we can put it above the main view of view controller but making it a bit transparent so that a bit of main view can be seen.
// When we animate the main view to change color, since the user is seeing through the gradient view it creates a cool effect.


