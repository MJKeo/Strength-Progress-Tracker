//
//  BreakdownGoalTableViewCell.swift
//  Strength Progress Tracker
//
//  Created by Michael Keohane on 5/6/20.
//  Copyright © 2020 Michael Keohne. All rights reserved.
//

import UIKit

class BreakdownGoalTableViewCell: UITableViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var cellImageView: UIView!
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var weightButton: UIButton!
    
    // onClick functionality
    var onClick: () -> Void = { return}
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // This shows the picker
    @IBAction func show(_ sender: Any) {
        self.onClick()
    }
}
