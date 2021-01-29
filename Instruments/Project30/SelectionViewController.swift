//
//  SelectionViewController.swift
//  Project30
//
//  Created by TwoStraws on 20/08/2016.
//  Copyright (c) 2016 TwoStraws. All rights reserved.
//

import UIKit

class SelectionViewController: UITableViewController {
	var items = [String]() // this is the array that will store the filenames to load
//    var images = [UIImage]()
	var dirty = false

    override func viewDidLoad() {
        super.viewDidLoad()

		title = "Reactionist"

		tableView.rowHeight = 90
		tableView.separatorStyle = .none

		// load all the JPEGs into our array
		let fm = FileManager.default

		if let tempItems = try? fm.contentsOfDirectory(atPath: Bundle.main.resourcePath ?? "") {
			for item in tempItems {
				if item.range(of: "Large") != nil {
					items.append(item)
				}
			}
		}
        
        generateImages()
        
        // MARK: - you can also register a cell here
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell2")
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if dirty {
			// we've been marked as needing a counter reload, so reload the whole table
			tableView.reloadData()
		}
	}
    
    func generateImages() {
        let path = getDocumentsDirectory().appendingPathComponent(items[0])
        guard UIImage(contentsOfFile: path.path) == nil else { return }
        
        for fileName in items {
            // find the image for this cell, and load its thumbnail
            let imageRootName = fileName.replacingOccurrences(of: "Large", with: "Thumb")
            let path = Bundle.main.path(forResource: imageRootName, ofType: nil)
            let original = UIImage(contentsOfFile: (path ?? ""))
            
             // MARK: - create a smaller scaled image instead of the origin massive one; it speeds up the rendering process when we call addEllipse()
            
            let renderRect = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))
            let renderer = UIGraphicsImageRenderer(size: renderRect.size)

            let rounded = renderer.image { ctx in
                ctx.cgContext.addEllipse(in: renderRect)
                ctx.cgContext.clip()  // using the defined path to clip an image i.e. only drawing things that lie inside the path (hence in this case a rounded-corner effect is produced)
                if let original = original {
                    original.draw(in: renderRect)  // draw the original image with a scale
                }
            }
//            images.append(rounded)
            
            let imagePath = getDocumentsDirectory().appendingPathComponent(fileName)
            if let jpegData = rounded.jpegData(compressionQuality: 0.8) {
                try? jpegData.write(to: imagePath)
            }
        }
    }
        
    // MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return items.count * 10
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // MARK: - reuse a tableview cell instead of creating it
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "Cell")
        // create the cell with identifier without using a storyboard
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
//        // or use the registered cell in viewDidLoad():
//        let cell2 = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath)
        
        let path = getDocumentsDirectory().appendingPathComponent(items[indexPath.row % items.count])
        cell.imageView?.image = UIImage(contentsOfFile: path.path)

		// give the images a nice shadow to make them look a bit more dramatic
		cell.imageView?.layer.shadowColor = UIColor.black.cgColor
		cell.imageView?.layer.shadowOpacity = 1
		cell.imageView?.layer.shadowRadius = 10
		cell.imageView?.layer.shadowOffset = CGSize.zero
        
        // MARK: - tell iOS the exact shadowPath to shade in, instead of letting iOS calculating that itself - speeds up the process by eliminating an image render that is otherwise needed for iOS to find the shadowPath
        
        let renderRect = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))
        cell.imageView?.layer.shadowPath = UIBezierPath(ovalIn: renderRect).cgPath

		// each image stores how often it's been tapped
		let defaults = UserDefaults.standard
        cell.textLabel?.text = "\(defaults.integer(forKey: items[indexPath.row % items.count]))"

		return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = ImageViewController()
		vc.image = items[indexPath.row % items.count]
		vc.owner = self

		// mark us as not needing a counter reload when we return
		dirty = false
        
        // show the view controller
		navigationController?.pushViewController(vc, animated: true)
	}
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
