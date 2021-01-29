//
//  GameScene.swift
//  DeadStormRising
//
//  Created by David Tan on 4/07/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import SpriteKit

enum Player {
    case none, red, blue
}

// we need to have different z positions for various sprite nodes in our game
// we use an enum so that these values can be available everywhere in the program
enum zPositions {
    // rather than the usual ': int' or ': CGFloat' after the namespace (the enum name) for our access to rawValue, we won't be using rawValue (since it's messy) and instead we will create several constants in the enum representing the different z positions for the things we want to display
    static let base: CGFloat = 10  // bases are the lowest thing
    static let bullet: CGFloat = 20  // bullets are next up
    static let unit: CGFloat = 30  // tanks are above bullets
    static let smoke: CGFloat = 40  // smoke used for explosions -- above tanks
    static let fire: CGFloat = 50  // fire used for explosions -- above smoke
    static let selectionMarker: CGFloat = 60  // selection marker will be used to draw a reticule over the unit the player tapped
    static let menuBar: CGFloat = 100  // above everything else
}

class GameScene: SKScene {
    
    var lastTouch = CGPoint.zero  // used to track movement inside touchesMoved()
    var originalTouch = CGPoint.zero  // used to compare where the touch started and where it ended, so we can figure out whether user tapped the screen or was just moving around
    var cameraNode: SKCameraNode!  // used to hold the SKCameraNode created in scene editor
    
    var currentPlayer = Player.red
    var units = [Unit]()  // stores all units in the game, until they get destroyed
    var bases = [Base]()  // stores all bases in the game
    var selectedItem: GameItem? {  // tracks which GameItem instance is selected
        didSet {
            // we use a property observer to change the selectionMarker every time the selectedItem property is changed
            selectedItemChanged()
        }
    }
    var selectionMarker: SKSpriteNode!  // holds the sprite that highlights which game item is selected
    var moveSquares = [SKSpriteNode]()  // stores all the squares that show where the selected unit can move (we'll re-use these)
    
    var menuBar: SKSpriteNode!  // holds the menubar itself -> a translucent black triangle
    var menuBarPlayer: SKSpriteNode!  // holds the name of the current player
    var menuBarEndTurn: SKSpriteNode!  // holds a button saying "End Turn" in either red or blue
    var menuBarCapture: SKSpriteNode!  // holds a button saying "Capture" that will appear when a unit is able to capture a base
    var menuBarBuild: SKSpriteNode!  // holds a button saying "Build" when a base is selected and can build a new unit
    
    override func didMove(to view: SKView) {
        // assign the existing camera property to cameraNode so that we don't need to continually unwrap something we know will be there
        cameraNode = camera!
        
        createStartingLayout()
        createMenuBar()
        
        // create the selectionMarker sprite
        selectionMarker = SKSpriteNode(imageNamed: "selectionMarker")
        selectionMarker.zPosition = zPositions.selectionMarker
        addChild(selectionMarker)
        hideSelectionMarker()
        
        // fill in the moveSquares array
        for _ in 0 ..< 41 {
            // given that each unit can move a Manhattan Distance up to 4 units (eg left 4, right 4, right 3 down 1...), there are 41 squares which a unit can move to including the one currently occupied by the unit
            // each move square will initially be a white square
            let moveSquare = SKSpriteNode(color: UIColor.white, size: CGSize(width: 64, height: 64))
            moveSquare.alpha = 0
            moveSquare.name = "move"
            moveSquares.append(moveSquare)
            addChild(moveSquare)
        }
    }
    
    // this method will set up the initial units
    func createStartingLayout() {
        for i in 0 ..< 5 {
            // create five red tanks
            let unit = Unit(imageNamed: "tankRed")
            
            // mark them as owned by red
            unit.owner = .red
            
            // position them neatly
            unit.position = CGPoint(x: -128 + (i * 64), y: -320)
            
            // give them the correct z position
            unit.zPosition = zPositions.unit
            
            // add them to the 'units' array for easy look up
            units.append(unit)
            
            // add them to the SpriteKit scene
            addChild(unit)
        }
        
        for i in 0 ..< 5 {
            // create five blue tanks
            let unit = Unit(imageNamed: "tankBlue")
            unit.owner = .blue
            unit.position = CGPoint(x: -128 + (i * 64), y: -128)
            unit.zPosition = zPositions.unit
            
            // these are rotated 180 degrees, so that they face downwards
            unit.zRotation = CGFloat.pi
            
            units.append(unit)
            addChild(unit)
        }
        
        // create nine bases in a 3x3 grid
        for row in 0 ..< 3 {
            for col in 0 ..< 3 {
                let base = Base(imageNamed: "base")
                base.position = CGPoint(x: -256 + (col * 256), y: -64 + (row * 256))
                base.zPosition = zPositions.base
                bases.append(base)
                addChild(base)
            }
        }
    }
    
