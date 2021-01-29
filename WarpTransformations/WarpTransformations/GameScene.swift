//
//  GameScene.swift
//  WarpTransformations
//
//  Created by David Tan on 14/07/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var warpType = 0
    var spaceship: SKSpriteNode!
    var src = [
        // bottom row: left, center, right
        vector_float2(0.0, 0.0),
        vector_float2(0.5, 0.0),
        vector_float2(1.0, 0.0),
        
        // middle row: left, center, right
        vector_float2(0.0, 0.5),
        vector_float2(0.5, 0.5),
        vector_float2(1.0, 0.5),
        
        // top row: left, center, right
        vector_float2(0.0, 1.0),
        vector_float2(0.5, 1.0),
        vector_float2(1.0, 1.0)
    ]  // contains the source positions in the grid for default 2x2 warp transform that does nothing
    
    override func didMove(to view: SKView) {
        spaceship = SKSpriteNode(imageNamed: "Spaceship")
        addChild(spaceship)
        
        // apply a warp geometry to the spaceship, where the source and destination transforms are the same, so that when we actually want to warp the sprite, we can start from an existing warp transform and SpriteKit will be able to animate the change to another warp transform
        let warp = SKWarpGeometryGrid(columns: 2, rows: 2, sourcePositions: src, destinationPositions: src)
        spaceship.warpGeometry = warp
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // create a destination transform by copying the source transform
        var dst = src
        
        // this is where we'll be modifying the destination transform
        switch warpType {
        case 0:
            // stretch the nose up
            dst[7] = vector_float2(0.5, 1.5)
        case 1:
            // stretch the wings down
            dst[0] = vector_float2(0, -0.5)
            dst[2] = vector_float2(1, -0.5)
        case 2:
            // squash the ship vertically
            dst[0] = vector_float2(0.0, 0.25)
            dst[1] = vector_float2(0.5, 0.25)
            dst[2] = vector_float2(1.0, 0.25)
            
            dst[6] = vector_float2(0.0, 0.75)
            dst[7] = vector_float2(0.5, 0.75)
            dst[8] = vector_float2(1.0, 0.75)
        case 3:
            // flip it left to right
            dst[0] = vector_float2(1.0, 0.0)
            dst[2] = vector_float2(0.0, 0.0)
            
            dst[3] = vector_float2(1.0, 0.5)
            dst[5] = vector_float2(0.0, 0.5)
            
            dst[6] = vector_float2(1.0, 1.0)
            dst[8] = vector_float2(0.0, 1.0)
        default:
            break
        }
        
        // create a new warp geometry by mapping from src to dst
        let newWarp = SKWarpGeometryGrid(columns: 2, rows: 2, sourcePositions: src, destinationPositions: dst)
        
        // pull out the existing warp geometry so we have something to animate back to
        let oldWarp = spaceship.warpGeometry!
        
        // try to create an SKAction with these two warps; each will animate over 0.5 seconds (note that the array of times passed in is cumulative)
        if let action = SKAction.animate(withWarps: [newWarp, oldWarp], times: [0.5, 1]) {
            // run it on the spaceship sprite
            spaceship.run(action)
        }
        
        // add 1 to the warp type so that we get a different transformation next time
        warpType += 1
        
        // if we are higher than 3 warp back to 0
        if warpType > 3 {
            warpType = 0
        }
    }
    
}
