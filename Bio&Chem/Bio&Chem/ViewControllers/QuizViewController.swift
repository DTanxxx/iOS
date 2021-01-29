//
//  QuizViewController.swift
//  Bio&Chem
//
//  Created by David Tan on 15/04/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var background: UIImageView!
    @IBOutlet var question: UITextView!
    @IBOutlet var answer: UITextView!
    @IBOutlet var container: UIView!
    
    @IBOutlet var container2: UIView!
    @IBOutlet var answer2: UITextView!
    @IBOutlet var question2: UITextView!
    
    @IBOutlet var backButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var nthCardLabel: UILabel!
    
    var recogniser: UITapGestureRecognizer!
    var isBio: Bool!
    var quizTopicsArray = [QuizTopic]()
    var topic: String?
    var currentFlashcard: Int! {
        didSet {
            nthCardLabel.text = "\(currentFlashcard+1)/\(quizTopicsArray.count)"
        }
    }
    var adjustContainer2By: CGFloat = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        container2.transform = CGAffineTransform(translationX: 500, y: adjustContainer2By)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        currentFlashcard = defaults.value(forKey: topic!) as? Int ?? 0

        parseJson()
        nthCardLabel.text = "\(currentFlashcard+1)/\(quizTopicsArray.count)"
        
        createBackButton()
        
        if isBio {
            background.backgroundColor = UIColor(red: 0.4, green: 0.8, blue: 0, alpha: 0.4)
        } else {
            background.backgroundColor = UIColor(red: 0.3, green: 1.0, blue: 1.0, alpha: 0.4)
        }
        
        configInitialFlashcard()
        addRecognisers()
        
        nextButton.setImage(createButtonImage(), for: .normal)
        backButton.setImage(createBackButtonImage(), for: .normal)
    }
    
    func addRecognisers() {
        recogniser = UITapGestureRecognizer(target: self, action: #selector(flip))
        let recogniser2 = UITapGestureRecognizer(target: self, action: #selector(flip))
        recogniser.delegate = self
        recogniser2.delegate = self
        question.addGestureRecognizer(recogniser)
        answer.addGestureRecognizer(recogniser2)
        
        let re3 = UITapGestureRecognizer(target: self, action: #selector(flip2))
        re3.delegate = self
        question2.addGestureRecognizer(re3)
        let re4 = UITapGestureRecognizer(target: self, action: #selector(flip2))
        re4.delegate = self
        answer2.addGestureRecognizer(re4)
    }
    
    func configInitialFlashcard() {
        question.layer.cornerRadius = 20
        question2.layer.cornerRadius = 20
        answer.layer.cornerRadius = 20
        answer2.layer.cornerRadius = 20
        container.layer.cornerRadius = 20
        container2.layer.cornerRadius = 20
        
        question.text = quizTopicsArray[currentFlashcard].question
        answer.text = quizTopicsArray[currentFlashcard].answer
    }
    
    func parseJson() {
        let fileName: NSMutableString = ""
        for c in topic! {
            if c == " " {
                fileName.append("_")
            } else {
                fileName.append("\(c)")
            }
        }
        
        let path = Bundle.main.path(forResource: fileName as String, ofType: ".json")
        guard path != nil else {
            print("Can't find bio json file")
            return
        }
            
        let url = URL(fileURLWithPath: path!)
            
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            quizTopicsArray = try decoder.decode([QuizTopic].self, from: data)
        } catch {
            print("Couldn't create data object from file")
        }
    }
    
    func createButtonImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 95, height: 65))
        let img = renderer.image { (ctx) in
            
            ctx.cgContext.move(to: CGPoint(x: 0, y: 32))
            ctx.cgContext.addLine(to: CGPoint(x: 95, y: 32))
            ctx.cgContext.move(to: CGPoint(x: 95, y: 32))
            ctx.cgContext.addLine(to: CGPoint(x: 70, y: 64))
            ctx.cgContext.move(to: CGPoint(x: 95, y: 32))
            ctx.cgContext.addLine(to: CGPoint(x: 70, y: 0))
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(3)
            ctx.cgContext.drawPath(using: .stroke)
            
        }
        return img
    }
    
    func createBackButtonImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 95, height: 65))
        let img = renderer.image { (ctx) in
            
            ctx.cgContext.move(to: CGPoint(x: 0, y: 32))
            ctx.cgContext.addLine(to: CGPoint(x: 95, y: 32))
            ctx.cgContext.move(to: CGPoint(x: 0, y: 32))
            ctx.cgContext.addLine(to: CGPoint(x: 25, y: 64))
            ctx.cgContext.move(to: CGPoint(x: 0, y: 32))
            ctx.cgContext.addLine(to: CGPoint(x: 25, y: 0))
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(3)
            ctx.cgContext.drawPath(using: .stroke)
            
        }
        return img
    }
    
    func createBackButton() {
        let button = UIButton(frame: CGRect(x: 15, y: 50, width: 70, height: 40))
        button.setTitle("Back", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func flip() {
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight,.showHideTransitionViews]
        
        if question.isHidden == false {
            
            UIView.transition(from: question, to: answer, duration: 0.5, options: transitionOptions) { [unowned self] (_) in
                self.question.isHidden = true
                self.answer.isHidden = false
            }
            
        } else if question.isHidden == true {
            UIView.transition(from: answer, to: question, duration: 0.5, options: transitionOptions) { [unowned self] (_) in
                self.answer.isHidden = true
                self.question.isHidden = false
            }
        }
    }
    
    @objc func flip2() {
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight,.showHideTransitionViews]
        
        if question2.isHidden == false {
            UIView.transition(from: question2, to: answer2, duration: 0.5, options: transitionOptions) { [unowned self] (_) in
                self.question2.isHidden = true
                self.answer2.isHidden = false
            }
        } else if question2.isHidden == true {
            UIView.transition(from: answer2, to: question2, duration: 0.5, options: transitionOptions) { [unowned self] (_) in
                self.answer2.isHidden = true
                self.question2.isHidden = false
            }
        }
    }
    
    func moveContainer2Right() {
        container2.transform = CGAffineTransform(translationX: -500, y: adjustContainer2By)
        question2.isHidden = false
        answer2.isHidden = true
        
        if currentFlashcard == 0 { currentFlashcard = quizTopicsArray.count - 1}
        else { currentFlashcard -= 1 }
        question2.text = quizTopicsArray[currentFlashcard].question
        answer2.text = quizTopicsArray[currentFlashcard].answer
        
        self.question2.centerVertically()
        self.answer2.centerVertically()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.backButton.isUserInteractionEnabled = false
            
            self.container.transform = CGAffineTransform(translationX: 500, y: 0)
            self.container2.transform = CGAffineTransform(translationX: 0, y: self.adjustContainer2By)
        }) { [unowned self ] (_) in
            self.backButton.isUserInteractionEnabled = true
        }
    }
    
    func moveContainer1Right() {
        container.transform = CGAffineTransform(translationX: -500, y: 0)
        question.isHidden = false
        answer.isHidden = true  // MARK: - changed here
        
        if currentFlashcard == 0 { currentFlashcard = quizTopicsArray.count - 1}
        else { currentFlashcard -= 1 }
        question.text = quizTopicsArray[currentFlashcard].question
        answer.text = quizTopicsArray[currentFlashcard].answer
        
        self.question.centerVertically()
        self.answer.centerVertically()

        UIView.animate(withDuration: 0.3, animations: {
            self.backButton.isUserInteractionEnabled = false
            
            self.container2.transform = CGAffineTransform(translationX: 500, y: self.adjustContainer2By)
            self.container.transform = CGAffineTransform(translationX: 0, y: 0)
        }) { [unowned self] _ in
            self.backButton.isUserInteractionEnabled = true
        }
    }
    
    func moveContainer2Left() {
        container2.transform = CGAffineTransform(translationX: 500, y: adjustContainer2By)
        question2.isHidden = false
        answer2.isHidden = true
        
        if currentFlashcard == quizTopicsArray.count - 1 { currentFlashcard = 0}
        else { currentFlashcard += 1 }
        question2.text = quizTopicsArray[currentFlashcard].question
        answer2.text = quizTopicsArray[currentFlashcard].answer
        
        self.question2.centerVertically()
        self.answer2.centerVertically()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.nextButton.isUserInteractionEnabled = false
            
            self.container.transform = CGAffineTransform(translationX: -500, y: 0)
            self.container2.transform = CGAffineTransform(translationX: 0, y: self.adjustContainer2By)
        }) { [unowned self ] (_) in
            self.nextButton.isUserInteractionEnabled = true
        }
    }
    
    func moveContainer1Left() {
        container.transform = CGAffineTransform(translationX: 500, y: 0)
        question.isHidden = false
        answer.isHidden = true  // MARK: - changed here
        
        if currentFlashcard == quizTopicsArray.count - 1 { currentFlashcard = 0}
        else { currentFlashcard += 1 }
        question.text = quizTopicsArray[currentFlashcard].question
        answer.text = quizTopicsArray[currentFlashcard].answer
        
        self.question.centerVertically()
        self.answer.centerVertically()

        UIView.animate(withDuration: 0.3, animations: {
            self.nextButton.isUserInteractionEnabled = false
            
            self.container2.transform = CGAffineTransform(translationX: -500, y: self.adjustContainer2By)
            self.container.transform = CGAffineTransform(translationX: 0, y: 0)
        }) { [unowned self] _ in
            self.nextButton.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        if container.frame.minX == 35 {
            moveContainer2Right()
        } else {
            moveContainer1Right()
        }
        
        let defaults = UserDefaults.standard
        defaults.set(currentFlashcard, forKey: topic!)
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        if container.frame.minX == 35 {
            moveContainer2Left()
        } else {
            moveContainer1Left()
        }
        
        let defaults = UserDefaults.standard
        defaults.set(currentFlashcard, forKey: topic!)
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if container.frame.minX == -465 {
            UIView.animate(withDuration: 0.3) {
                self.container2.transform = CGAffineTransform(translationX: 500, y: self.adjustContainer2By)
                self.container.isHidden = true
            }
        } else if container2.frame.minX == -465 {
            UIView.animate(withDuration: 0.3) {
                self.container.transform = CGAffineTransform(translationX: 500, y: 0)
                self.container2.isHidden = true
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.container.transform = CGAffineTransform(translationX: 500, y: 0)
                self.container2.transform = CGAffineTransform(translationX: 500, y: self.adjustContainer2By)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        question2.centerVertically()
        answer2.centerVertically()
        question.centerVertically()
        answer.centerVertically()
        
    }
    
}


extension UITextView {

    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }

}
