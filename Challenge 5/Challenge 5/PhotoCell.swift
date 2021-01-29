//
//  PhotoCell.swift
//  Challenge 5
//
//  Created by David Tan on 9/11/19.
//  Copyright © 2019 LearnAppMaking. All rights reserved.
//

import UIKit

class PhotoCell: UITableViewCell {
    
    @IBOutlet var captionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
