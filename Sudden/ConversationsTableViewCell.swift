//
//  ConversationsTableViewCell.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/14/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import UIKit

class ConversationsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var conversationText: UILabel!
    
    @IBOutlet weak var userName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateCellWithConversation(_ image: UIImage, name: String, conversationTextMessage: String?) {
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.layer.masksToBounds = true
        userImage.image = image
        userName.text = name
        if let conversationTextMessage = conversationTextMessage {
            conversationText.text = conversationTextMessage
        } else {
            conversationText.text = "Waiting!"
            conversationText.textColor = .red
        }
    }
    
    func updateWithNewConversation(_ image: UIImage, name: String, creatorID: String) {
        var creatorName = ""
        UserController.fetchUserForIdentifier(creatorID) { (user) in
            if let user = user {
                creatorName = user.firstName
                self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2
                self.userImage.layer.masksToBounds = true
                self.userImage.image = image
                self.userName.text = name
                self.conversationText.text = "\(creatorName) Wants To Link You!"
                self.conversationText.textColor = .red
            }
            
        }
    }
    
}
