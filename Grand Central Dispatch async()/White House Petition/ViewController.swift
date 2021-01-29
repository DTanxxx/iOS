//
//  ViewController.swift
//  White House Petition
//
//  Created by David Tan on 11/10/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var answer = ""
    
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    var petitionsToUse = [Petition]()

    override func viewDidLoad() {
        super.viewDidLoad()
            
        let button1 = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(goBack))
        
        let button2 = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showTextField))
        
        navigationItem.leftBarButtonItems = [button1, button2]
    
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showCredits))
        
        // let urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        let urlString: String
        
        // ...this:
        if navigationController?.tabBarItem.tag == 0 {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        }
        else {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        // This code essentially makes the first instance of ViewController to load the original JSON, and the second to load only petitions that have at least 10,000 signatures.
        
        // Grand Central Dispatch--it places the parsing code in a separate queue (one with fewer number of CPU working on it ie slower) so that both viewDidLoad() and the parse method are called at the same time ie the UI does not freeze.
        // We used async() this time, we can also use performSelector() (in another copy of the project).
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    self?.parse(json: data)
                    return
                }
            }
            
            self?.showError()
        }
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        //  The decoder is used to convert between JSON and Codable objects (hence able to work with json data itself).
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            petitionsToUse = petitions
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
            // Every work done to user interface eg reloading table view data in this case should be done in the main thread, that's why we used .main instead of .global
        }
        // A new syntax, Petitions.self, is Swift’s way of referring to the Petitions type itself rather than an instance of it. That is, we’re not saying “create a new one”, but instead specifying it as a parameter to the decoding so JSONDecoder knows what to convert the JSON too.
    }
    
    func showError() {
        // Same here, presenting an alert controller is an user interface work.
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(title: "Loading Error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(ac, animated: true)
        }
    }
    
    @objc func showCredits() {
        let ac = UIAlertController(title: "Credits", message: "This data comes from the We 'The People API of the Whitehouse'.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Return", style: .default))
        present(ac, animated: true)
    }
    
    // Create method that displays UIAlertController with a textfield
    @objc func showTextField() {
        let ac = UIAlertController(title: "Enter Keyword", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let submitAction = UIAlertAction(title: "Search", style: .default) { [weak self, weak ac] action in guard let answer = ac?.textFields?[0].text else { return }
            self?.answer = answer
            self?.performSelector(inBackground: #selector(self?.submit), with: nil)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    @objc func submit() {
        filteredPetitions = []
        for petition in petitions {
            if petition.title.contains(answer) {
                filteredPetitions.append(petition)
            }
        }
        if filteredPetitions.isEmpty {
            DispatchQueue.main.async {
                let ac = UIAlertController(title: "Failed Search", message: "Please type in a valid keyword.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Return", style: .cancel))
                self.present(ac, animated: true)
            }
            return
        }
        petitionsToUse = filteredPetitions
        answer = ""
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
    }
    
    @objc func goBack() {
        petitionsToUse = petitions
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petitionsToUse.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = petitionsToUse[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitionsToUse[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

}

