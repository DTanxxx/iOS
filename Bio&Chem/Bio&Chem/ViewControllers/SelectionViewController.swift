//
//  SelectionViewController.swift
//  Bio&Chem
//
//  Created by David Tan on 15/04/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

class SelectionViewController: UIViewController {

    @IBOutlet var background: UIImageView!
    @IBOutlet var content: UIButton!
    @IBOutlet var quiz: UIButton!
    
    var isBio: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createBackButton()
        
        var imageString = ""
        if isBio { imageString = "vector_forest" } else { imageString = "water" }
        if let path = Bundle.main.path(forResource: imageString, ofType: "jpg") {
            let image = UIImage(contentsOfFile: path)
            background.image = image
        }
        
        configureButton()
    }
    
    func configureButton() {
        content.layer.cornerRadius = 20
        content.imageView?.layer.cornerRadius = 20
        content.imageView?.layer.borderWidth = 5
        
        quiz.layer.cornerRadius = 20
        quiz.imageView?.layer.cornerRadius = 20
        quiz.imageView?.layer.borderWidth = 5
        
        
        if isBio {
            let img = createBioImage(section: "Content")
            content.setImage(img, for: .normal)
            let img2 = createBioImage(section: "Quiz")
            quiz.setImage(img2, for: .normal)
        } else {
            let img = createChemImage(section: "Content")
            content.setImage(img, for: .normal)
            let img2 = createChemImage(section: "Quiz")
            quiz.setImage(img2, for: .normal)
        }
    }
    
    func createBioImage(section: String) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 150, height: 80))
        let img = renderer.image { (ctx) in
            ctx.cgContext.translateBy(x: 75, y: 40)
            
            let rectangle = CGRect(x: -80, y: -45, width: 160, height: 90)
            ctx.cgContext.setStrokeColor(UIColor(red: 0, green: 0.2, blue: 0.1, alpha: 1.0).cgColor)
            ctx.cgContext.setFillColor(UIColor(red: 0.4, green: 0.8, blue: 0, alpha: 0.4).cgColor)
            ctx.cgContext.setLineWidth(20)
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
                
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 31),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor(red: 0, green: 0.2, blue: 0.1, alpha: 1.0)
            ]
                
            let string = section
            let attributedString = NSAttributedString(string: string, attributes: attrs)
                
            attributedString.draw(with: CGRect(x: -75, y: -20, width: 150, height: 80), options: .usesLineFragmentOrigin, context: nil)
        }
        content.imageView?.layer.borderColor = UIColor(red: 0, green: 0.2, blue: 0.1, alpha: 1.0).cgColor
        quiz.imageView?.layer.borderColor = UIColor(red: 0, green: 0.2, blue: 0.1, alpha: 1.0).cgColor
        return img
    }
    
    func createChemImage(section: String) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 150, height: 80))
        let img = renderer.image { (ctx) in
            ctx.cgContext.translateBy(x: 75, y: 40)
            
            let rectangle = CGRect(x: -80, y: -45, width: 160, height: 90)
            ctx.cgContext.setStrokeColor(UIColor(red: 0, green: 0.3, blue: 0.6, alpha: 1.0).cgColor)
            ctx.cgContext.setFillColor(UIColor(red: 0.6, green: 1.0, blue: 1.0, alpha: 0.4).cgColor)
            ctx.cgContext.setLineWidth(20)
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
                
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 31),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor(red: 0, green: 0.3, blue: 0.6, alpha: 1.0)
            ]
                
            let string = section
            let attributedString = NSAttributedString(string: string, attributes: attrs)
                
            attributedString.draw(with: CGRect(x: -75, y: -20, width: 150, height: 80), options: .usesLineFragmentOrigin, context: nil)
        }
        content.imageView?.layer.borderColor = UIColor(red: 0, green: 0.3, blue: 0.6, alpha: 1.0).cgColor
        quiz.imageView?.layer.borderColor = UIColor(red: 0, green: 0.3, blue: 0.6, alpha: 1.0).cgColor
        return img
    }
    
    
    @IBAction func contentTapped(_ sender: Any) {
        if isBio {
            if let vc = storyboard?.instantiateViewController(identifier: "Topics") as? TopicViewController {
                vc.isQuiz = false
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            if let vc = storyboard?.instantiateViewController(identifier: "Topic2") as? Topic2TableViewController {
                vc.isQuiz = false
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func quizTapped(_ sender: Any) {
        
        if isBio {
            if let vc = storyboard?.instantiateViewController(identifier: "Topics") as? TopicViewController {
                vc.isQuiz = true
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            if let vc = storyboard?.instantiateViewController(identifier: "Topic2") as? Topic2TableViewController {
                vc.isQuiz = true
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        
    }
    
    func createBackButton() {
        let button = UIButton(frame: CGRect(x: 15, y: 50, width: 70, height: 40))
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
}
