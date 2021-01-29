//
//  SceneDelegate.swift
//  Alarmadillo
//
//  Created by David Tan on 27/05/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let center = UNUserNotificationCenter.current()
        
        if let navController = window?.rootViewController as? UINavigationController {
            if let viewController = navController.viewControllers[0] as? ViewController {
                // if we're here, it means we found our active 'ViewController' object
                // set our ViewController as the delegate for user notification center, so when alerts come in they will get handled by ViewController object
                center.delegate = viewController as UNUserNotificationCenterDelegate
            }
        }
        
        // create the three actions we want for our alert
        // show = launch the app in the foreground and take user to the group that triggered the alarm
        let show = UNNotificationAction(identifier: "show", title: "Show Group", options: .foreground)  // the 'identifier' parameter tells you which button was tapped
        
        // destroy = destroy the group that created the alarm and would require user to unlock the device
        let destroy = UNNotificationAction(identifier: "destroy", title: "Destroy Group", options: [.destructive, .authenticationRequired])
        
        // rename = require user to enter a new name for the group
        let rename = UNTextInputNotificationAction(identifier: "rename", title: "Rename Group", options: [], textInputButtonTitle: "Rename", textInputPlaceholder: "Type the new name here")
        
        let removePicture = UNNotificationAction(identifier: "removePicture", title: "Remove Picture", options: [.destructive, .authenticationRequired])
        
        // wrap the actions inside a category -> the 'identifier' parameter needs to match the content.categoryIdentifier in ViewController class
        let category = UNNotificationCategory(identifier: "alarm", actions: [show, rename, destroy], intentIdentifiers: [], options: [.customDismissAction])
        // 'intentIdentifiers' are used to hook to SiriKit; 'options' .customDismissAction requests that you be notified when the user dismisses your notification
        
        let categoryForAlarmsWithPictures = UNNotificationCategory(identifier: "alarmWithPictures", actions: [show, rename, removePicture, destroy], intentIdentifiers: [], options: [.customDismissAction])
        
        // register the category with the system
        center.setNotificationCategories([category, categoryForAlarmsWithPictures])
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

