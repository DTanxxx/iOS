//
//  CannonInfo.swift
//  Chemmy
//
//  Created by David Tan on 26/08/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import Foundation
import UIKit

enum CannonInfo {
    static let standSize: CGSize = CGSize(width: 50, height: 30)
    static let standPos: CGPoint = CGPoint(x: 0, y: 15)
    static let standPhysicsBodyOffsetHeight: CGFloat = 26
    static let standPhysicsBodyPos: CGPoint = CGPoint(x: 0, y: -13)
    
    static let cannonScaleFactor: CGFloat = 1.65
    static let cannonPos: CGPoint = CGPoint(x: 0, y: 15)
    
    static let inputDetectionBoxSizeOffsetHeight: CGFloat = 8
    static let inputDetectionBoxSizeOffsetWidth: CGFloat = 10
    static let inputDetectionBoxPos: CGPoint = CGPoint(x: 0, y: 26)
    
    static let rotationPivotPos: CGPoint = CGPoint(x: 0, y: 15)
    static let rotationSpeed: CGFloat = 0.1
    static let maxRotationAngle: CGFloat = .pi/6
}
