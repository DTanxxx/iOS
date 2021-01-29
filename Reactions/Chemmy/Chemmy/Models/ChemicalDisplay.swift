//
//  ChemicalDisplay.swift
//  Chemmy
//
//  Created by David Tan on 17/08/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

enum ChemicalDisplayType {
    case panel
    case box
}

protocol ChemicalDisplayDelegate {
    func selectChemical(display type: ChemicalDisplayType, chemical: Chemical)
}

class ChemicalDisplay: UIScrollView {
    public var chemicalDisplayDelegate: ChemicalDisplayDelegate!
    public var stackView: UIStackView!
    
    private var _displayType: ChemicalDisplayType!
    private var _stackViewWidthAnchorConstraint: NSLayoutConstraint?
    private var _chemicals: [Chemical]! {
        didSet {
            print("\(_displayType!) currently has (after adjustment): \(_chemicals.count) chemicals!")
            adjustStackViewWidthAnchor()
        }
    }
    
    public func setUpChemicalDisplayView(type: ChemicalDisplayType) {
        _displayType = type
        // create stack view according to different types passed in
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        
        switch type {
        case .panel:
            stackView.spacing = PanelInfo.spacing
            stackView.layoutMargins = UIEdgeInsets(top: PanelInfo.longitudinalEdgeOffset, left: PanelInfo.lateralEdgeOffset, bottom: PanelInfo.longitudinalEdgeOffset, right: PanelInfo.lateralEdgeOffset)
        case .box:
            stackView.spacing = BoxInfo.spacing
            stackView.layoutMargins = UIEdgeInsets(top: BoxInfo.longitudinalEdgeOffset, left: BoxInfo.lateralEdgeOffset, bottom: BoxInfo.longitudinalEdgeOffset, right: BoxInfo.lateralEdgeOffset)
        }

        self.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        // MARK: - remove later
        _chemicals = [Chemical]()
        if (type == .panel) {
            for _ in 0 ..< 10 {
                let chemical = Chemical(name: String(Int.random(in: 0..<10)), types: (Int.random(in: 0...1)==0 ? ["oxygen"] : ["hydrocarbon_1C"]), frame: ChemicalInfo.defaultFrame)  // note that the CGRect frame provided here takes lower priority than the anchors and stack view auto layout for its subviews
                _chemicals.append(chemical)
            }
            populateWithChemicals(chemicals: _chemicals)
        }
    }
    
    @objc func chemicalSelected(sender: UITapGestureRecognizer) {
        let tapLoc = sender.location(in: sender.view?.superview)
        let tappedChemicals = stackView.subviews.filter { subView -> Bool in
            return subView.frame.contains(tapLoc)
        }
        chemicalDisplayDelegate.selectChemical(display: _displayType, chemical: (tappedChemicals.first as! Chemical))
    }
    
    // called from GameViewController
    public func expendChemicals(by reaction: Reaction, container: Any) {
        // MARK: - IMPLEMENT!!
        // calls removeChemical for all required chemicals
        // remove required reactants from _chemicals array using expendChemicals logic in Cannon
        // ...and call removeChemical for each
        // consider passing in an index indicating the position of the chemical to remove (to reduce redundant loops when chemicals are removed due to firing)
    }
    
    // MARK: FINISH AND TEST BELOW TWO METHODS===========================
    public func removeChemical(chemical: Chemical, container: Any? = nil) {
        for (index, c) in _chemicals.enumerated() {
            if c.id == chemical.id {
                self._chemicals.remove(at: index)
                break
            }
        }
        
        if let cannon = container as? Cannon {
            cannon.removeFromStoredChemicals(chemical: chemical)
            // check if cannon is still able to fire
            let (ableToFire, _) = cannon.ableToFireWithReaction()
            if ableToFire {
                // enable fire button
                // MARK: - add method to delegate to disable fire button
            } else {
                // disable fire button
                // MARK: - add method to delegate to enable fire button
            }
        }
        //else if let...
        
        stackView.removeArrangedSubview(chemical)
        chemical.removeFromSuperview()
    }
    
    // called from GameViewController
    public func addChemical(chemical: Chemical, container: Any? = nil) {
        self._chemicals.append(chemical)
        if let cannon = container as? Cannon {
            cannon.addToStoredChemicals(chemical: chemical)
            let (ableToFire, _) = cannon.ableToFireWithReaction()
            // check if cannon is still able to fire
            if ableToFire {
                // enable to fire button
                // MARK: - same here
            } else {
                // MARK: - and here
            }
        }
        //else if let...
        
        chemical.removeGestureRecognizer((chemical.gestureRecognizers?.first)!)
        chemical.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chemicalSelected)))
        stackView.addArrangedSubview(chemical)
        chemical.topAnchor.constraint(equalTo: stackView.topAnchor, constant: PanelInfo.longitudinalEdgeOffset).isActive = true
        chemical.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -PanelInfo.longitudinalEdgeOffset).isActive = true
    }
    
    public func populateWithChemicals(chemicals: [Chemical]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        self._chemicals = chemicals
        
        for i in 0..<self._chemicals.count {
            let chemical = chemicals[i]
            chemical.isUserInteractionEnabled = true
            chemical.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chemicalSelected)))
            stackView.addArrangedSubview(chemical)
            chemical.topAnchor.constraint(equalTo: stackView.topAnchor, constant: PanelInfo.longitudinalEdgeOffset).isActive = true
            chemical.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -PanelInfo.longitudinalEdgeOffset).isActive = true
        }
    }
    
    private func adjustStackViewWidthAnchor() {
        layoutIfNeeded()
        _stackViewWidthAnchorConstraint?.isActive = false
        var cellHeight: CGFloat
        var widthAnchorValue: CGFloat
        
        switch _displayType {
        case .panel:
            cellHeight = stackView.frame.size.height - 2*PanelInfo.longitudinalEdgeOffset
            widthAnchorValue = cellHeight*CGFloat(_chemicals.count)*ChemicalInfo.cellWidthToHeightRatio
            widthAnchorValue += 2*PanelInfo.lateralEdgeOffset
            // if no cell, make sure spacing is not negative
            widthAnchorValue += CGFloat((CGFloat(_chemicals.count-1) < 0 ? 0 : _chemicals.count-1))*PanelInfo.spacing
        case .box:
            cellHeight = stackView.frame.size.height - 2*BoxInfo.longitudinalEdgeOffset
            widthAnchorValue = cellHeight*CGFloat(_chemicals.count)*ChemicalInfo.cellWidthToHeightRatio
            widthAnchorValue += 2*BoxInfo.lateralEdgeOffset
            // same here
            widthAnchorValue += CGFloat((CGFloat(_chemicals.count-1) < 0 ? 0 : _chemicals.count-1))*BoxInfo.spacing
        default:
            fatalError("Invalid display type here!!!")
            break
        }
        
        _stackViewWidthAnchorConstraint = stackView.widthAnchor.constraint(equalToConstant: widthAnchorValue)
        _stackViewWidthAnchorConstraint?.isActive = true
    }
}
