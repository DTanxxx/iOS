//
//  ChaptersViewController.swift
//  Bio&Chem
//
//  Created by David Tan on 27/03/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

class ChaptersViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    var isBio: Bool!
    
    var topicNum: Int!
    var chapter: [String: Int]!
    var arrayOfValues = [Int]()
    var arrayOfChapters = [String]()
    var tapInCell: Bool!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - increase the distance between table view cells
        
        tableView.contentInset = UIEdgeInsets(top: 60, left: 0, bottom: 10, right: 0)
        
        for key in chapter.keys {
            arrayOfValues.append(chapter[key]!)
            arrayOfChapters.append(key)
        }
        for i in 0..<arrayOfValues.count {
            let num = arrayOfValues[i]
            var a = i
            if i > 0 {
                while num < arrayOfValues[a-1] {
                    arrayOfValues.swapAt(a, a-1)
                    arrayOfChapters.swapAt(a, a-1)
                    a -= 1
                    if a == 0 { break }
                }
            }
        }
        
        if isBio {
            if let path = Bundle.main.path(forResource: "vector_forest", ofType: "jpg") {
                let image = UIImage(contentsOfFile: path)
                tableView.backgroundView = UIImageView(image: image)
            }
        } else {
            if let path = Bundle.main.path(forResource: "water", ofType: "jpg") {
                let image = UIImage(contentsOfFile: path)
                tableView.backgroundView = UIImageView(image: image)
            }
        }
        
        createBackButton()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return chapter.keys.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chapter") as? ChapterCell
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 360, height: 78))
        let img = renderer.image { (ctx) in
            
            // create a white background
            let backgroundWhiteRect = CGRect(x: 0, y: 0, width: 360, height: 78)
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.addRect(backgroundWhiteRect)
            ctx.cgContext.drawPath(using: .fill)
            
            // create the desired green background
            let rectangle = CGRect(x: 0, y: 0, width: 360, height: 78)
            
            if isBio {
                ctx.cgContext.setStrokeColor(UIColor(red: 0, green: 0.2, blue: 0.1, alpha: 1.0).cgColor)
                ctx.cgContext.setFillColor(UIColor(red: 0.4, green: 0.8, blue: 0, alpha: 0.4).cgColor)
            } else {
                ctx.cgContext.setStrokeColor(UIColor(red: 0, green: 0.3, blue: 0.6, alpha: 1.0).cgColor)
                ctx.cgContext.setFillColor(UIColor(red: 0.6, green: 1.0, blue: 1.0, alpha: 0.4).cgColor)
            }
            
            ctx.cgContext.setLineWidth(5)
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            
            var color: UIColor
            if isBio { color = UIColor(red: 0, green: 0.2, blue: 0.1, alpha: 1.0) }
            else { color = UIColor(red: 0, green: 0.3, blue: 0.6, alpha: 1.0) }
                
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 26),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: color
            ]

            var string = arrayOfChapters[indexPath.section]
            if string == "Resource Acquisition and Transport" {
                string = "Resource Acquisition and\nTransport"
            } else if string == "Osmoregulation and Excretion" {
                string = "Osmoregulation and\nExcretion"
            } else if string == "Sensory and Motor Mechanisms" {
                string = "Sensory and Motor\nMechanisms"
            } else if string == "Molecular Basis of Inheritance" {
                string = "Molecular Basis of\nInheritance"
            } else if string == "DNA Tools and Biotechnology" {
                string = "DNA Tools and\nBiotechnology"
            }
            else if string == "Arrangement of Electrons in Orbitals" {
                string = "Arrangement of Electrons\nin Orbitals"
            } else if string == "Periodicity of Atomic Properties" {
                string = "Periodicity of Atomic\nProperties"
            } else if string == "Electrophilic Substitution with Benzene" {
                string = "Electrophilic Substitution\nwith Benzene"
            } else if string == "Standard Electrode Reduction Potential" {
                string = "Standard Electrode\nReduction Potential"
            } else if string == "Pressure-Volume Relationship" {
                string = "Pressure-Volume\nRelationship"
            } else if string == "Amount-Volume Relationship" {
                string = "Amount-Volume\nRelationship"
            }
            
            let attributedString = NSAttributedString(string: string, attributes: attrs)
                
            if attributedString.length > 26 || string == "Amount-Volume\nRelationship" {
                attributedString.draw(with: CGRect(x: 30, y: 7, width: 360, height: 78), options: .usesLineFragmentOrigin, context: nil)
            } else if attributedString.length <= 33 {
                attributedString.draw(with: CGRect(x: 30, y: 22, width: 360, height: 78), options: .usesLineFragmentOrigin, context: nil)
            }
        }
        
        cell?.backgroundColor = .clear

        cell?.selectionStyle = .none
        cell?.imageV.image = img
        
        cell?.imageV.layer.borderWidth = 5
        cell?.imageV.layer.cornerRadius = 20
        cell?.layer.cornerRadius = 20
        
        if isBio {
            cell?.imageV.layer.borderColor = UIColor(red: 0, green: 0.2, blue: 0.1, alpha: 1.0).cgColor
        } else {
            cell?.imageV.layer.borderColor = UIColor(red: 0, green: 0.3, blue: 0.6, alpha: 1.0).cgColor
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? ChapterCell
        
        if !cell!.isTapWithin { return }
    
        if let vc = storyboard?.instantiateViewController(identifier: "content") as? ContentViewController {
            vc.isBio = isBio
            vc.topicNum = topicNum
            vc.chapterNum = chapter[arrayOfChapters[indexPath.section]]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func createBackButton() {
        let button = UIButton(frame: CGRect(x: 15, y: -45, width: 70, height: 40))
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        view.addSubview(button)
    }
   
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
   
}

