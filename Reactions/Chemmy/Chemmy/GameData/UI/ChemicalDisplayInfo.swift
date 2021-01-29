//
//  ChemicalDisplayInfo.swift
//  Chemmy
//
//  Created by David Tan on 26/08/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import Foundation
import UIKit

enum PanelInfo {
    static let widthAnchorMultiplier: CGFloat = 0.7
    static let heightAnchorMultiplier: CGFloat = 0.1
    static let bottomEdgeOffset: CGFloat = -20
    
    static let spacing: CGFloat = 10
    static let lateralEdgeOffset: CGFloat = 10  // used for stack view cells offset from stack view edges
    static let longitudinalEdgeOffset: CGFloat = 10  // used for stack view cells offset from stack view edges
    
    //    static let color: UIColor =
}

enum BoxInfo {
    static let widthAnchorMultiplier: CGFloat = 0.55
    static let heightAnchorMultiplier: CGFloat = 0.08
    static let bottomEdgeOffsetFromPanel: CGFloat = -10
    
    static let spacing: CGFloat = 10
    static let lateralEdgeOffset: CGFloat = 8  // used for stack view cells offset from stack view edges
    static let longitudinalEdgeOffset: CGFloat = 8  // used for stack view cells offset from stack view edges
    
    //    static let color: UIColor =
}
