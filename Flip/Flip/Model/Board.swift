//
//  Board.swift
//  Flip
//
//  Created by David Tan on 28/06/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import GameplayKit

// the Board class keeps track of the actual state of the board (compared to GameScene, which only gives a visual representation of the state of play)
// this Board model is needed because when we apply AI, it works by producing lots of copies of the board -> if we can have a board model that is separate from the GameScene, where SpriteKit views are, we can make the AI faster since the board model would be light
class Board: NSObject, GKGameModel {
    static let size = 8
    static let moves = [
        Move(row: -1, col: -1), Move(row: 0, col: -1), Move(row: 1, col: -1), Move(row: -1, col: 0), Move(row: 1, col: 0), Move(row: -1, col: 1), Move(row: 0, col: 1), Move(row: 1, col: 1)
    ]  // used to check whether a move is able to capture a piece
    
    var rows = [[StoneColor]]()
    var currentPlayer = Player.allPlayers[0]
    
    // GameplayKit requires our board to have an array called 'players' that holds an optional array of GKGameModelPlayer objects -> we can make 'players' a computed property that maps to Player.allPlayers array
    var players: [GKGameModelPlayer]? {
        return Player.allPlayers
    }
    // GameplayKit also expects to see a property called activePlayer that returns an optional GKGameModelPlayer object -> again we can make it a computed property that returns the currentPlayer
    var activePlayer: GKGameModelPlayer? {
        return currentPlayer
    }
    
    func canMoveIn(row: Int, col: Int) -> Bool {
        // test 1: check move is sensible
        if !isInBounds(row: row, col: col) { return false }
        
        // test 2: check move hasn't been made already
        let stone = rows[row][col]
        if stone != .empty { return false }
        
        // test 3: check the move is legal -> have to capture at least one stone with the move
        if !willCapture(row: row, col: col) { return false }
        
        return true
    }
    
    // check if the move is within the bounds of the board
    func isInBounds(row: Int, col: Int) -> Bool {
        if row < 0 { return false }
        if col < 0 { return false }
        if row >= Board.size { return false }
        if col >= Board.size { return false }
        
        return true
    }
    
    // check if the move will capture at least one piece
    // this method will work by looping through all possible move directions (stored in moves array) and extend each direction in a straight line to the edge of the board
    // during the extension, we will check for the presence of any enemy pieces that are about to be sandwiched between current player's pieces
    func willCapture(row: Int, col: Int) -> Bool {
        // loop through each possible move
        for move in Board.moves {
            // create a variable to track whether we have passed at least one opponent stone
            var passedOpponent = false
            
            // set movement variables containing our initial row and column
            var currentRow = row
            var currentCol = col
            
            // count from here up to the edge of the board, applying our move each time
            for _ in 0 ..< Board.size {
                // add the move to our movement variables
                currentRow += move.row
                currentCol += move.col
                
                // if our new position is off the board, break out of the loop
                guard isInBounds(row: currentRow, col: currentCol) else { break }
                
                let stone = rows[currentRow][currentCol]
                
                if (stone == currentPlayer.opponent.stoneColor) {
                    // we found an enemy stone
                    passedOpponent = true
                } else if stone == currentPlayer.stoneColor && passedOpponent {
                    // we found one of our stones after finding an enemy stone
                    return true
                } else {
                    // we found something else; break out of the loop for the current move direction
                    break
                }
            }
        }
        
        // if we are still here it means we failed
        return false
    }
    
