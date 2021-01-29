//
//  Board.swift
//  four_in_a_row
//
//  Created by David Tan on 9/02/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import GameplayKit

// represent the current state of each slot
enum ChipColor: Int {
    case none = 0
    case red
    case black
    // note: since you have assigned the first value 'case none' to 0, Swift will assign the following values an auto-incremented number - red = 1, black = 2
}

class Board: NSObject, GKGameModel {
    
    static var width = 7
    static var height = 6
    
    var slots = [ChipColor]()  // creates a one-dimensional array to store slots - although less easy to work with, it is a lot faster to use
    var currentPlayer: Player
    
    // properties required by GKGameModel protocol:
    var players: [GKGameModelPlayer]? {
        return Player.allPlayers
    }
    
    var activePlayer: GKGameModelPlayer? {
        return currentPlayer
    }
    
    override init() {
        currentPlayer = Player.allPlayers[0]
        
        for _ in 0 ..< Board.width * Board.height {
            slots.append(.none)
        }
        
        super.init()
    }
    
    // reads the chip color of a specific slot
    func chip(inColumn column: Int, row: Int) -> ChipColor {
        // note that the slots are counted vertically - that is, counting one column from bottom up, then count another column from bottom up
        return slots[row + column * Board.height]
    }
    
    // sets the chip color of a specific slot
    func set(chip: ChipColor, in column: Int, row: Int) {
        slots[row + column * Board.height] = chip
    }
    
    // determines whether player can make a move in a column
    func canMove(in column: Int) -> Bool {
        return nextEmptySlot(in: column) != nil
    }
    
    // returns the row number of the next empty slot
    func nextEmptySlot(in column: Int) -> Int? {
        for row in 0 ..< Board.height {
            if chip(inColumn: column, row: row) == .none {
                return row
            }
        }
        
        return nil
    }
    
    // adds a chip to a column at the next available space.
    func add(chip: ChipColor, in column: Int) {
        if let row = nextEmptySlot(in: column) {
            set(chip: chip, in: column, row: row)
        }
    }
    
    // MARK: - game state determinants
    
    // a draw
    func isFull() -> Bool {
        for column in 0 ..< Board.width {
            if canMove(in: column) {
                return false
            }
        }
        
        return true
    }
    
    // a win
    func isWin(for player: GKGameModelPlayer) -> Bool {
        // this will loop through every slot and call squaresMatch(initialChip:) four times for each slot (for each type of win arrangement), this way squaresMatch will only have to take care of checking arrangements in one direction (eg only need to check in the left direction for horizontal win)
        
        let chip = (player as! Player).chip
        for row in 0 ..< Board.height {
            for col in 0 ..< Board.width {
                // horizontal win: X movement=1 and Y movement=0
                if squaresMatch(initialChip: chip, row: row, col: col, moveX: 1, moveY: 0) {
                    return true
                }
                // vertical win: X movement=0 and Y movement=1
                else if squaresMatch(initialChip: chip, row: row, col: col, moveX: 0, moveY: 1) {
                    return true
                }
                // diagonal wins: X movement=1 and Y movement=1, or X movement=-1 and Y movement=-1
                else if squaresMatch(initialChip: chip, row: row, col: col, moveX: 1, moveY: 1) {
                    return true
                }
                else if squaresMatch(initialChip: chip, row: row, col: col, moveX: 1, moveY: -1) {
                    return true
                }
            }
        }
        return false
    }
    
    // check for a win arrangement
    func squaresMatch(initialChip: ChipColor, row: Int, col: Int, moveX: Int, moveY: Int) -> Bool {
        // if try to search outside of board bounds, return false
        if row + (moveY * 3) < 0 { return false }
        if row + (moveY * 3) >= Board.height { return false }
        if col + (moveX * 3) < 0 { return false }
        if col + (moveX * 3) >= Board.width { return false }
        
        // now we can check every square; if color does not match, return false
        if chip(inColumn: col, row: row) != initialChip { return false}
        if chip(inColumn: col + moveX, row: row + moveY) != initialChip { return false }
        if chip(inColumn: col + (moveX * 2), row: row + (moveY * 2)) != initialChip { return false }
        if chip(inColumn: col + (moveX * 3), row: row + (moveY * 3)) != initialChip { return false }
        
        return true
    }
    
    func isGoodMove() {
        // MARK: - try to find a good move
        
        // restrict the number of slots from centre for the first 5 moves (set a score)
        
        // restrict the total number of moves (as move number increases, increment the score -- do i need to reset it to 0 ??)
        
        
        
        
        
        
        
    }
    
    // MARK: - GKGameModel methods
    
    // copy the current board in order to evaluate various moves
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Board()  // create a copy of Board object
        copy.setGameModel(self)  // apply a game state to this copy
        return copy
    }
    
    // apply a game state to the copy so that the copy's board is reset so it matches the position after one of GameplayKit's moves
    func setGameModel(_ gameModel: GKGameModel) {
        if let board = gameModel as? Board {
            slots = board.slots  // apply the new slots array (which contains a move generated by GameplayKit) to the copy's slots array (so essentially the slot data is copied across from AI's move to the copy of the current board)
            currentPlayer = board.currentPlayer  // set the active player
        }
    }
    
    // tell GameplayKit all the possible moves that can be made on the copy of board
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        // how it works: If isWin(for:) is true either for the player or their opponent we return nil; if not, we call canMove(in:) for every column to see if the AI can move in each column. If so, we create a new Move object to represent that column, and add it to an array of possible moves.
        
        // 1. We optionally downcast our GKGameModelPlayer parameter into a Player object.
        if let playerObject = player as? Player {
            // 2. If the player or their opponent has won, return nil to signal no moves are available.
            if isWin(for: playerObject) || isWin(for: playerObject.opponent) {
                return nil
            }
        
            // 3. Otherwise, create a new array that will hold Move objects.
            var moves = [Move]()
        
            // 4. Loop through every column in the board, asking whether the player can move in that column.
            for column in 0 ..< Board.width {
                if canMove(in: column) {
                    // 5. If so, creata a new Move object for that column, and add it to the array.
                    moves.append(Move(column: column))
                }
            }
    
            // 6. Finally, return the array to tell the AI all the possible moves it can make.
            return moves
        }
        
        return nil
    }
    
    // ask the AI to try the array of moves returned
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        // this method is called once for every move, on a copy of the game board that reflects the current state of play after its virtual moves
        
        if let move = gameModelUpdate as? Move {
            add(chip: currentPlayer.chip, in: move.column)  // make the move
            currentPlayer = currentPlayer.opponent  // change players
            
            
            // MARK: - set the move property, so it can be used in isGoodMove() method
            
            
            
            
            
        }
    }
    
    // tell the AI whether a move is good or not by providing a player score after each of its move: this is the heuristic function
    func score(for player: GKGameModelPlayer) -> Int {
        if let playerObject = player as? Player {
            if isWin(for: playerObject) {
                return 1000
            } else if isWin(for: playerObject.opponent) {
                return -1000
            }
        }
        
        return 0
    }
    
    
}
// NSCoding is used to encoding and decode objects so that they can be archived, such as when you're writing to UserDefaults. This is good for when you want to save or distribute your data, but it's not very efficient if you just want to copy it.
// NSCopying: it's a protocol that lets iOS take a copy of your object in memory, with the copy being identical but separate to the original. This is needed since GameplayKit will be taking a lot of copies of our game board.



