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
    
    @IBOutlet weak var commingMessageViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var goingMessageViewConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension ChatThreadTableViewCell {
    
    func updateWithOutGoingMessage(_ message: Message) {
        switch message.text.characters.count {
        case 1...5: goingMessageViewConstraint.constant = 280
        case 6...20: goingMessageViewConstraint.constant = 240
        case 21...30: goingMessageViewConstraint.constant = 180
        default:
            goingMessageViewConstraint.constant = 120
        }
        goingMessageLabel.text = message.text
        goingMessageContainerView.layer.cornerRadius = 7
        
    }
    
    func updateWithInComingMessage(_ message: Message) {
        switch message.text.characters.count {
        case 1...5: commingMessageViewConstraint.constant = 280
        case 6...20: commingMessageViewConstraint.constant = 240
        case 21...30: commingMessageViewConstraint.constant = 180
        default:
            commingMessageViewConstraint.constant = 120
        }
        comingMessageLabel.text = message.text
        comingMessageContainerView.layer.cornerRadius = 7
        
    }
    
    
    
    
    
    
    
    
    
    
    
}