    // MARK: - after the game works, try replacing every 'player' in this method with 'currentPlayer' and see if it works the same
    // logic similar to willCapture()
    func makeMove(player: Player, row: Int, col: Int) -> [Move] {
        // create an array to hold all captured stones
        var didCapture = [Move]()
        
        // place a stone in the requested position and add it to the didCapture array
        rows[row][col] = player.stoneColor
        didCapture.append(Move(row: row, col: col))
        
        // go through each direction and create movement variables from it, as well as a mightCapture array to handle possible captures in this direction
        for move in Board.moves {
            // look in this direction for captured stones
            var mightCapture = [Move]()
            var currentRow = row
            var currentCol = col
            
            // count from here up to the edge of the board, applying our move each time
            for _ in 0 ..< Board.size {
                currentRow += move.row
                currentCol += move.col
                
                // make sure this is a sensible position to move to
                guard isInBounds(row: currentRow, col: currentCol) else { break }
                
                let stone = rows[currentRow][currentCol]
                
                if stone == player.opponent.stoneColor {
                    // we found an enemy stone - add it to the list of possible captures
                    mightCapture.append(Move(row: currentRow, col: currentCol))
                } else if stone == player.stoneColor {
                    // we found one of our stones - add the entire mightCapture array to didCapture
                    didCapture.append(contentsOf: mightCapture)
                    
                    // change all stones in mightCapture array to the player's color, then exit the loop because we are finished in this direction
                    mightCapture.forEach {
                        rows[$0.row][$0.col] = player.stoneColor
                    }
                    
                    break
                } else {
                    // we found something else, eg a gap on the board; bail out without flipping stones in mightCapture
                    break
                }
            }
        }
        
        // send back the list of captured stones
        return didCapture
    }
    
    // MARK: - methods for GameplayKit AI logic
    
    func getScores() -> (black: Int, white: Int) {
        // this method counts the number of black and white stones and returns those counts as a tuple
        var black = 0
        var white = 0
        
        rows.forEach {
            $0.forEach {
                if $0 == .black {
                    black += 1
                } else if $0 == .white {
                    white += 1
                }
            }
        }
        
        return (black, white)
    }
    
    // as GameplayKit examines each move, it will ask us whether we consider it a win for a specific player
    // for now, we will report a game as a win if the AI is at least 10 points ahead of the player
    
    // when GameplayKit asks us whether a move is a win, it will pass in a GKGameModelPlayer instance
    // we need then to typecast this instance to Player, since Player class has already conformed to GKGameModelPlayer protocol
    func isWin(for player: GKGameModelPlayer) -> Bool {
        guard let player = player as? Player else { return false }
        
        let scores = getScores()
        
        if player.stoneColor == .black {
            return scores.black > scores.white + 10
        } else {
            return scores.white > scores.black + 10
        }
    }
    
    // we need to also provide the AI with every possible legal move for it to choose from
    // if there are no moves available, the game would be over and method should return nil
    // if isWin() reports true, the method should also return nil since we have already found a good enough move to go with
    // we can find a list of all possible moves by looping through every column in every row and calling canMoveIn() on it
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        // safely unwrap the player object
        guard let playerObject = player as? Player else { return nil }
        
        // if the game is over exit now
        if isWin(for: playerObject) || isWin(for: playerObject.opponent) {
            return nil
        }
        
        // if we are still here prepare to send back a list of moves
        var moves = [Move]()
        
        // try every column in every row
        for row in 0 ..< Board.size {
            for col in 0 ..< Board.size {
                if canMoveIn(row: row, col: col) {
                    // this move is possible; add it to the list
                    moves.append(Move(row: row, col: col))
                }
            }
        }
        
        return moves
    }  // note the return value type is an array of GKGameModelUpdate -> we have made Move class to conform to GKGameModelUpdate protocol, hence an object of type Move is also of type GKGameModelUpdate -> here we essentially return a list of Move objects
    
    // once we have given GameplayKit a list of possible moves, it will start trying them all
    // it will pick one of the moves it wants to explore and ask us to make that move -> we can make the move by calling makeMove()
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        guard let move  = gameModelUpdate as? Move else { return }
        
        _ = makeMove(player: currentPlayer, row: move.row, col: move.col)
        currentPlayer = currentPlayer.opponent  // switch players after each move
    }
    
    // MARK: - methods for copying the game board
    
    // we need to handle the case where GameplayKit reuses an existing Board object (purpose of which is to save memory)
    func setGameModel(_ gameModel: GKGameModel) {
        guard let board = gameModel as? Board else { return }
        
        // GameplayKit requires us to set our current state to be the same as the board it passed us, effectively reusing this current board for the board passed in
        currentPlayer = board.currentPlayer
        rows = board.rows
    }
    
    // we need to also handle the case where GameplayKit creates a full copy of a Board object, rather than reusing one
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Board()
        copy.setGameModel(self)  // we need to set the state of the Board copy the same as the state of the Board object it copied from (otherwise it will just be a default Board object)
        return copy
    }
}
