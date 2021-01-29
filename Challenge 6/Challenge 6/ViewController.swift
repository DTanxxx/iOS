//
//  ViewController.swift
//  Challenge 6
//
//  Created by David Tan on 17/12/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var countries = [Country]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = Bundle.main.path(forResource: "JSON_data", ofType: "json") {
            do {
                let url = URL(fileURLWithPath: path)
                let data = try Data(contentsOf: url)
                parse(json: data)
            } catch {
                print("Unable to create Data object.")
            }
        }
        
        title = "List of Countries"
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        do {
            // The structure of JSON must match the Countries structure--an array of Country objects, so a key matching an array of dictionaries.
            let jsonCountries = try decoder.decode(Countries.self, from: json)
            countries = jsonCountries.countries
            tableView.reloadData()
        } catch {
            print("Error while parsing")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Names", for: indexPath)
        cell.textLabel?.text = countries[indexPath.row].name
        cell.textLabel?.numberOfLines = 0
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            vc.country = countries[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }


}

