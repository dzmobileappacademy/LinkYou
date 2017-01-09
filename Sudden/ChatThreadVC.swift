//
//  ChatThreadVC.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/16/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import UIKit

class ChatThreadVC: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    var conversation: Conversation?
    var messagesArray: [Message] = []
    var currentUserID = UserController.currentUserID

    @IBOutlet weak var oppositeUserImage: UIImageView!
    @IBOutlet weak var cameraButtonOutlet: UIButton!
    @IBOutlet weak var sendButtonTapped: UIButton!
    @IBOutlet weak var typeMessageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var typingTextContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the opposite user image and also the title of the navigation as the opposite username

    }
    
    // send Click ==> save  message(text, conversationID, sendID) to firebase
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        if let text = typeMessageTextField.text, let conversationID = self.conversation?.identifier {
            MessageController.createMessage(conversationID, userID: currentUserID, text: text, completion: { (message) in
                self.typeMessageTextField.resignFirstResponder()
                self.typeMessageTextField.text = ""
                
                
            })
        }
    }
    

    @IBAction func cameraButtonTapped(_ sender: UIButton) {
    }
    
    // query for messages
    func queryForMessage(_ conversation: Conversation) {
        self.conversation = conversation
        MessageController.queryForMessages(conversation) { (messages) in
            self.messagesArray = conversation.messages
            self.messagesArray.sort(by: {$0.0.identifier! < $0.1.identifier!})
            DispatchQueue.main.async(execute: { 
                self.tableView.reloadData()
            })
        }
    }

}

extension ChatThreadVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messagesArray[indexPath.row]
        if (conversation?.userOneID == currentUserID) && (conversation?.userOneID == message.senderID) || (conversation?.userTwoID == currentUserID) && (conversation?.userTwoID == message.senderID) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "goingMessage", for: indexPath) as! ChatThreadTableViewCell
            cell.updateWithOutGoingMessage(message)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "comingMessage", for: indexPath) as! ChatThreadTableViewCell
            cell.updateWithInComingMessage(message)
            return cell
            
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
}
