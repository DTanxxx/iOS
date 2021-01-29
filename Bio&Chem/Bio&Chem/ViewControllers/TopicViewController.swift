//
//  TopicViewController.swift
//  Bio&Chem
//
//  Created by David Tan on 25/03/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

class TopicViewController: UICollectionViewController {
    
    var topicsArray = [Topic]()
    var isQuiz: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parseJson()
        
        if let path = Bundle.main.path(forResource: "vector_forest", ofType: "jpg") {
            let image = UIImage(contentsOfFile: path)
            collectionView.backgroundView = UIImageView(image: image)
        }
        
        createBackButton()
    }
    
    // MARK: - parse JSON
    
    func parseJson() {
        let path = Bundle.main.path(forResource: "Titles", ofType: ".json")
        guard path != nil else {
            print("Can't find bio json file")
            return
        }
            
        let url = URL(fileURLWithPath: path!)
            
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            topicsArray = try decoder.decode([Topic].self, from: data)
        } catch {
            print("Couldn't create data object from file")
        }
    }
    
    // MARK: - Collection view stuff
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topicsArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topic", for: indexPath) as? TopicCell else { fatalError("Cell not initialising properly") }
        
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
                
            let string = topicsArray[indexPath.row].topic!
            let attributedString = NSAttributedString(string: string, attributes: attrs)
                
            attributedString.draw(with: CGRect(x: -75, y: -20, width: 150, height: 80), options: .usesLineFragmentOrigin, context: nil)
        }
        
        cell.topic.image = img
        cell.topic.layer.borderWidth = 5
        cell.topic.layer.cornerRadius = 20
        cell.layer.cornerRadius = 20
        cell.topic.layer.borderColor = UIColor(red: 0, green: 0.2, blue: 0.1, alpha: 1.0).cgColor
        return cell
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if !isQuiz {
            if let vc = storyboard?.instantiateViewController(identifier: "Chapters") as? ChaptersViewController {
            
                vc.isBio = true
                vc.topicNum = indexPath.row + 1
                vc.chapter = topicsArray[indexPath.row].chapters
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            if let vc = storyboard?.instantiateViewController(identifier: "quiz") as? QuizViewController {
            
                vc.isBio = true
                vc.topic = topicsArray[indexPath.row ].topic
                navigationController?.pushViewController(vc, animated: true)
            }
              
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
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
