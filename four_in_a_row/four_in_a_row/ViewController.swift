//
//  ViewController.swift
//  four_in_a_row
//
//  Created by David Tan on 9/02/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UIViewController {
    
    var placedChips = [[UIView]]()  // this holds an array of columns, each containing an array of chips
    var board: Board!
    
    @IBOutlet var columnButtons: [UIButton]!
    
    var strategist: GKMinmaxStrategist!  // the strategist AI is slow, so it should be run on a background thread
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create the strategist
        strategist = GKMinmaxStrategist()
        strategist.maxLookAheadDepth = 7
        strategist.randomSource = nil  // this acts as a tie-breaker (when two moves are equally good): setting it to nil means "just return the first best move"
        // alternatively you can have the AI to take a random best move: strategist.randomSource = GKARC4RandomSource()
        
        for _ in 0 ..< Board.width {
            // populate placedChips with empty arrays to represent columns
            placedChips.append([UIView]())
        }
        
        // clear column arrays off any views that were added
        resetBoard()
    }
    
    func resetBoard() {
        // create a new game board
        board = Board()
        // feed the new game model (the new board) into the strategist
        strategist.gameModel = board
        
        updateUI()
        
        for i in 0 ..< placedChips.count {
            for chip in placedChips[i] {
                // remove chip from the view
                chip.removeFromSuperview()
            }
            
            // remove chips from the array
            placedChips[i].removeAll(keepingCapacity: true)
        }
    }
    
    // MARK: - setting chips
    
    func addChip(inColumn column: Int, row: Int, color: UIColor) {
        let button = columnButtons[column]
        let size = min(button.frame.width, button.frame.height / 6)
        let rect = CGRect(x: 0, y: 0, width: size, height: size)  // creates a rectangular frame
        
        // makes sure there is/are space(s) in the column to drop the chip
        if (placedChips[column].count < row + 1) {
            let newChip = UIView()
            newChip.frame = rect  // set chip's frame
            newChip.isUserInteractionEnabled = false  // disable user interaction so that: 1. tapping on a chip is ignored and 2. the tap is pass through to its column button
            newChip.backgroundColor = color
            newChip.layer.cornerRadius = size / 2  // make it a circle
            newChip.center = positionForChip(inColumn: column, row: row)  // set the position of the frame
            newChip.transform = CGAffineTransform(translationX: 0, y: -800)  // set the initial position of the chip 800 points up where it is supposed to be
            view.addSubview(newChip)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                newChip.transform = CGAffineTransform.identity  // clear any transformations assigned and reset the changes that have been applied to our chip view, effectively returning the chip to where it is supposed to be, except this time with animations
            })
            
            placedChips[column].append(newChip)
        }
    }
    
    func positionForChip(inColumn column: Int, row: Int) -> CGPoint {
        // pulls out the UIButton that represents the correct column
        let button = columnButtons[column]
        
        // sets the chip size to be either the width of the column button or the height of column button divided by six - whichever is the lowest
        let size = min(button.frame.width, button.frame.height / 6)
        
        // uses midX to get the horizontal center of the column button
        let xOffset = button.frame.midX
        
        // uses maxY to get the BOTTOM of the column button, then subtracts half the chip size because we want to work with the center of the chip
        var yOffset = button.frame.maxY - size / 2
        
        // multiplies the row by the size of each chip to figure out how far to offset the new chip, and subtracts that from the Y position calculated in previous step
        yOffset -= size * CGFloat(row)
        
        // creates a CGPoint representing the X and Y positions
        return CGPoint(x: xOffset, y: yOffset)
    }

    @IBAction func makeMove(_ sender: UIButton) {
        let column = sender.tag
        
        // find the next empty row within the column
        if let row = board.nextEmptySlot(in: column) {
            board.add(chip: board.currentPlayer.chip, in: column)  // update the model
            addChip(inColumn: column, row: row, color: board.currentPlayer.color)  // update the view
            continueGame()
        }
    }
    
    // MARK: - per turn actions
    
    func updateUI() {
        title = "\(board.currentPlayer.name)'s Turn"
        
        // call startAIMove() when it's black's turn
        if board.currentPlayer.chip == .black {
            startAIMove()
        }
    }
    
    // either switch players or show an alert when the game ends
    func continueGame() {
        // create a gameOverTitle optional string set to nil
        var gameOverTitle: String? = nil
        
        // if the game is over or the board is full, gameOverTitle is updated to include the relevant status message
        if board.isWin(for: board.currentPlayer) {
            gameOverTitle = "\(board.currentPlayer.name) Wins!"
        } else if board.isFull() {
            gameOverTitle = "Draw!"
        }
        
        // if gameOverTitle is not nil (ie the game is won or drawn) show an alert controller that resets the board when dismissed
        if gameOverTitle != nil {
            let alert = UIAlertController(title: gameOverTitle, message: nil, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Play Again", style: .default) { [unowned self] action in
                self.resetBoard()
            }
            
            alert.addAction(alertAction)
            present(alert, animated: true)
            
            return
        }
        
        // otherwise, change the current player of the game, then call updateUI() to set the navigation bar title
        board.currentPlayer = board.currentPlayer.opponent
        updateUI()
    }
    
    // MARK: - GKMinmaxStrategist methods
    
    func columnForAIMove() -> Int? {
        // this method should be called on the background thread
        // find the best move using bestMove(for:)
        if let aiMove = strategist.bestMove(for: board.currentPlayer) as? Move {
            return aiMove.column
        }
        
        // if no more available moves for the player, return nil
        return nil
    }
    
    func makeAIMove(in column: Int) {
        // this method should be called on the main thread
        
        columnButtons.forEach { $0.isEnabled = true }  // re-enable the column buttons
        navigationItem.leftBarButtonItem = nil  // destroy the thinking spinner
        
        if let row = board.nextEmptySlot(in: column) {
            board.add(chip: board.currentPlayer.chip, in: column)
            addChip(inColumn: column, row: row, color: board.currentPlayer.color)
            
            continueGame()
        }
    }
    
    func startAIMove() {
        // this method will:
        // 1. Dispatch some work to the background thread.
        // 2. Get the current time, then run columnForAIMove().
        // 3. Get the time again, compare the difference, and subtract that value from 1 second to form a delay value.
        // 4. Run makeAIMove(in:) on the main thread after that delay, to execute the move.
        
        // the delay value is needed so that the AI always waits at least one second before making its move (otherwise it might confuse the user)
        // the subtraction of time difference from 1 second gives us the amount of time that the AI needs to wait AFTER it has found the move, before making the move by adjusting UI
        // eg if the AI takes half a second to find a move, we subtract that from our one second minimum to wait for a further half a second, equalling one second in total before starting the AI to execute the move
        
        columnButtons.forEach { $0.isEnabled = false }  // disable the column buttons when the AI's move starts, so user cannot tap on the columns
        // the forEach keyword is a way of quickly looping through an array, executing some code on every item in that array
        
        let spinner = UIActivityIndicatorView(style: .medium)  // create a spinner to show that the AI is currently working
        spinner.startAnimating()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: spinner)
        
        DispatchQueue.global().async {
            [unowned self] in
            let strategistTime = CFAbsoluteTimeGetCurrent()
            guard let column = self.columnForAIMove() else { return }
            let delta = CFAbsoluteTimeGetCurrent() - strategistTime
            
            let aiTimeCeiling = 1.0
            let delay = aiTimeCeiling - delta
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.makeAIMove(in: column)
            }
        }
    }
    
    
}
// Three protocols required for GameplayKit AI to work:
// 1.GKGameModel: represents the state of play, which means it needs to know where all the game pieces are, who the players are, what happens after each move is made, and what the score for a player is given any state.
// 2. GKGameModelPlayer (conformed to by Player class): represents one player in the game, which means it needs your player class to have a playerId integer. It's used to identify a player uniquely inside the AI.
// 3. GKGameModelUpdate (conformed to by Move class): represents one possible move in the game. For us, that means storing a column number to represent a piece being played there. This protocol requires that you also store a value integer, which is used to rank all possible results by quality to help GameplayKit make a good choice.

// How the AI actually works:
// When you ask GameplayKit to find a move, it will examine all possible moves. To begin with, that is every column, because they all have space for moves in them. It then takes a copy of the game, and makes a virtual move on that copy. It then takes a copy of the game, and makes a different virtual move, and so on until until all initial first moves have been made.
// Next, it starts to re-use its copies to save on memory: it will take one of those copies and apply a game state to it, which means it will reset the board so that it matches the position after one of its virtual moves. It will then rinse and repeat: it will examine all possible moves, and make one. It does this for all moves, and does so recursively until it has created a tree of all possible moves and outcomes, or at least as many as you ask it to scan.
// Each time the AI has made a move, it will ask us what the player score is.
// Hence the reason why we have two separate models (classes) of nearly identical content (Board and ViewController classes) is because that the AI already needs to calculate a lot of moves for it to work (7x7x7x7x... in this case, because there are 7 columns). If we have the AI to work on the ViewController class as a whole (instead of a concise, separate Board class), every time it makes a copy of the model to simulate one move it will have to copy additional objects (the UIViews for chips in this case) that are unnecessary, which will slow down the AI.
// To sum things up: To simulate a move, GameplayKit takes copies of our board state, finds all possible moves that can happen, and applies them all on different copies.



