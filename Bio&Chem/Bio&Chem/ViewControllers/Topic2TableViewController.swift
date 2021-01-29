//
//  Topic2TableViewController.swift
//  Bio&Chem
//
//  Created by David Tan on 7/04/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

class Topic2TableViewController: UITableViewController {
    
    var topicsArray = [Topic]()
    var isQuiz: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        parseJSON()
        
        if isQuiz {
            topicsArray = topicsArray.filter { (topic) -> Bool in
                topic.topic! == "Acids and Bases" ||
                topic.topic! == "Covalent Bonding" ||
                topic.topic! == "Organic Chemistry" ||
                topic.topic! == "Solubility Equilibria" ||
                topic.topic! == "Electrochemistry"
            }
        }
        
        tableView.contentInset = UIEdgeInsets(top: 60, left: 0, bottom: 10, right: 0)
        
        if let path = Bundle.main.path(forResource: "water", ofType: "jpg") {
            let image = UIImage(contentsOfFile: path)
            tableView.backgroundView = UIImageView(image: image)
        }
        
        createBackButton()
    }
    
    // MARK: - parse JSON
    
    func parseJSON() {
        let path = Bundle.main.path(forResource: "Titles2", ofType: ".json")
        guard path != nil else {
            print("Can't find chem json file")
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
    
    
    
    // MARK: - Table view methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return topicsArray.count
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "topic") as? ChapterCell
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 360, height: 78))
        let img = renderer.image { (ctx) in
            
            // create a white background
            let backgroundWhiteRect = CGRect(x: 0, y: 0, width: 360, height: 78)
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.addRect(backgroundWhiteRect)
            ctx.cgContext.drawPath(using: .fill)
            
            // create the desired blue background
            let rectangle = CGRect(x: 0, y: 0, width: 360, height: 78)
            ctx.cgContext.setStrokeColor(UIColor(red: 0, green: 0.3, blue: 0.6, alpha: 1.0).cgColor)
            ctx.cgContext.setFillColor(UIColor(red: 0.6, green: 1.0, blue: 1.0, alpha: 0.4).cgColor)
            ctx.cgContext.setLineWidth(5)
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
                
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 31),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor(red: 0, green: 0.3, blue: 0.6, alpha: 1.0)
            ]

            let string = topicsArray[indexPath.section].topic!
            let attributedString = NSAttributedString(string: string, attributes: attrs)
            
            if attributedString.length > 26 {
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
        cell?.imageV.layer.borderColor = UIColor(red: 0, green: 0.3, blue: 0.6, alpha: 1.0).cgColor

        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? ChapterCell
        if !cell!.isTapWithin { return }
        
        if !isQuiz {
            if let vc = storyboard?.instantiateViewController(identifier: "Chapters") as? ChaptersViewController {
    
                vc.isBio = false
                vc.topicNum = indexPath.section + 1
                vc.chapter = topicsArray[indexPath.section].chapters
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            if let vc = storyboard?.instantiateViewController(identifier: "quiz") as? QuizViewController {
            
                vc.isBio = false
                vc.topic = topicsArray[indexPath.section].topic
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
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
