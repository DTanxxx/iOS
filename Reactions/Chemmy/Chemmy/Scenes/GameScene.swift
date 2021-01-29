//
//  GameScene.swift
//  Reactions
//
//  Created by David Tan on 20/07/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    public weak var viewController: GameViewController!
    public var playerStartPos: CGPoint {
        return _playerStartPos
    }
    public var player: Player! {
        return _player
    }
    public var selectedContainer: Any? {
        return _selectedContainer
    }
    
    private var _gravity: CGVector = CGVector(dx: 0, dy: -2)
    private var _playerStartPos: CGPoint = CGPoint(x: -200, y: 200)
    private var _playerFadeOutDuration: Double = 0.1
    
    private var _rotateLeft: SKSpriteNode!
    private var _rotateRight: SKSpriteNode!
    
    private var _leftTapped = false
    private var _rightTapped = false
    
    private var _player: Player!
    private var _selectedContainer: Any?  // can be Cannon, or other things that can contain chemicals
    
    override func didMove(to view: SKView) {
        self.physicsWorld.gravity = _gravity
        self.physicsWorld.contactDelegate = self
        
        setUpTilemap()
        setUpPlayer()
        setUpCannons()
        setUpButtons()
        
        // set up cannons created in editor
        let texture = SKTexture(imageNamed: "cannon")
        let sheet = SpriteSheet(texture: texture, rows: 1, columns: 6, spacing: 2, margin: 4)
        for node in children {
            guard let name = node.name else { continue }
            // it's a cannon
            if name.starts(with: "Cannon") {
                let cannon = node as! Cannon
                cannon.createCannonSprite(texture: sheet.textureForColumn(column: 0, row: 0))
                cannon.createInputDetectionBox()
                cannon.createRotationPivot()
                cannon.createStandSprite()
                cannon.setCannonPhysics()
                cannon.restoreDefaultState()
                cannon.name = "cannonContainer"
                cannon.zPosition = zPositions.inputDetectionBox
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        processRotation()
        
        if !_player.ragDollState {
            if let body = _player.physicsBody {
                if (body.velocity.speed() > 0.01) {
                    _player.zRotation = body.velocity.angle() - CGFloat.pi/2
                }
            }
        }
    }
    
    // MARK: - Initialisation code
    
    private func setUpTilemap() {
        guard let tileMap = childNode(withName: "Platform") as? SKTileMapNode else { fatalError("No Tile Map to Load") }

        let tileSize = tileMap.tileSize
        let halfWidth = CGFloat(tileMap.numberOfColumns) / 2.0 * tileSize.width
        let halfHeight = CGFloat(tileMap.numberOfRows) / 2.0 * tileSize.height

        for col in 0..<tileMap.numberOfColumns {
            for row in 0..<tileMap.numberOfRows {
                let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row)
                let isEdgeTile = tileDefinition?.userData?["edgeTile"] as? Bool
                if (isEdgeTile ?? false) {
                    let x = CGFloat(col) * tileSize.width - halfWidth
                    let y = CGFloat(row) * tileSize.height - halfHeight
                    let rect = CGRect(x: 0, y: 0, width: tileSize.width, height: tileSize.height)
                    let tileNode = Tile(rect: rect)
                    tileNode.setTilePhysics(size: tileSize)
                    tileNode.name = "tile"
                    tileNode.position = CGPoint(x: x, y: y)
                    tileNode.lineWidth = 0
                    tileMap.addChild(tileNode)
                }
            }
        }
    }
    
    private func setUpPlayer() {
        let texture = SKTexture(imageNamed: "male")
        let sheet = SpriteSheet(texture: texture, rows: 5, columns: 9, spacing: 6, margin: 6)
        _player = Player()  // this is a container object
        _player.createPlayerSprite(texture: sheet.textureForColumn(column: 0, row: 4))
        _player.setPlayerPhysics()
        _player.zPosition = zPositions.player
        _player.name = "playerContainer"
        // MARK: - read position from file
        _player.position = playerStartPos
        
        addChild(_player)
    }
    
    private func setUpCannons() {
        let texture = SKTexture(imageNamed: "cannon")
        let sheet = SpriteSheet(texture: texture, rows: 1, columns: 6, spacing: 2, margin: 4)
        
        // MARK: - read positions from file
        for i in 0 ..< 2 {
            let cannon = Cannon()  // this is a container object
            cannon.createCannonSprite(texture: sheet.textureForColumn(column: 0, row: 0))
            cannon.createInputDetectionBox()
            cannon.createRotationPivot()
            cannon.createStandSprite()
            cannon.setCannonPhysics()
            cannon.restoreDefaultState()
            cannon.name = "cannonContainer"
            cannon.zPosition = zPositions.inputDetectionBox
            cannon.position = CGPoint(x: -300 + i * 100, y: -10)
            
            addChild(cannon)
        }
    }
    
    private func setUpButtons() {
        _rotateLeft = SKSpriteNode(imageNamed: "left")
        _rotateRight = SKSpriteNode(imageNamed: "right")
        
        _rotateLeft.name = "rotateLeft"
        _rotateRight.name = "rotateRight"
        
        _rotateLeft.setScale(RotateButtonInfo.scaleFactor)
        _rotateRight.setScale(RotateButtonInfo.scaleFactor)
        _rotateLeft.alpha = 0
        _rotateRight.alpha = 0
        
        _rotateLeft.position = CGPoint(x: -(self.frame.width/2) + RotateButtonInfo.lateralEdgeOffset, y: -(self.frame.height/2) + RotateButtonInfo.longitudinalEdgeOffset)
        _rotateRight.position = CGPoint(x: (self.frame.width/2) - RotateButtonInfo.lateralEdgeOffset, y: -(self.frame.height/2) + RotateButtonInfo.longitudinalEdgeOffset)
        _rotateLeft.zPosition = zPositions.buttons
        _rotateRight.zPosition = zPositions.buttons
        
        addChild(_rotateLeft)
        addChild(_rotateRight)
    }
    
    // MARK: - Physics code
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "playerContainer" && nodeB.name == "cannonBox" && !nodeA.hasActions() {
            if (nodeB.parent?.parent as! Cannon).hasFiredJustThen { return }
            nodeA.run(SKAction.fadeOut(withDuration: _playerFadeOutDuration))
            (nodeB.parent?.parent as! Cannon).setPlayerToBeFired(player: nodeA as! Player)
        } else if nodeB.name == "playerContainer" && nodeA.name == "cannonBox" && !nodeB.hasActions() {
            if (nodeA.parent?.parent as! Cannon).hasFiredJustThen { return }
            nodeB.run(SKAction.fadeOut(withDuration: _playerFadeOutDuration))
            (nodeA.parent?.parent as! Cannon).setPlayerToBeFired(player: nodeB as! Player)
        }
        
        if (nodeA.name == "playerContainer") {
            (nodeA as! Player).ragDollState = true
        } else if (nodeB.name == "playerContainer") {
            (nodeB as! Player).ragDollState = true
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if (nodeA.name == "playerContainer" && nodeB.name == "cannonBox") {
            (nodeB.parent?.parent as! Cannon).hasFiredJustThen = false
        } else if (nodeB.name == "playerContainer" && nodeA.name == "cannonBox") {
            (nodeA.parent?.parent as! Cannon).hasFiredJustThen = false
        }
    }
    
    // MARK: - User input code
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        processInput(at: touchLocation)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        _leftTapped = false
        _rightTapped = false
        if let cannon = selectedContainer as? Cannon {
            cannon.stopRotation()
        }
    }
    
    private func processInput(at point: CGPoint) {
        let tappedNodes = nodes(at: point)
        
        for node in tappedNodes {
            if node.name == "rotateLeft" {
                // user wants to rotate left
                _leftTapped = true
                return
            }
            else if node.name == "rotateRight" {
                // user wants to rotate right
                _rightTapped = true
                return
            }
            else if node.name == "cannonBox" {
                if let cannon = selectedContainer as? Cannon {
                    // if a cannon was already selected, check if it's the same one
                    if cannon != (node.parent?.parent as? Cannon) {
                        // show buttons
                        selectContainer(node)
                        return
                    }
                } else {
                    // the container already selected was not a cannon; show buttons
                    selectContainer(node)
                    return
                }
            }
        }
        
        // hide buttons
        deselectContainer()
    }
    
    private func processRotation() {
        if (_leftTapped) {
            let cannon = selectedContainer as? Cannon
            cannon?.rotateLeft()
            if let _ = cannon?.getPlayerToBeFired() {
                // prepare firing if there is a player in the cannon
                cannon?.preparePlayerForFiring()
            }
        }
        else if (_rightTapped) {
            let cannon = selectedContainer as? Cannon
            cannon?.rotateRight()
            if let _ = cannon?.getPlayerToBeFired() {
                cannon?.preparePlayerForFiring()
            }
        }
    }
    
    private func selectContainer(_ node: SKNode) {
        // user taps on a container
        if let cannon = node.parent?.parent as? Cannon {
            // the container is a cannon
            showButtons()
            _selectedContainer = cannon
        }
        //else if let...
        showChemicals()
    }
    
    private func deselectContainer() {
        _selectedContainer = nil
        hideButtons()
        hideChemicals()
    }
    
    private func hideButtons() {
        _rotateLeft.alpha = 0
        _rotateRight.alpha = 0
        viewController.hideButtons()
    }
    
    private func showButtons() {
        _rotateLeft.alpha = 1
        _rotateRight.alpha = 1
        viewController.showButtons()
    }
    
    private func showChemicals() {
        viewController.showChemicalDisplays(for: selectedContainer!)
    }
    
    private func hideChemicals() {
        viewController.hideChemicalDisplays()
    }
}
