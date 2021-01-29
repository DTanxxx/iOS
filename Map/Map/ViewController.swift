//
//  ViewController.swift
//  Map
//
//  Created by David Tan on 15/12/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(changeType))
        
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics.")
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.")
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Light.")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.")
        let washington = Capital(title: "Washington, D.C.", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude:-77.036667), info: "Named after George himself.")
        mapView.addAnnotations([london, oslo, paris, rome, washington])
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // If the annotation isn't from a capital city, it must return nil so iOS uses a default view.
        guard annotation is Capital else { return nil }
        
        // Define a reuse identifier. This is a string that will be used to ensure we reuse annotation views as much as possible.
        let identifier = "Capital"
        
        // Try to dequeue an annotation view from the map view's pool of unused views.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            // If it isn't able to find a reusable view, create a new one using MKPinAnnotationView and sets its canShowCallout property to true. This triggers the popup with the city name.
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.pinTintColor = UIColor(red: 0, green: 0, blue: 1.0, alpha: 1)
            annotationView?.canShowCallout = true
            
            // Create a new UIButton using the built-in .detailDisclosure type. This is a small blue "i" symbol with a circle around it.
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
            // Note: you don't need to use addTarget() to add an action to the button, because you'll automatically be told by the map view using a calloutAccessoryControlTapped method.
            // When this method is called, you'll be told what map view sent it (we only have one, so that's easy enough), what annotation view the button came from (this is useful), as well as the button that was tapped.
        } else {
            // If it can reuse a view, update that view to use a different annotation.
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let capital = view.annotation as? Capital else { return }
        let placeName = capital.title
        let placeInfo = capital.info
        
        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Return", style: .cancel))
        ac.addAction(UIAlertAction(title: "More Info", style: .default, handler: { [weak self] action in
            // create a new vc
            if let webVC = self?.storyboard?.instantiateViewController(withIdentifier: "WebVC") as? WebViewController {
                webVC.placeName = placeName
                self?.navigationController?.pushViewController(webVC, animated: true)
            }
        }))
        present(ac, animated: true)
    }
    
    @objc func changeType() {
        let ac = UIAlertController(title: "Change Map Type", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Satellite", style: .default, handler: { [weak self] action in
            self?.mapView.mapType = .satellite
        }))
        ac.addAction(UIAlertAction(title: "Standard", style: .default, handler: { [weak self] action in
            self?.mapView.mapType = .standard
        }))
        ac.addAction(UIAlertAction(title: "Hybrid", style: .default, handler: { [weak self] action in
            self?.mapView.mapType = .hybrid
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

}

