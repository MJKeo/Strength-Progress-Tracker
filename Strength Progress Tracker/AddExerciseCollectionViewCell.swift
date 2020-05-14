//
//  AddExerciseCollectionViewCell.swift
//  Strength Progress Tracker
//
//  Created by Michael Keohane on 4/24/20.
//  Copyright © 2020 Michael Keohne. All rights reserved.
//

import UIKit

class AddExerciseCollectionViewCell: UICollectionViewCell {
    // display items
    @IBOutlet weak var mainView: UIView!
    
    // onClick functionality
    var onClick: () -> () = { return}
    
    @IBAction func doAction(_ sender: Any) {
        onClick()
    }
    
}
