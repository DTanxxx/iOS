//
//  CGVector+Extension.swift
//  Chemmy
//
//  Created by David Tan on 15/08/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

extension CGVector {
    func speed() -> CGFloat {
        return sqrt(dx*dx + dy*dy)
    }
    
    func angle() -> CGFloat {
        return atan2(dy, dx)
    }
}