    func createMenuBar() {
        // create a translucent black menu bar, positioned near the top
        menuBar = SKSpriteNode(color: UIColor(white: 0, alpha: 0.66), size: CGSize(width: 1024, height: 60))
        menuBar.position = CGPoint(x: 0, y: 354)
        menuBar.zPosition = zPositions.menuBar
        cameraNode.addChild(menuBar)  // the menuBar sprite is added as a child to cameraNode -- this means it will stay fixed even when the user scrolls
          
        // add the "Red's Turn" sprite to the top-left corner
        menuBarPlayer = SKSpriteNode(imageNamed: "red")
        menuBarPlayer.anchorPoint = CGPoint(x: 0, y: 0.5)  // adjust the anchorPoint property so that we can align it to the left
        menuBarPlayer.position = CGPoint(x: -512 + 20, y: 0)
        menuBar.addChild(menuBarPlayer)
        
        // add the red "End Turn" sprite to the top-right corner
        menuBarEndTurn = SKSpriteNode(imageNamed: "redEndTurn")
        menuBarEndTurn.anchorPoint = CGPoint(x: 1, y: 0.5)  // align it to the right
        menuBarEndTurn.position = CGPoint(x: 512 - 20, y: 0)
        menuBarEndTurn.name = "endturn"  // give the button an unique name, which we can identify to let us do tap detection
        menuBar.addChild(menuBarEndTurn)
        
        // add the "Capture" button to the center of the menu bar
        menuBarCapture = SKSpriteNode(imageNamed: "capture")
        menuBarCapture.position = CGPoint(x: 0, y: 0)
        menuBarCapture.name = "capture"
        menuBar.addChild(menuBarCapture)
        hideCaptureMenu()
        
        // add the "Build" button to the center of the menu bar
        menuBarBuild = SKSpriteNode(imageNamed: "build")
        menuBarBuild.position = CGPoint(x: 0, y: 0)
        menuBarBuild.name = "build"
        menuBar.addChild(menuBarBuild)
        hideBuildMenu()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // pull out the touch
        guard let touch = touches.first else { return }
        
        // figure out its location in the SKView and assign that to both lastTouch and originalTouch - the former will change every time touchesMove() is called; the latter won't change until touchesBegan() is called again
        // this way we can check whether user has tapped the screen or has moved around
        lastTouch = touch.location(in: self.view)
        originalTouch = lastTouch
    }
    
    // MARK: - Moving camera
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // same as in touchesBegan(), we find the touch location in the SKView, which is important because SKView is the thing that contains our game scene, not the game scene itself, therefore the touch location is calculated using UIKit axes (where y=0 is at the top of screen), not SpriteKit axes
        // the reason we read from the SKView and not the game scene is that as the camera moves, so does its position in the game scene (hence a change in x of 50 units on the screen does not correspond to change in x of 50 units on the game scene), so we will get entirely wrong results from reading the scene location
        let touchLocation = touch.location(in: self.view)
        
        // MARK: - UIKit vs SpriteKit Y axes
        
        // SpriteKit counts up from the bottom; UIKit counts down from the top
        // so, to calculate the X position we subtract the current touch location from the previous one, in order to create the "dragging" effect of the scene (the scene location does not change, it's the camera that is moving in opposite direction)
        let newX = cameraNode.position.x + (lastTouch.x - touchLocation.x)
        // however, to calculate Y, we subtract the previous touch location from the current one, so that the change in y-distance is positive (UIKit axis) when we drag downwards and we can add that to the camera's current position (so that camera moves upwards -> SpriteKit axis, creating a scene being dragged downwards effect)
        let newY = cameraNode.position.y + (touchLocation.y - lastTouch.y)
        
        // change cameraNode's position using new coordinates
        cameraNode.position = CGPoint(x: newX, y: newY)
        
