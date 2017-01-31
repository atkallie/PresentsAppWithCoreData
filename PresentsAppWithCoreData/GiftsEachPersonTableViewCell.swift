//
//  GiftsEachPersonTableViewCell.swift
//  PresentsAppWithCoreData
//
//  Created by Ahmed T Khalil on 1/28/17.
//  Copyright © 2017 kalikans. All rights reserved.
//

import UIKit

class GiftsEachPersonTableViewCell: UITableViewCell {
    
    @IBOutlet var name: UILabel!
    @IBOutlet var gift: UILabel!
    @IBOutlet var personImage: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
