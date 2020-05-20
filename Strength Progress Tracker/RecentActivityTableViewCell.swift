//
//  RecentActivityTableViewCell.swift
//  Strength Progress Tracker
//
//  Created by Michael Keohane on 5/19/20.
//  Copyright © 2020 Michael Keohne. All rights reserved.
//

import UIKit

class RecentActivityTableViewCell: UITableViewCell {

    // visuals
    @IBOutlet weak var ORMLabel: UILabel!
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    // variables
    var id: String!
    
    // onClick functionality
    var onClick: (String) -> Void = { _ in return}
    
    @IBAction func deleteActivity(_ sender: Any) {
        onClick(self.id)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
