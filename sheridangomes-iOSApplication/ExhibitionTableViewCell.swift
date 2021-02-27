//
//  ExhibitionTableViewCell.swift
//  sheridangomes-iOSApplication
//
//  Created by Sheridan's Lair on 13/09/20.
//  Copyright © 2020 monash. All rights reserved.
//

import UIKit

class ExhibitionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
