//
//  ChatThreadTableViewCell.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/14/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import UIKit

class ChatThreadTableViewCell: UITableViewCell {
    
    @IBOutlet weak var goingMessageContainerView: UIView!
    
    @IBOutlet weak var goingMessageLabel: UILabel!
    
    @IBOutlet weak var comingMessageContainerView: UIView!
    
    @IBOutlet weak var comingMessageLabel: UILabel!
    
    @IBOutlet weak var userConnectorPicture: UIImageView!
    
    
    
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
