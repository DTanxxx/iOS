//
//  SceneDelegate.swift
//  White House Petition
//
//  Created by David Tan on 11/10/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // Our storyboard automatically creates a window in which all our view controllers are shown. This window needs to know what its initial view controller is, and that gets set to its rootViewController property. This is all handled by our storyboard.
        // In the Single View App template, the root view controller is the ViewController, but we embedded ours inside a navigation controller, then embedded that inside a tab bar controller. So, for us the root view controller is a UITabBarController.
        if let tabBarController = window?.rootViewController as? UITabBarController {
            
            // We need to create a new ViewController by hand, which first means getting a reference to our Main.storyboard file. This is done using the UIStoryboard class.
            // You don't need to provide a bundle, because nil means "use my current app bundle."
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // We create our view controller using the instantiateViewController() method, passing in the storyboard ID of the view controller we want. Earlier we set our navigation controller to have the storyboard ID of "NavController", so we pass that in.
            let vc = storyboard.instantiateViewController(identifier: "NavController")
            
            // We create a UITabBarItem object for the new view controller, giving it the "Top Rated" icon and the tag 1.
            vc.tabBarItem = UITabBarItem(tabBarSystemItem: .topRated, tag: 1)
            
            // We add the new view controller to our tab bar controller's viewControllers array, which will cause it to appear in the tab bar.
            tabBarController.viewControllers?.append(vc)
        }
        // So, the code creates a duplicate ViewController wrapped inside a navigation controller, gives it a new tab bar item to distinguish it from the existing tab, then adds it to the list of visible tabs.
        // This lets us use the same class for both tabs without having to duplicate things in the storyboard.
        // The reason we gave a tag of 1 to the new UITabBarItem is because it's an easy way to identify it. Remember, both tabs contain a ViewController, which means the same code is executed. Right now that means both will download the same JSON feed, which makes having two tabs pointless. But if you go and modify urlString in ViewController.swift’s viewDidLoad() method to...
        
        guard let _ = (scene as? UIWindowScene) else { return }
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

