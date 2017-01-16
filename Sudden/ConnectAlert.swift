//
//  ConnectAlert.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/14/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import UIKit
import Foundation

// create a delegate protocol for notification in other classses
protocol LinkAlertDelegate: class {
    func removeBlurEffect(_ sender: ConnectAlert)
}


class ConnectAlert: UIView, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var connectionLabel: UILabel!
    @IBOutlet weak var userOneImage: UIImageView!
    @IBOutlet weak var userTwoImage: UIImageView!
    @IBOutlet weak var introductionMessageTextView: UITextView!
    @IBOutlet weak var connectButtonOutlet: UIButton!
    @IBOutlet weak var cancelButtonOutlet: UIButton!
    
    // MARK: - Delegate property
    
    weak var connectionDelegate: LinkAlertDelegate?  // reason of weak because delegate maintain a weak reference and it's optional, it could go to nil and the program will still work , sometimes it's just a notification tool !!!!!!!! remember!!!!!!!!IMPORTANT!!!!!!
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.removeFromSuperview()
        
        print("CANCEL BUTTON CLICKED AND BLUR REMOVED SUCCESFULLY!!!!")
        connectionDelegate?.removeBlurEffect(self)
        
    }
    
    @IBAction func connectButtonTapped(_ sender: UIButton) {
        if let userOne = UserController.userOne,
            let userTwo = UserController.userTwo {
            let creatorID = UserController.currentUserID
            ConversationController.createConversation(userOne.identifier!, userTwoID: userTwo.identifier!, conversationCreatorID: creatorID, completion: { (success, conversation) in
                if self.introductionMessageTextView.text == "introduction message" || self.introductionMessageTextView.text == "" {
                    if let conversationID = conversation?.identifier {
                        var creatorName = ""
                        UserController.fetchUserForIdentifier(UserController.currentUserID, completion: { (user) in
                            if user != nil {
                                creatorName = (user?.firstName)!
                                let text = "\(creatorName) Wants  To Introduce you... "
                                MessageController.createMessage(conversationID, userID: creatorID, text: text, completion: { (message) in
                                    self.removeFromSuperview()
                                    print("message created successfully from the connection Alert CONNECT BUTTON!!!")
                                    // post notification to the observer to get it 
                                    let notificationName = Notification.Name("blurRemoved")
                                    NotificationCenter.default.post(name: notificationName, object: nil)
                                    self.connectionDelegate?.removeBlurEffect(self)
                                })
                            }
                        })
                    }
                } else {
                    if let text = self.introductionMessageTextView.text, let conversationID = conversation?.identifier {
                        MessageController.createMessage(conversationID, userID: creatorID, text: text, completion: { (message) in
                            self.removeFromSuperview()
                            print("message created successfully from the connection Alert CONNECT BUTTON!!!")
                            self.connectionDelegate?.removeBlurEffect(self)
                        })
                    }
                }
            })
        }
        
        
    }
    
    // MARK: - NIB Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 4.0
        introductionMessageTextView.delegate = self
        introductionMessageTextView.layer.cornerRadius = 8
        connectButtonOutlet.layer.cornerRadius = 4
        cancelButtonOutlet.layer.cornerRadius = 4
        
        
        if let userOne = UserController.userOne {
            ImageLoader.sharedLoader.imageForUrl(urlString: userOne.profileImageURL!, completionHandler: { (image, url) in
                if let image = image {
                    self.userOneImage.image = image
                }
            })
        }
        
        if let userTwo = UserController.userTwo {
            ImageLoader.sharedLoader.imageForUrl(urlString: userTwo.profileImageURL!, completionHandler: { (image, url) in
                if let image = image {
                    self.userTwoImage.image = image
                }
            })
        }
        
    }
    // MARK: - textField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        introductionMessageTextView.resignFirstResponder()
        return true
    }
    
}



















