//
//  Cannon.swift
//  Chemmy
//
//  Created by David Tan on 25/07/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import SpriteKit

class Cannon: SKNode {
    
    public var hasFiredJustThen: Bool = false
    public var storedChemicals: [Chemical] {
        return _storedChemicals
    }
    
    private var _storedChemicals: [Chemical] = [Chemical]()
    private var _chemicalsTracker: [String: Int] = [String: Int]()
    private let _launchSpeed: CGFloat = 30
    private var _cannon: SKSpriteNode!
    private var _inputDetectionBox: SKSpriteNode!
    private var _rotationPivot: SKNode!
    private var _playerToBeFired: Player?
    
    // MARK: - TO REMOVE
    private func expendChemicals(by reaction: Reaction) {
        for reactant in reaction.reactants! {
            for chemical in _storedChemicals {
                if chemical.types.contains(reactant.type!) {
                    // remove this chemical from both _chemicalsTracker and _storedChemicals
                    removeFromStoredChemicals(chemical: chemical)
                }
            }
        }
    }
    
    // MARK: - Initialisation code
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("All working correctly!!")
    }
    
    override init() {
        super.init()
    }
    
    public func setCannonPhysics() {
        guard _inputDetectionBox != nil else { return }
        
        _inputDetectionBox.physicsBody = SKPhysicsBody(rectangleOf: _inputDetectionBox.size)
        _inputDetectionBox.physicsBody?.isDynamic = false
        _inputDetectionBox.physicsBody?.angularDamping = 0.0
        _inputDetectionBox.physicsBody?.friction = 0.0
        _inputDetectionBox.physicsBody?.mass = 0.0
        
        _inputDetectionBox.physicsBody?.collisionBitMask = CollisionType.tile.rawValue 
        _inputDetectionBox.physicsBody?.categoryBitMask = CollisionType.cannon.rawValue
        _inputDetectionBox.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
    }
    
    public func restoreDefaultState() {
        // give storedChemicals two starting chemical
        _storedChemicals.append(contentsOf: [Chemical(name: String(Int.random(in: 0..<5)), types: ["oxygen"], frame: ChemicalInfo.defaultFrame), Chemical(name: String(Int.random(in: 0..<5)), types: ["oxygen"], frame: ChemicalInfo.defaultFrame)])
        _chemicalsTracker["oxygen"] = 2
    }
    
    public func createInputDetectionBox() {
        _inputDetectionBox = SKSpriteNode(texture: nil, size: CGSize(width: _cannon.texture!.size().width-CannonInfo.inputDetectionBoxSizeOffsetWidth, height: _cannon.texture!.size().height-CannonInfo.inputDetectionBoxSizeOffsetHeight))
        _inputDetectionBox.name = "cannonBox"
        _inputDetectionBox.position = CannonInfo.inputDetectionBoxPos
        _inputDetectionBox.addChild(_cannon)
        // MARK: - remove later
        _inputDetectionBox.color = UIColor.red
    }
    
    public func createCannonSprite(texture: SKTexture?) {
        _cannon = SKSpriteNode(texture: texture!)
        _cannon.setScale(CannonInfo.cannonScaleFactor)
        _cannon.name = "cannon"
        _cannon.position = CannonInfo.cannonPos
        _cannon.zPosition = zPositions.cannon
    }
    
    public func createStandSprite() {
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        format.opaque = false

        let bounds = CGRect(x: 0, y: 0, width: CannonInfo.standSize.width, height: CannonInfo.standSize.height)

        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: format)
        let result = renderer.image { (ctx) in
            ctx.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
            ctx.cgContext.setFillColor(UIColor.lightGray.cgColor)
            
            ctx.cgContext.move(to: CGPoint(x: 0, y: bounds.height))
            ctx.cgContext.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
            ctx.cgContext.addLine(to: CGPoint(x: bounds.width / 2, y: 0))
            ctx.cgContext.addLine(to: CGPoint(x: 0, y: bounds.height))
            
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        
        let texture = SKTexture(image: result)
        let stand = SKSpriteNode(texture: texture)
        stand.name = "stand"
        stand.position = CannonInfo.standPos
        stand.zPosition = zPositions.stand
        
        stand.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: CannonInfo.standSize.width, height: CannonInfo.standSize.height-CannonInfo.standPhysicsBodyOffsetHeight), center: CannonInfo.standPhysicsBodyPos)
        stand.physicsBody?.isDynamic = false
        
        stand.physicsBody?.collisionBitMask = CollisionType.tile.rawValue | CollisionType.player.rawValue
        stand.physicsBody?.categoryBitMask = CollisionType.stand.rawValue
        
        self.addChild(stand)
    }
    
    public func createRotationPivot() {
        _rotationPivot = SKNode()
        _rotationPivot.position = CannonInfo.rotationPivotPos
        _rotationPivot.addChild(_inputDetectionBox)
        self.addChild(_rotationPivot)
        // MARK: - remove later
        let pivotGizmos = SKSpriteNode(color: .green, size: CGSize(width: 5, height: 5))
        pivotGizmos.zPosition = 100
        pivotGizmos.position = _rotationPivot.position
        self.addChild(pivotGizmos)
    }
    
    // MARK: - Rotation
    
    public func rotateRight() {
        if _rotationPivot.zRotation < -CannonInfo.maxRotationAngle {
            stopRotation()
        }
        else {
            _rotationPivot.run(SKAction.rotate(byAngle: -CannonInfo.rotationSpeed, duration: 1))
        }
    }

    public func rotateLeft() {
        if _rotationPivot.zRotation > CannonInfo.maxRotationAngle {
            stopRotation()
        }
        else {
            _rotationPivot.run(SKAction.rotate(byAngle: CannonInfo.rotationSpeed, duration: 1))
        }
    }
    
    public func stopRotation() {
        _rotationPivot.removeAllActions()
    }
    
    public func getPlayerToBeFired() -> Player? {
        return _playerToBeFired
    }
    
    // MARK: - Fire
    
    public func setPlayerToBeFired(player: Player) {
        _playerToBeFired = player
        _playerToBeFired?.physicsBody?.isDynamic = false
        preparePlayerForFiring()
        // MARK: - remove later
        let centre = SKSpriteNode(color: .blue, size: CGSize(width: 10, height: 10))
        centre.zPosition = 200
        _inputDetectionBox.addChild(centre)
        _playerToBeFired?.zPosition = 100
    }
    
    // MARK: TEST=======================
    public func firePlayer() {
        // check if it has a player
        guard let player = _playerToBeFired else { return }
        
        let (ableToFire, reaction) = ableToFireWithReaction()
        if !ableToFire {
            fatalError("Cannon should be able to fire if Fire button is shown and interactable!")
        }
        
        self.expendChemicals(by: reaction!)
        
        print("Player fired!")
        
//        player.alpha = 1
//        player.ragDollState = false
//        player.physicsBody?.isDynamic = true
//
//        let xVelocity = sin(-_rotationPivot.zRotation) * _launchSpeed
//        let yVelocity = cos(-_rotationPivot.zRotation) * _launchSpeed
//        player.physicsBody?.applyImpulse(CGVector(dx: xVelocity, dy: yVelocity))
//
//        _playerToBeFired = nil
//        hasFiredJustThen = true
    }
    
    public func preparePlayerForFiring() {
        // set position and rotation
        let playerPhysicsBody = _playerToBeFired?.physicsBody
        _playerToBeFired?.physicsBody = nil
        _playerToBeFired?.position = _inputDetectionBox.convert(.zero, to: scene!)
        _playerToBeFired?.zRotation = _rotationPivot.zRotation
        _playerToBeFired?.physicsBody = playerPhysicsBody
    }
    
    // MARK: TEST===============================
    // returns whether or not the cannon is able to fire, as well as the particular reaction needed
    public func ableToFireWithReaction() -> (Bool, Reaction?) {
        guard let actions = JSONParser.parsedActions else { return (false, nil) }
        // iterate through available actions
        for action in actions {
            if action.name! == ActionNames.firing {
                // if action's name is "firing", we found the action we want
                let actionCost = action.cost!
                // iterate through all available reactions for this action
                for reaction in action.reactions! {
                    let reactionEnergy = reaction.energy!
                    var reactantMultiplier = actionCost / reactionEnergy
                    if actionCost % reactionEnergy != 0 {
                        // need to increment reactantMultiplier
                        reactantMultiplier += 1
                    }
                    
                    var reactionViable = true
                    // iterate through reactants needed for this reaction
                    for reactant in reaction.reactants! {
                        let amountNeeded = reactant.amount! * reactantMultiplier
                        // check if key (type) exists in dictionary
                        if let amountAvailable = _chemicalsTracker[reactant.type!] {
                            // check if there is enough of a reactant stored in cannon
                            if amountAvailable < amountNeeded {
                                reactionViable = false
                            }
                        }
                        else {
                            reactionViable = false
                        }
                    }
                    // ...also need to check for catalysts in the future
                    
                    if reactionViable {
                        return (true, reaction)
                    }
                }
                break
            }
        }
        return (false, nil)
    }
    
    // MARK: - Chemicals
    
    // called from ChemicalDisplay
    public func addToStoredChemicals(chemical: Chemical) {
        _storedChemicals.append(chemical)
        chemical.types.forEach {
            if _chemicalsTracker[$0] != nil {
                // key already present
                _chemicalsTracker[$0]! += 1
            } else {
                _chemicalsTracker[$0] = 1
            }
        }
    }
    
    public func removeFromStoredChemicals(chemical: Chemical) {
        for (index, c) in _storedChemicals.enumerated() {
            if c.id == chemical.id {
                _storedChemicals.remove(at: index)
                // remove things in chemicalsTracker accordingly
                c.types.forEach {
                    if _chemicalsTracker[$0] != nil {
                        _chemicalsTracker[$0]! -= 1
                    } else {
                        fatalError ("Tried to remove a type of chemical that does not exist in chemicalsTracker dictionary")
                    }
                }
                break
            }
        }
    }
}
