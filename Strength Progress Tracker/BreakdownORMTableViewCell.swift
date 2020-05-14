//
//  BreakdownORMTableViewCell.swift
//  Strength Progress Tracker
//
//  Created by Michael Keohane on 5/6/20.
//  Copyright © 2020 Michael Keohne. All rights reserved.
//

import UIKit

class BreakdownORMTableViewCell: UITableViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var cellImageView: UIView!
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
