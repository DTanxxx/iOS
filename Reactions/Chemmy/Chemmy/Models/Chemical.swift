//
//  Chemical.swift
//  Chemmy
//
//  Created by David Tan on 6/09/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

class Chemical: UIView {
    public var id: String! {
        return _id
    }
    public var types: [String]! {
        return _types
    }
    
    private var _id: String!
    private var _name: String!
    private var _types: [String]!
    private var _chemicalLabel: UILabel!
    private var _chemicalImage: UIImageView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(name: String, types: [String], frame: CGRect) {
        self.init(frame: frame)
        self._name = name
        self._types = types
        self._id = UUID().uuidString
        setUpChemical()
    }
    
    private func setUpChemical() {
        translatesAutoresizingMaskIntoConstraints = false
        // add an imageview
        _chemicalImage = UIImageView(frame: self.frame)
        _chemicalImage.backgroundColor = .brown
        _chemicalImage.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(_chemicalImage)
        _chemicalImage.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        _chemicalImage.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        _chemicalImage.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        _chemicalImage.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        // add a label
        _chemicalLabel = UILabel(frame: self.frame)
        _chemicalLabel.backgroundColor = .green
        _chemicalLabel.textAlignment = .center
        _chemicalLabel.text = "\(_name!)"
        
        // MARK: - remove later
        types.forEach({ (s) in
            _chemicalLabel.text! += s
        })
        // MARK: =======================
        
        _chemicalLabel.font = UIFont.systemFont(ofSize: 5)  // change font to 10 later
        _chemicalLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(_chemicalLabel)
        _chemicalLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: ChemicalInfo.labelHeightAnchorMultiplier).isActive = true
        _chemicalLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: ChemicalInfo.labelWidthAnchorMultiplier).isActive = true
        _chemicalLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: ChemicalInfo.labelLeftEdgeOffset).isActive = true
        _chemicalLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -ChemicalInfo.labelBottomEdgeOffset).isActive = true
    }
}
