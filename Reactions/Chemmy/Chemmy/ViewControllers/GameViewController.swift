//
//  GameViewController.swift
//  Reactions
//
//  Created by David Tan on 20/07/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, ChemicalDisplayDelegate {
    
    private var _currentGame: GameScene!
    
    private var _resetButton: UIButton!
    private var _fireButton: UIButton!
    
    private var _chemicalDisplayPanel: ChemicalDisplay!
    private var _chemicalDisplayBox: ChemicalDisplay!
    
    override func loadView() {
        super.loadView()
        
        if JSONParser.parsedActions == nil {
            JSONParser.parseActions()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                
                _currentGame = scene as? GameScene
                _currentGame.viewController = self
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        createChemicalDisplayPanel()
        createChemicalDisplayBox()
        
        createResetButton()
        createFireButton()
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
    
    // MARK: - Chemical displays
    
    private func createChemicalDisplayPanel() {
        _chemicalDisplayPanel = ChemicalDisplay()
        _chemicalDisplayPanel.bounces = false
        _chemicalDisplayPanel.alpha = 0
        _chemicalDisplayPanel.chemicalDisplayDelegate = self
        self.view.addSubview(_chemicalDisplayPanel)
        
        _chemicalDisplayPanel.translatesAutoresizingMaskIntoConstraints = false
        _chemicalDisplayPanel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: PanelInfo.widthAnchorMultiplier).isActive = true
        _chemicalDisplayPanel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: PanelInfo.heightAnchorMultiplier).isActive = true
        _chemicalDisplayPanel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: PanelInfo.bottomEdgeOffset).isActive = true
        _chemicalDisplayPanel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        _chemicalDisplayPanel.contentSize.height = _chemicalDisplayPanel.visibleSize.height
        _chemicalDisplayPanel.setUpChemicalDisplayView(type: .panel)
        // MARK: - remove later
        _chemicalDisplayPanel.backgroundColor = .red
    }
    
    public func createChemicalDisplayBox() {
        _chemicalDisplayBox = ChemicalDisplay()
        _chemicalDisplayBox.bounces = false
        _chemicalDisplayBox.alpha = 0
        _chemicalDisplayBox.chemicalDisplayDelegate = self
        self.view.addSubview(_chemicalDisplayBox)
        
        _chemicalDisplayBox.translatesAutoresizingMaskIntoConstraints = false
        _chemicalDisplayBox.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: BoxInfo.widthAnchorMultiplier).isActive = true
        _chemicalDisplayBox.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: BoxInfo.heightAnchorMultiplier).isActive = true
        _chemicalDisplayBox.bottomAnchor.constraint(equalTo: _chemicalDisplayPanel.topAnchor, constant: BoxInfo.bottomEdgeOffsetFromPanel).isActive = true
        _chemicalDisplayBox.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        _chemicalDisplayBox.setUpChemicalDisplayView(type: .box)
        // MARK: - remove later
        _chemicalDisplayBox.backgroundColor = .yellow
    }
    
    public func showChemicalDisplays(for container: Any) {
        _chemicalDisplayPanel.alpha = 1
        _chemicalDisplayBox.alpha = 1
        // also update the chemical box
        if let cannon = container as? Cannon {
            _chemicalDisplayBox.populateWithChemicals(chemicals: cannon.storedChemicals)
        }
        //else if let... 
    }
    
    public func hideChemicalDisplays() {
        _chemicalDisplayPanel.alpha = 0
        _chemicalDisplayBox.alpha = 0
    }
    
    public func selectChemical(display type: ChemicalDisplayType, chemical: Chemical) {
        print("\(chemical.id!) is selected from \(type)!")
        switch type {
        case .panel:
            _chemicalDisplayPanel.removeChemical(chemical: chemical)
            _chemicalDisplayBox.addChemical(chemical: chemical, container: _currentGame.selectedContainer!)
        case .box:
            _chemicalDisplayBox.removeChemical(chemical: chemical, container: _currentGame.selectedContainer!)
            _chemicalDisplayPanel.addChemical(chemical: chemical)
        }
    }
    
    // MARK: - Buttons
    
    private func createResetButton() {
        _resetButton = UIButton()
        _resetButton.setTitle("RESET", for: .normal)
        _resetButton.setTitleColor(.red, for: .normal)
        _resetButton.titleLabel?.font =
            UIFont.systemFont(ofSize: ResetButtonInfo.fontSize)
        _resetButton.frame =
            CGRect(x: 0, y: 0, width: ResetButtonInfo.width, height: ResetButtonInfo.height)
        _resetButton.addTarget(self, action: #selector(resetPressed), for: .touchUpInside)
        _resetButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(_resetButton)
        
        _resetButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: ResetButtonInfo.topEdgeOffset).isActive = true
        _resetButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: ResetButtonInfo.leadingEdgeOffset).isActive = true
    }
    
    private func createFireButton() {
        _fireButton = UIButton()
        _fireButton.setTitle("FIRE", for: .normal)
        _fireButton.setTitleColor(.red, for: .normal)
        _fireButton.titleLabel?.font =
            UIFont.systemFont(ofSize: FireButtonInfo.fontSize)
        _fireButton.frame =
            CGRect(x: 0, y: 0, width: FireButtonInfo.width, height: FireButtonInfo.height)
        _fireButton.addTarget(self, action: #selector(firePressed), for: .touchUpInside)
        _fireButton.translatesAutoresizingMaskIntoConstraints = false
        _fireButton.alpha = 0
        self.view.addSubview(_fireButton)
        
        _fireButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: FireButtonInfo.topEdgeOffset).isActive = true
        _fireButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: FireButtonInfo.leadingEdgeOffset).isActive = true
    }
    
    @objc func resetPressed() {
        _currentGame.player.position = _currentGame.playerStartPos
        _currentGame.player.zRotation = 0
        _currentGame.player.alpha = 1
        
        _currentGame.player.physicsBody?.isDynamic = true
        _currentGame.player.physicsBody?.velocity = .zero
        _currentGame.player.physicsBody?.angularVelocity = .zero
        
        _currentGame.player.ragDollState = true
    }
    
    @objc func firePressed() {
        (_currentGame.selectedContainer as! Cannon).firePlayer()
        // MARK: - call expendChemicals on chemical box (a new method to remove all chemicals needed for firing)
    }
    
    // MARK: TEST===================================
    public func showButtons() {
        let (ableToFire, _) = (_currentGame.selectedContainer as! Cannon).ableToFireWithReaction()
        if ableToFire {
            _fireButton.alpha = 1
        } else {
            hideButtons()
        }
    }
    
    public func hideButtons() {
        _fireButton.alpha = 0
    }
}
