//
//  ParkTableViewCell.swift
//  PA Parks
//
//  Created by Pranav Jain on 9/30/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import UIKit

class ParkTableViewCell: UITableViewCell {

    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var parkImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
