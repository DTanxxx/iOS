//
//  ViewController.swift
//  iBeacon
//
//  Created by David Tan on 13/01/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var beaconName: UILabel!
    @IBOutlet var distanceReading: UILabel!
    var locationManager: CLLocationManager?  // this object lets us configure how we want to be notified about location, and will also deliver location updates to us
    var detected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        view.backgroundColor = .gray
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        if let regionConstraints = locationManager?.rangedBeaconConstraints {
            regionConstraints.forEach { constraint in
                locationManager?.stopRangingBeacons(satisfying: constraint)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!  // convert a string into an UUID
        let beaconRegion = CLBeaconRegion(uuid: uuid, major: 123, minor: 456, identifier: "MyBeacon")
        let uuid2 = UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!
        let beaconRegion2 = CLBeaconRegion(uuid: uuid2, major: 123, minor: 4567, identifier: "MyBeacon2")
        let beaconRegions = [beaconRegion, beaconRegion2]
        beaconRegions.forEach { region in
            locationManager?.startMonitoring(for: region)
            locationManager?.startRangingBeacons(satisfying: region.beaconIdentityConstraint)
        }
    }
    
    func update(distance: CLProximity) {
        UIView.animate(withDuration: 1) {
            switch distance {
            case .far:
                self.view.backgroundColor = UIColor.blue
                self.distanceReading.text = "FAR"
                self.showAC()
            case .near:
                self.view.backgroundColor = UIColor.orange
                self.distanceReading.text = "NEAR"
                self.showAC()
            case .immediate:
                self.view.backgroundColor = UIColor.red
                self.distanceReading.text = "RIGHT HERE"
                self.showAC()
            default:
                self.view.backgroundColor = UIColor.gray
                self.distanceReading.text = "UNKNOWN"
                self.detected = false
            }
        }
    }
    
    func showAC() {
        if !detected {
            detected = true
            let ac = UIAlertController(title: "Detected a Beacon", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "YAY!!", style: .default))
            present(ac, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if let beacon = beacons.first {
            print("uuid: \(beacon.uuid.uuidString)")
        }
    }
    /*
    // With this method, we'll be given an array of beacons the location manager has found for a given region.
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        // MARK: - adjust below code
        // check the region uuid
        if region.minor == 456 {
            print("HI")
            if let beacon = beacons.first {
                beaconName.text = "AppleAirLocate 5A4BCFCE"
                update(distance: beacon.proximity)
            }
        } else if region.minor == 4567 {
            print("HELLO")
            if let beacon = beacons.first {
                beaconName.text = "AppleAirLocate E2C56DB5"
                update(distance: beacon.proximity)
            }
        } else {
            beaconName.text = "No beacon detected"
            update(distance: .unknown)
        }
    }*/
    
    
        
        
     
    
    

}
// How we actually range beacons:
// First, we use a new class called CLBeaconRegion, which is used to identify a beacon uniquely.
// Second, we give that to our CLLocationManager object by calling its startMonitoring(for:) and startRangingBeacons(in:) methods.
// Once that's done, we sit and wait. As soon as iOS has anything tell us, it will do so.

// iBeacons are identified using three pieces of information: a universally unique identifier (UUID), plus a major number and a minor number.
// The major number is used to subdivide within the UUID. So, if you have 10,000 stores in your supermarket chain, you would use the same UUID for them all but give each one a different major number.
// The minor number can be used to subdivide within the major number.




