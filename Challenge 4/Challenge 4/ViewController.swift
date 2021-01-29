//
//  ViewController.swift
//  Challenge 4
//
//  Created by David Tan on 3/11/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var usedWords = [String]()
    var cellsUntappable = [LetterCell]()
    var selectedCell: LetterCell!
    var labelsHidden = [UILabel]()
    var alphabets =  ["a","b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
    var hangManWords = [String]()
    var answerWord = ""
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var incorrect = 0 {
        didSet {
            incorrectWordsLabel.text = "Number wrong: \(incorrect)/10"
        }
    }
    var activatedCells = [UILabel]()
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var incorrectWordsLabel: UILabel!
    @IBOutlet var textField: UITextField!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var submitButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        collectionView.delegate = self
        collectionView.dataSource = self
        performSelector(inBackground: #selector(loadWord), with: nil)
        
    }
    
    // MARK: - Create Button actions
    @objc func cancelTapped(_ sender: UIButton) {
        textField.text = ""
        
        // show the selected button
        if activatedCells != [] {
            activatedCells[activatedCells.count-1].isHidden = false
            activatedCells.removeAll()
        }
    }
    
    @objc func submitTapped(_ sender: UIButton) {
        activatedCells = []
        
        // Make selected cell untappable
        selectedCell.untappable = true
        
        if textField.text == "" {
            return
        }
        var array = wordLabel.text?.components(separatedBy: " ")
        answerWord = answerWord.lowercased()
        guard let guessedLetter = textField.text else { return }
        // Create an array of answer word letters, in strings
        var answerWordArray = [String]()
        for letter in answerWord {
            answerWordArray.append(String(letter))
        }
        if answerWordArray.contains(guessedLetter) {
            for (index, letter) in answerWordArray.enumerated() {
                if letter == guessedLetter {
                    array![index] = letter
                }
            }
            wordLabel.text = array?.joined(separator: " ")
            //correctLetter.append(letter)
        }
        else {
            incorrect += 1
        }
        textField.text = ""
        
        // If incorrect letter count reached:
        if incorrect == 10 {
            let ac = UIAlertController(title: "Oops-the man is dead", message: "The word is '\(answerWord)'.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Restart", style: .default, handler: { [weak self] _ in
                self?.usedWords.removeAll()
                self?.loadWord()
                self?.score = 0
            }))
            present(ac, animated: true)
        }
        
        // If word reached:
        if wordLabel.text!.contains("_") == false {
            let ac = UIAlertController(title: "Congratulations!", message: "Ready for a new word?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Next word", style: .default, handler: { [weak self] _ in self?.loadWord()
                self?.score += 1
            }))
            present(ac, animated: true)
        }
    }
    
    
    
    
    
    // fix so that the on a success run the same word does not appear twice
    // append the word to a list each time loadWord() called
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Making the loadWord method, with setUp called
    @objc func loadWord() {
        if let wordFileURL = Bundle.main.url(forResource: "HangMan words", withExtension: "txt") {
            if let wordContents = try? String(contentsOf: wordFileURL) {
                var lines = wordContents.components(separatedBy: "\n")
                lines.shuffle()
                
                
                
                
                
                while (usedWords.contains(lines[0])) {
                    lines.shuffle()
                }
                usedWords.append(lines[0])
                answerWord = lines[0]
                
                
                
                
                
                
                
                
                
                // Remember to clear the word later on
                performSelector(onMainThread: #selector(setUp), with: nil, waitUntilDone: false)
            }
        }
    }
    
    @objc func setUp() {
        incorrect = 0
        textField.text = ""
        for label in labelsHidden {
            label.isHidden = false
        }
        for cell in cellsUntappable {
            cell.untappable = false
        }
        activatedCells.removeAll()
        labelsHidden.removeAll()
        cellsUntappable.removeAll()
        
        var underscores = ""
        for _ in 0..<answerWord.count {
            underscores += "_ "
        }
        wordLabel.text = underscores
        scoreLabel.text = "Score: \(score)"
        incorrectWordsLabel.text = "Number wrong: \(incorrect)/10"
        
        collectionView.reloadData()
    }
    
    // MARK: - Collection View methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return alphabets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Alphabet", for: indexPath) as! LetterCell
        cell.letterLabel.text = alphabets[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Unhide selected letter
        for label in activatedCells {
            label.isHidden = false
        }
        
        // Append letter to textfield
        selectedCell = collectionView.cellForItem(at: indexPath) as? LetterCell
        
        if selectedCell.untappable == true {
            return
        }
        
        textField.text = selectedCell.letterLabel.text
        
        // Hide the selected button
        cellsUntappable.append(selectedCell)
        activatedCells.append(selectedCell.letterLabel)
        labelsHidden.append(selectedCell.letterLabel)
        selectedCell.letterLabel.isHidden = true
    }
    
}


