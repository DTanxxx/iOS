//
//  GameScene.swift
//  Challenge 7
//  Objective: create three rows on the screen, then have targets slide across from one side to the other. If the user taps a target, make it fade out and award them points.
//  Created by David Tan on 18/12/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // array of row nodes
    
    // int of bullets per clip
    
    override func didMove(to view: SKView) {
        // add background node and set name
        
        // create three nodes for three rows, with names indicating whether its on top/bottom or middle
        
        // create score label
        
        // create timer--creates target during intervals
        
        // create timer2--counts down from 60s
        
    }
    
    func createTarget() {
        // create target object for random row
        
        // target method: create node
        
        // target method: move from one end to the other
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // get node tapped
        
        // check the name
        
        // if targert node: called fade out method and remove node, if target==bad or good play respective sound files (yes create those as well--or use whack penguin's
        
        // if background node: if bullets==0 reload back to 6 and create sound file and play the file for reload noise and delay for some time--should not be able to tap target during this time
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // target method: remove node once past certain point
        
    }
    
    
}
