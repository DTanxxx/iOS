//
//  IntentHandler.swift
//  Extension
//
//  Created by David Tan on 15/05/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import Intents
import UIKit

class IntentHandler: INExtension, INListRideOptionsIntentHandling, INRequestRideIntentHandling, INGetRideStatusIntentHandling {
    
    // MARK: - the 'Handle' step
    
    // this method shows the list of available rides when someone is using Apple Maps
    func handle(intent: INListRideOptionsIntent, completion: @escaping (INListRideOptionsIntentResponse) -> Void) {
        let result = INListRideOptionsIntentResponse(code: .success, userActivity: nil)
        
        // each listed ride will be an INRideOption; there will be three rides
        // each INRideOption has a name and an estimated pick up date
        let mini = INRideOption(name: "Mini Cooper", estimatedPickupDate: Date(timeIntervalSinceNow: 1000))
        let accord = INRideOption(name: "Honda Accord", estimatedPickupDate: Date(timeIntervalSinceNow: 800))
        let ferrari = INRideOption(name: "Ferrari F430", estimatedPickupDate: Date(timeIntervalSinceNow: 300))
        ferrari.disclaimerMessage = "This is bad for the environment"
        
        // attach an expiration date to the "success" response code
        result.expirationDate = Date(timeIntervalSinceNow: 3600)
        // attach an array of INRideOptions to the "success" response code
        result.rideOptions = [mini, accord, ferrari]
        
        completion(result)
    }
    
    // this method allows user to create a ride when it has been requested using Apple Maps or Siri
    func handle(intent: INRequestRideIntent, completion: @escaping (INRequestRideIntentResponse) -> Void) {
        // this method is called when the user has picked out the ride they want and wants to confirm the booking and get the car
        
        // you need to create an INRideStatus object that represents the ride, and give it various options:
        /*
         - rideIdentifier: identifies the ride uniquely inside the app - if this changes, Maps assumes that the previous ride was either completed successfully or cancelled for some reason, and updates its UI
         - pickupLocation and dropOffLocation: provided by the two 'resolve' methods
         - phase: set to one of received, confirmed, ongoing, etc. depending on the state of the ride
         - estimatedPickupDate: provide an estimate of how long it will take for the car to arrive
         - vehicle: set to an instance of INRideVehicle, which describes the location of the car, and also where it currently is
         */
        
        // NOTE: you need to create and configure the INRideVehicle object fully before you assign it to the ride status
        
        let result = INRequestRideIntentResponse(code: .success, userActivity: nil)
        
        let status = INRideStatus()
        
        // this is our internal value that identifies the ride uniquely in our back-end system
        status.rideIdentifier = "abc123"
        
        // give it the pick up and drop off location we already agreed with the user
        status.pickupLocation = intent.pickupLocation
        status.dropOffLocation = intent.dropOffLocation
        
        // mark it as confirmed - we will deliver a ride
        status.phase = INRidePhase.confirmed
        
        // say we'll be there in 15 minutes
        status.estimatedPickupDate = Date(timeIntervalSinceNow: 900)
        
        // create a new vehicle and configure it fully
        let vehicle = INRideVehicle()
        
        // workaround: load the car image into UIImage, convert that into PNG data, then create an INImage out of that
        let image = UIImage(named: "car")!
        let data = image.pngData()!
        vehicle.mapAnnotationImage = INImage(imageData: data)
        
        // set the vehicle's current location to wherever the user wants to go - this ought to at least place it a little way away for testing purposes
        vehicle.location = intent.dropOffLocation!.location
        
        // now that we have configured the vehicle fully, assign it all at once to status.vehicle
        status.vehicle = vehicle
        
        // attach our finished INRideStatus object to the result
        result.rideStatus = status
        
        // and send it back
        completion(result)
    }
    
    // these methods provide metadata for a ride (eg where the driver is)
    // will not be implemented due to the need for real data
    func handle(intent: INGetRideStatusIntent, completion: @escaping (INGetRideStatusIntentResponse) -> Void) {
        // send a value back to iOS saying that everything is OK
        let result = INGetRideStatusIntentResponse(code: .success, userActivity: nil)  // the userActivity is sent to your app if the user requests to launch your app to get more info - you might send the booking ID in there so that the app can pick up where the extension left off
        completion(result)
    }
    
