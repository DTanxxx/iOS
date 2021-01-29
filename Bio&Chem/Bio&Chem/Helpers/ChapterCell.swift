//
//  ChapterCell.swift
//  Bio&Chem
//
//  Created by David Tan on 2/04/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

class ChapterCell: UITableViewCell {
    
    @IBOutlet var imageV: UIImageView!
    var isTapWithin: Bool!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first {
            let positionWidth = touch.location(in: imageV).x
            let positionHeight = touch.location(in: imageV).y
            
            if positionWidth <= (imageV.frame.width) && positionWidth >= 0 && positionHeight <= (imageV.frame.height) {
                isTapWithin = true
            } else {
                isTapWithin = false
            }
            
        }
    }
       

}
