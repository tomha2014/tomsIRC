//
//  ChannelTableViewCell.swift
//  KISS_IRC
//
//  Created by tom hackbarth on 3/20/19.
//  Copyright © 2019 thackbarth.com. All rights reserved.
//

import UIKit

class ChannelTableViewCell: UITableViewCell {



    @IBOutlet weak var title: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
