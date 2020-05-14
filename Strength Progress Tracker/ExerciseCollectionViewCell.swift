//
//  ExerciseCollectionViewCell.swift
//  Strength Progress Tracker
//
//  Created by Michael Keohane on 4/17/20.
//  Copyright © 2020 Michael Keohne. All rights reserved.
//

import UIKit

class ExerciseCollectionViewCell: UICollectionViewCell {
    // display items
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellName: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var button: UIButton!
    
    // onClick functionality
    var onClick: (String) -> () = {_ in return}
    
    
    @IBAction func clicked(_ sender: Any) {
        onClick(cellName.text!)
    }
    
}
