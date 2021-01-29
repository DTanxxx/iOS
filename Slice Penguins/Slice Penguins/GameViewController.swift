//
//  GameViewController.swift
//  Slice Penguins
//
//  Created by David Tan on 6/01/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    @IBOutlet var restartButton: UIButton!
    var gameScene: GameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                
                // MARK: - hide button
                gameScene = scene as? GameScene
                gameScene.viewController = self
                restartButton.isHidden = true
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func restartTapped(_ sender: Any) {
        // create a new scene
        let newGame = GameScene(size: gameScene.size)
        newGame.viewController = self
        
        // create a transition between scenes that takes place when the game ends
        let transition = SKTransition.doorway(withDuration: 1.5)
        gameScene.view?.presentScene(newGame, transition: transition)
        
        gameScene = newGame
        restartButton.isHidden = true
    }
}
