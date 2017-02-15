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
    
    @IBOutlet weak var userOneImage: UIImageView!
    @IBOutlet weak var userTwoImage: UIImageView!
    @IBOutlet weak var introductionMessageTextView: UITextView!
    @IBOutlet weak var connectButtonOutlet: UIButton!
    @IBOutlet weak var cancelButtonOutlet: UIButton!
    
    // MARK: - Delegate property
    
    weak var connectionDelegate: LinkAlertDelegate?  // reason of weak because delegate maintain a weak reference and it's optional, it could go to nil and the program will still work , sometimes it's just a notification tool !!!!!!!! remember!!!!!!!!IMPORTANT!!!!!!
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        // notification to remove blur views
        let removeBlurs = Notification(name: Notification.Name(rawValue: "blursRemoved"), object: nil, userInfo: nil)
        NotificationCenter.default.post(removeBlurs)
        self.removeFromSuperview()
        print("CANCEL BUTTON CLICKED AND BLUR REMOVED SUCCESFULLY!!!!")
        connectionDelegate?.removeBlurEffect(self)
        
    }
    
    @IBAction func connectButtonTapped(_ sender: UIButton) {
        if let userOne = SuddenMainVC.selectedUserOne,
            let userTwo = SuddenMainVC.selectedUserTwo {
            let creatorID = UserController.currentUserID
            ConversationController.createConversation(userOne.identifier!, userTwoID: userTwo.identifier!, conversationCreatorID: creatorID, completion: { (success, conversation) in
                if self.introductionMessageTextView.text == "Type Something..." || self.introductionMessageTextView.text == "" {
                    if let conversationID = conversation?.identifier {
                        var creatorName = ""
                        UserController.fetchUserForIdentifier(UserController.currentUserID, completion: { (user) in
                            if user != nil {
                                creatorName = (user?.firstName)!
                                let text = "\(creatorName) Wants  To Introduce you... "
                                MessageController.createMessage(conversationID, userID: creatorID, text: text, completion: { (message) in
                                    print("message created successfully from the connection Alert CONNECT BUTTON!!!")
                                    // post notification to the observer to get it and remove the blur views
                                    let removeBlurs = Notification(name: Notification.Name(rawValue: "blursRemoved"), object: nil, userInfo: nil)
                                    NotificationCenter.default.post(removeBlurs)
                                    self.connectionDelegate?.removeBlurEffect(self)
                                    self.removeFromSuperview()
                                    
                                })
                            }
                        })
                    }
                } else {
                    if let text = self.introductionMessageTextView.text, let conversationID = conversation?.identifier {
                        MessageController.createMessage(conversationID, userID: creatorID, text: text, completion: { (message) in
                            let removeBlurs = Notification(name: Notification.Name(rawValue: "blursRemoved"), object: nil, userInfo: nil)
                            NotificationCenter.default.post(removeBlurs)
                            print("message created successfully from the connection Alert CONNECT BUTTON!!!")
                            self.connectionDelegate?.removeBlurEffect(self)
                            self.removeFromSuperview()
                            
                        })
                    }
                }
            })
        }
        self.connectionDelegate?.removeBlurEffect(self)
        self.removeFromSuperview()
    }
    
    // MARK: - NIB Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        introductionMessageTextView.delegate = self
        introductionMessageTextView.layer.cornerRadius = 8
        
        if let userOne = SuddenMainVC.selectedUserOne {
            ImageLoader.sharedLoader.imageForUrl(urlString: userOne.profileImageURL!, completionHandler: { (image, url) in
                if let userImage = image {
                    self.userOneImage.image = userImage
                }
            })
        }
        
        if let userTwo = SuddenMainVC.selectedUserTwo {
            ImageLoader.sharedLoader.imageForUrl(urlString: userTwo.profileImageURL!, completionHandler: { (image, url) in
                if let secondUserImage = image {
                    self.userTwoImage.image = secondUserImage
                }
                
            })
        }
        
    }
    // MARK: - textField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        introductionMessageTextView.resignFirstResponder()
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "" || textView.text == "Type Something..." {
            textView.text = ""
            textView.textColor = .black
            textView.layer.borderColor = UIColor.red.cgColor
            textView.layer.borderWidth = 1.0
//            textView.layer.cornerRadius = 5
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Type Something..."
            
        }
        
    }
    
    // Mark:- Text View Delegate
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        introductionMessageTextView.endEditing(true)
    }
}



















