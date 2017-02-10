//
//  ConversationsListTVC.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/16/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import UIKit

class ConversationsListTVC: UITableViewController {
    var conversationArray = [Conversation]()
    let currentUserID = UserController.currentUserID
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Conversations"
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateWithConversations()
        
    }
    
    // MARK: - UPDATEWITHCONVERSATION FUNCTION
    func updateWithConversations() {
        ConversationController.fetchAllConversationsForUser(currentUserID) { (conversations) in
            self.conversationArray = conversations
            self.tableView.reloadData()
        }
    }
    
    // REFRECH TABLEVIEW
    func refresh() {
        updateWithConversations()
        refreshControl?.endRefreshing()
    }
    
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if conversationArray.count > 0 {
            return  conversationArray.count
        } else {
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationCellIdentifier", for: indexPath) as! ConversationsTableViewCell
        // Configure the cell...
        let conversation = conversationArray[indexPath.row]
        var messagesArray: [Message]?
        MessageController.queryForMessages(conversation) {(messages) in
            messagesArray = messages?.sorted(by: {$0.identifier! < $1.identifier!})
        }
        ConversationController.oppositeUser(conversation: conversation, userID: currentUserID) { (user) in
            ImageLoader.sharedLoader.imageForUrl(urlString: (user?.profileImageURL)!, completionHandler: { (image, url) in
                if let image = image {
                    if (messagesArray?.count)! > 1 {
                        cell.updateCellWithConversation(image, name: (user?.firstName)!, conversationTextMessage: messagesArray?.last?.text)
                    } else {
                        cell.updateWithNewConversation(image, name: (user?.firstName)!, creatorID: conversation.creatorID)
                    }
                }
                
            })
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let conversation = conversationArray[indexPath.row]
            ConversationController.removeConversation(conversation, completion: { (true) in
                conversation.delete()
                self.updateWithConversations()
            })
            
            //tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    // MARK: - Navigation
    
    //      In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //      Get the new view controller using segue.destinationViewController.
        if segue.identifier == "showConversations" {
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                let chatThread = segue.destination as! ChatThreadVC
                let conversation = conversationArray[indexPath.row]
                chatThread.conversation = conversation
                chatThread.queryForMessage(conversation)
                
                
            }
            
        }
        
        
        //      Pass the selected object to the new view controller.
    }
    
    
}
