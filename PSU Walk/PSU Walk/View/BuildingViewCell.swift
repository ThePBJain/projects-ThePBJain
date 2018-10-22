//
//  BuildingViewCell.swift
//  PSU Walk
//
//  Created by Pranav Jain on 10/15/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import UIKit

class BuildingViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var code: UILabel!
    
    var indexPath : IndexPath?
    
    let walkModel = WalkModel.sharedInstance
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
