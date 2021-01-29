//
//  Capital.swift
//  Map
//
//  Created by David Tan on 15/12/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit
import MapKit

// Map annotations are described not as a class, but as a protocol, so we need to create a separate class in order to conform to the protocol
class Capital: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
}