        // update the lastTouch property with the new touch position
        lastTouch = touchLocation
    }
    
    // MARK: - Selecting game items
    
    // this method is called when the touch finishes and we are ready to figure out whether the player has tapped or swiped around on the screen
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // call touchesMoved() to ensure we have the very latest information for the touch and camera position
        touchesMoved(touches, with: event)
        
        // use manhattanDistance() method to calculate the distance between the user's original touch and their final touch, and if that's less than a certain threshold (44 in this case) then pass the touch on to nodesTapped() -- we have identified the player as having tapped the screen since their final touch is near their original touch
        let distance = originalTouch.manhattanDistance(to: lastTouch)
        
        if distance < 44 {
            nodesTapped(at: touch.location(in: self))  // note that here we are passing in 'self' as argument to touch.location(in:), rather than 'self.view', because the location passed into nodesTapped() must be the touch’s position in the game scene, not in the SKView (ie the screen) –- we need to know what the user tapped, rather than caring about relative movement
        }
    }
    
    // when this method is called, we can be sure that the user has tapped on the screen rather than moving around and accidentally triggering something, therefore at this point we need to carry out our selection logic
    func nodesTapped(at point: CGPoint) {
        // get an array of all VISIBLE nodes at the position that was tapped (therefore if a node is hidden i.e. alpha=0 then it won't be returned)
        let tappedNodes = nodes(at: point)
        
        var tappedMove: SKNode!
        var tappedUnit: Unit!
        var tappedBase: Base!
        
        // loop through all of them to figure out what was at that spot
        // a given square may be occupied by at least 3 things: a move square where a selected unit can move to, a unit (alive or dead, ours or the opponent's), and/or a base
        for node in tappedNodes {
            // we will use the 'is' operator to do a type check for Unit and Base, then use a node name comparison to look for "move" -- the name we will be giving to move squares later on
            if node is Unit {
                tappedUnit = node as? Unit
            } else if node is Base {
                tappedBase = node as? Base
            } else if node.name == "move" {
                tappedMove = node
            } else if node.name == "endturn" {
                endTurn()
                return  // return immediately so that if a game item is layered directly underneath the button we won't select it
            } else if node.name == "capture" {
                captureBase()
                return  // same here
            } else if node.name == "build" {
                guard let selectedBase = selectedItem as? Base else { return }
                
                if let unit = selectedBase.buildUnit() {
                    // we got a new unit back!
                    units.append(unit)
                    addChild(unit)  // add the unit to the game scene
                }
                
                selectedItem = nil
                return  // same here
            }
        }
        
        // now we need to evaluate what was tapped and decide what that means
        // our selection priority: move squares, then units, then bases
        // note: by having move squares coming before units and bases, we are able to differentiate between a 'selection' tap and a 'decision' tap (ie a start tap and an end tap), because during 'selection' tap there will be no move squares, so tappedMove is nil and player would either select an unit, a base, or nothing; during 'decision' tap, we would have created move squares based on the 'selection' tap if 'selection tap' was an unit (or no move squares created if a base or nothing was tapped), so any squares in the movable region that player tapped would have the move square selected, hence either a move or an attack would take place, rather than selecting an unit or a base that may occupy the same square
        // note: by having units coming before bases, we are able to select the unit and carry out actions with it, rather than selecting the base, if both the unit and base are on the same square
        if tappedMove != nil {
            // move or attack
            // since we are only hiding the move squares once we finished making a move, the player can still tap on it to trigger this if condition, therefore we need to check beforehand whether we have a selectedItem that is Unit -> if so, then we allow this if condition to continue
            guard let selectedUnit = selectedItem as? Unit else { return }
            let tappedUnits = units.itemsAt(position: tappedMove.position)
            
            if tappedUnits.count == 0 {
                // if we get back 0 tapped units we will call move() on the selected unit
                selectedUnit.move(to: tappedMove)
            } else {
                // call attack()
                selectedUnit.attack(target: tappedUnits[0])
            }
            
            // clear the selectedItem after a move or an attack, which will cause the move squares and selection marker to disappear
            selectedItem = nil
        } else if tappedUnit != nil {
            // user tapped a unit
            if selectedItem != nil && tappedUnit == selectedItem {
                // it was already selected; deselect it
                selectedItem = nil
            } else {
                // don't let us control enemy units or dead units
                if tappedUnit.owner == currentPlayer && tappedUnit.isAlive {
                    selectedItem = tappedUnit
                }
            }
        } else if tappedBase != nil {
            // user tapped a base
            if tappedBase.owner == currentPlayer {
                // and it's theirs - select it
                selectedItem = tappedBase
            }
        } else {
            // user tapped something else; deselect whatever we had selected
            selectedItem = nil
        }
    }
    
    // MARK: - Selection marker
    
    func showSelectionMarker() {
        // call removeAllActions on the selectionMarker property to ensure it's fully reset (to remove any rotation it has)
        guard let item = selectedItem else { return }
        selectionMarker.removeAllActions()
        
        // move the selectionMarker sprite to the position of the currently selected item
        selectionMarker.position = item.position
        
        // give it an alpha of 1 so that it's fully visible
        selectionMarker.alpha = 1
        
        // add a rotation action to make it spin around gently, then make that action repeat forever
        let rotate = SKAction.rotate(byAngle: -CGFloat.pi, duration: 1)
        let repeatForever = SKAction.repeatForever(rotate)
        selectionMarker.run(repeatForever)
    }
    
    func hideSelectionMarker() {
        // remove any actions (ie the spinning)
        selectionMarker.removeAllActions()
        
        // set alpha to 0
        selectionMarker.alpha = 0
    }
    
    // this method is called by selectedItem's property observer
    func selectedItemChanged() {
        // call hideMoveOptions() to ensure that all previous move options are removed
        hideMoveOptions()
        
        // hide the build and capture menus
        hideBuildMenu()
        hideCaptureMenu()
        
        if let item = selectedItem {
            // something was selected; show the selection marker
            showSelectionMarker()
            
            if selectedItem is Unit {
                // if the selected item is a Unit we call showMoveOptions()
                showMoveOptions()
                
                // get the list of bases at this item's position
                let currentBases = bases.itemsAt(position: item.position)
                
                if currentBases.count > 0 {
                    if currentBases[0].owner != currentPlayer {
                        // we found a base we didn't already own
                        showCaptureMenu()
                    }
                }
            } else {
                // the user selected a base (if the user is able to select a base then it means that base already belongs to the player -- check nodesTapped() method)
                showBuildMenu()
            }
        } else {
            // selectedItem is nil, so we hide the selection marker
            hideSelectionMarker()
        }
    }
    
    // MARK: - Move Squares
    
    func hideMoveOptions() {
        moveSquares.forEach {
            $0.alpha = 0
        }
    }
    
    func showMoveOptions() {
        guard let selectedUnit = selectedItem as? Unit else { return }
        
        // we will use a counter variable equal to how many squares have been placed already, so that we know which one to modify next
        var counter = 0
        
        // loop from -5 to +5 rows, and -5 to +5 columns, and calculate how far that is from 0
        for row in -5 ..< 5 {
            for col in -5 ..< 5 {
                // only allow moves that are 4 or fewer spaces
                let distance = abs(col) + abs(row)
                guard distance <= 4 else { continue }
                
                // calculate the map position for this square then see which items are there using our new itemsAt() method
                let squarePosition = CGPoint(x: selectedUnit.position.x + CGFloat(col * 64), y: selectedUnit.position.y + CGFloat(row * 64))
                let currentUnits = units.itemsAt(position: squarePosition)
                var isAttack = false
                
                // note that currentUnits can contain at most one unit, since only one unit can occupy a square at a time
                if currentUnits.count > 0 {
                    if currentUnits[0].owner == currentPlayer || currentUnits[0].isAlive == false {
                        // if there's a unit there and it's ours or dead, ignore this move
                        continue
                    } else {
                        // if there's any other unit there, this is an attack
                        isAttack = true
                    }
                }
                
                if isAttack {
                    // if this is an attack and we haven't already fired, color the square red
                    guard selectedUnit.hasFired == false else { continue }
                    moveSquares[counter].color = UIColor.red
                } else {
                    // if this is a move and we haven't already moved, color the square white
                    guard selectedUnit.hasMoved == false else { continue }
                    moveSquares[counter].color = UIColor.white
                }
                
                // position the square, make it partially visible, then add 1 to the counter so the next move square is used
                moveSquares[counter].position = squarePosition
                moveSquares[counter].alpha = 0.35
                counter += 1
            }
        }
    }
    
    // MARK: - Menu Bar
    
    func hideCaptureMenu() {
        menuBarCapture.alpha = 0
    }
    
    func showCaptureMenu() {
        menuBarCapture.alpha = 1
    }
    
    func hideBuildMenu() {
        menuBarBuild.alpha = 0
    }
    
    func showBuildMenu() {
        menuBarBuild.alpha = 1
    }
    
    // MARK: - Menu Items
    
    func endTurn() {
        if currentPlayer == .red {
            // switch the controlling player
            currentPlayer = .blue
            
            // update the two textures
            menuBarEndTurn.texture = SKTexture(imageNamed: "blueEndTurn")
            // we use an SKAction to change the controlling player's texture, with 'resize' parameter being passed in 'true' -> this is needed because we need the sprite to resize to fit the new image ("BLUE" is bigger than "RED") and we don't want them both squeezed in the same space
            let setTexture = SKAction.setTexture(SKTexture(imageNamed: "blue"), resize: true)
            menuBarPlayer.run(setTexture)
        } else {
            currentPlayer = .red
            menuBarEndTurn.texture = SKTexture(imageNamed: "redEndTurn")
            let setTexture = SKAction.setTexture(SKTexture(imageNamed: "red"), resize: true)
            menuBarPlayer.run(setTexture)
        }
        
        // reset all bases and units
        bases.forEach { $0.reset() }
        units.forEach { $0.reset() }
        
        // remove any dead units from 'units' array
        units = units.filter { $0.isAlive }
        
        // clear any previous selection
        selectedItem = nil
    }
    
    func captureBase() {
        guard let item = selectedItem else { return }
        let currentBases = bases.itemsAt(position: item.position)
        
        // if we have a base here...
        if currentBases.count > 0 {
            // ...and it's not owned by us already
            if currentBases[0].owner != currentPlayer {
                // capture it!
                currentBases[0].setOwner(currentPlayer)
                selectedItem = nil
            }
        }
    }
    
    
}
