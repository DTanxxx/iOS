//
//  GameScene.swift
//  Flip
//
//  Created by David Tan on 28/06/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var rows = [[Stone]]()
    var board: Board!
    var strategist: GKMonteCarloStrategist!
    
    override func didMove(to view: SKView) {
        board = Board()
        
        let background = SKSpriteNode(imageNamed: "background")
        background.blendMode = .replace  // because background image doesn't need alpha blending
        background.zPosition = 1
        addChild(background)
        
        let gameBoard = SKSpriteNode(imageNamed: "board")
        gameBoard.name = "board"
        gameBoard.zPosition = 2
        addChild(gameBoard)
        
        setUpStones(myBoard: gameBoard)
        setUpStrategist()
        
        rows[4][3].setPlayer(.white)
        rows[4][4].setPlayer(.black)
        rows[3][3].setPlayer(.black)
        rows[3][4].setPlayer(.white)
        
        board.rows[4][3] = .white
        board.rows[4][4] = .black
        board.rows[3][3] = .black
        board.rows[3][4] = .white
    }
    
    // we will create stones when the game starts, giving each of them a clear texture, to make tap detection easy
    func setUpStones(myBoard: SKSpriteNode) {
        // set up the constants for positioning
        // each stone is 80x80, the board is 640x640
        // since SpriteKit positions everything from the center of the parent, the left most stone will have x=-320+(80/2) and bottom most stone will have y=-320+(80/2)
        let offsetX = -280
        let offsetY = -281  // there is shadow on the stone graphics, so adjust y-offset accordingly
        let stoneSize = 80
        
        for row in 0 ..< Board.size {
            // count from 0 to 7, once for each row, creating a new array of stones for that row
            var colArray = [Stone]()
            
            for col in 0 ..< Board.size {
                // count from 0 to 7, once for each column, creating a new stone object with clear color 
                let stone = Stone(color: UIColor.clear, size: CGSize(width: stoneSize, height: stoneSize))
    
                // place the stone at the correct position
                stone.position = CGPoint(x: offsetX + (col * stoneSize), y: offsetY + (row * stoneSize))
                stone.zPosition = 3
                
                // tell the stone its row and column
                stone.row = row
                stone.col = col
                
                // add each stone to the game board and column array
                myBoard.addChild(stone)
                colArray.append(stone)
            }
            
            // add each column to the rows array
            rows.append(colArray)
            
            // also add to the Board object's rows array
            board.rows.append([StoneColor](repeating: .empty, count: Board.size))
            // the initialiser used creates an array of repeated elements
        }
    }
    
    // MARK: - initialising Monte Carlo strategist
    
    func setUpStrategist() {
        // the GKMonteCarloStrategist object has four properties that are of interest:
        /*
         1.  The budget property controls how many total moves the strategist should evaluate. Higher values help it find better results, but also slow things down.
         2.  The explorationParameter property is set to 4 by default, which means “focus as much on trying new things as focusing on moves that look good.” We’ll set this to 1, which means “when moves look good, follow them as far as you can.”
         3.  The randomSource property is way to generate random numbers, which is a central feature of the Monte Carlo algorithm.
         4.  The gameModel property stores the board it should look at to generate moves.
        */
        
        strategist = GKMonteCarloStrategist()
        strategist.budget = 100
        strategist.explorationParameter = 1
        strategist.randomSource = GKRandomSource.sharedRandom()
        strategist.gameModel = board
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // unwrap the first touch that was passed in
        guard let touch = touches.first else { return }
        
        // find the game board in the scene, or return if it somehow couldn't be found
        // note that we aren't checking whether board is present, but rather the game board, which is a SKSpriteNode
        // board is a model object, not the actual visual board sprite
        guard let gameBoard = childNode(withName: "board") else { return }
        
        // figure out where on the game board the touch landed
        let location = touch.location(in: gameBoard)
        
        // pull out an array of all SKNode objects at that touch point
        let nodesAtPoint = nodes(at: location)
        
        // filter out all nodes that aren't Stone nodes
        let tappedStones = nodesAtPoint.filter { $0 is Stone }
        
        // if no stone was tapped, bail out
        guard tappedStones.count > 0 else { return }
        
        let tappedStone = tappedStones[0] as! Stone
        
        // pass the tapped stone's row and column properties into our new canMoveIn() method
        if board.canMoveIn(row: tappedStone.row, col: tappedStone.col) {
            // if the move is legal, make the move
            makeMove(row: tappedStone.row, col: tappedStone.col)
            
            // hand control over to the AI when it's white's turn
            if board.currentPlayer.stoneColor == .white {
                makeAIMove()
            }
        } else {
            print("Move is illegal")
        }
    }
    
    func makeMove(row: Int, col: Int) {
        // find the list of captured stones
        let captured = board.makeMove(player: board.currentPlayer, row: row, col: col)
        
        for move in captured {
            // pull out the sprite for each captured stone
            let stone = rows[move.row][move.col]
            
            // update who owns it
            stone.setPlayer(board.currentPlayer.stoneColor)
            
            // make it 120% of its normal size
            stone.xScale = 1.2
            stone.yScale = 1.2
            
            // animate it down to 100%
            stone.run(SKAction.scale(to: 1, duration: 0.5))
        }
        
        // change players
        board.currentPlayer = board.currentPlayer.opponent
    }
    
    // MARK: - AI work
    
    func makeAIMove() {
        // push all work to a background thread so that the AI doesn't cause the game to freeze
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            // get the current time
            let strategistTime = CFAbsoluteTimeGetCurrent()
            
            // calculate the best AI move
            guard let move = self.strategist.bestMoveForActivePlayer() as? Move else { return }
            
            // use the previous time reading to figure out how much time the AI spent thinking
            let delta = CFAbsoluteTimeGetCurrent() - strategistTime
            
            // set the AI's chosen tile to the "thinking" texture -> push the work onto main thread
            DispatchQueue.main.async { [unowned self] in
                self.rows[move.row][move.col].setPlayer(.choice)
            }
            
            // wait for at least three seconds minus how long the AI took to think, so the AI will always appear to think for at least three seconds
            let aiTimeCeiling = 3.0
            let delay = min(aiTimeCeiling - delta, aiTimeCeiling)
            
            // after at least three seconds have passed, make the AI's move for real
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [unowned self] in
                self.makeMove(row: move.row, col: move.col)
            }
        }
    }
    
}
