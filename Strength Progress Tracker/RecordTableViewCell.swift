//
//  RecordTableViewCell.swift
//  Strength Progress Tracker
//
//  Created by Michael Keohane on 5/4/20.
//  Copyright © 2020 Michael Keohne. All rights reserved.
//

import UIKit

class RecordTableViewCell: UITableViewCell {
    
    // component variables
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var exerciseIcon: UIImageView!
    @IBOutlet weak var exerciseTitle: UILabel!
    @IBOutlet weak var bestORMLabel: UILabel!
    @IBOutlet weak var StrengthLevelView: UIView!
    @IBOutlet weak var StrengthLevelText: UILabel!
    @IBOutlet weak var iconView: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: false)
    }

}