    func startSendingUpdates(for intent: INGetRideStatusIntent, to observer: INGetRideStatusIntentResponseObserver) {
    }
    
    func stopSendingUpdates(for intent: INGetRideStatusIntent) {
    }
    
    func handle(cancelRide intent: INCancelRideIntent, completion: @escaping (INCancelRideIntentResponse) -> Void) {
        let result = INCancelRideIntentResponse(code: .success, userActivity: nil)
        completion(result)
    }
    
    func handle(sendRideFeedback sendRideFeedbackintent: INSendRideFeedbackIntent, completion: @escaping (INSendRideFeedbackIntentResponse) -> Void) {
        let result = INSendRideFeedbackIntentResponse(code: .success, userActivity: nil)
        completion(result)
    }
    
    // MARK: - the 'Resolve' step (optional)
    
    func resolvePickupLocation(for intent: INRequestRideIntent, with completion: @escaping (INPlacemarkResolutionResult) -> Void) {
        // this method needs to either return success if we have a valid pick up location already, or request a valid one if nothing was provided
        let result: INPlacemarkResolutionResult
        
        if let requestedLocation = intent.pickupLocation {
            // we have a valid pick up location - return success
            result = INPlacemarkResolutionResult.success(with: requestedLocation)
        } else {
            // no pick up location yet; mark this as outstanding
            // this will trigger Siri to ask the user to provide a location
            result = INPlacemarkResolutionResult.needsValue()
        }
        
        completion(result)
    }
    
    func resolveDropOffLocation(for intent: INRequestRideIntent, with completion: @escaping (INPlacemarkResolutionResult) -> Void) {
        // similar to resolvePickupLocation(), except that we check the requested drop off location instead
        let result: INPlacemarkResolutionResult
        
        if let requestedLocation = intent.dropOffLocation {
            result = INPlacemarkResolutionResult.success(with: requestedLocation)
        } else {
            result = INPlacemarkResolutionResult.needsValue()
        }
        
        completion(result)
    }
    
    func resolvePartySize(for intent: INRequestRideIntent, with completion: @escaping (INIntegerResolutionResult) -> Void) {
        let result: INIntegerResolutionResult
        
        if let partySize = intent.partySize {
            result = INIntegerResolutionResult.success(with: partySize)
        } else {
            result = INIntegerResolutionResult.needsValue()
        }
        
        completion(result)
    }
    
    // MARK: - the 'Confirm' step (optional)
    
    func confirm(intent: INRequestRideIntent, completion: @escaping (INRequestRideIntentResponse) -> Void) {
        var result = INRequestRideIntentResponse(code: .success, userActivity: nil)
        
        // check for valid pick up location, drop off location, and party size
        guard let _ = intent.pickupLocation else {
            result = INRequestRideIntentResponse(code: .failure, userActivity: nil)
            completion(result)
            return
        }
        
        guard let _ = intent.dropOffLocation else {
            result = INRequestRideIntentResponse(code: .failure, userActivity: nil)
            completion(result)
            return
        }
        
        guard let _ = intent.partySize else {
            result = INRequestRideIntentResponse(code: .failure, userActivity: nil)
            completion(result)
            return
        }
    
        completion(result)
    }
}
/*
 Intents allow us to express what kind of action our code is capable of dealing with.
 
 Three steps to working with intents:
 1. Resolve: clarify you have enough data
 2. Confirm: report back that you’re ready to act on the user’s request
 3. Handle: act on the user’s request for real
 
 Only the Handle step is required: if you don’t need much data then the resolve step isn’t needed, and the confirm step is automatically handled well by Siri and Maps
 */

/*
 Apple groups all ride hailing types app functionality into three intent types:
 1. “List ride options”: responsible for showing the user what types of ride are available for them.
 2. “Request ride”: responsible for booking a specific ride when the user has decided exactly what they want.
 3. “Get ride status”: responsible for reporting back where the ride currently is. This would show the car getting steadily closer to the user before pick up, or part way on the route when the ride is in progress.
 
 All three intent types are grouped into a single protocol called INRidesharingDomainHandling
 
 Only 1 and 2 are implemented here - the third type will required real live data via a server
 */
