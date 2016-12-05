//
//  MessageController.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/14/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import Foundation
class MessageController {
    
    // Fetch message with the provided identifier
    static func fetchMessageForIdentifier(_ identifier: String, completion: @escaping(_ message: Message?) -> Void) {
        FirebaseController.dataAtEndPoint("Messages/\(identifier)") { (data) in
            if let json = data as? [String: AnyObject] {
                let message = Message(json: json, identifier: identifier)
                completion(message)
            } else {
                print(" COULD NOT PULLUP MESSAGE FOR THE SPECIFIED IDENTIFIER")
                completion(nil)
            }
        }
    }
    
    
    // create message
    
    static func createMessage(_ conversationID: String, userID: String, text: String, completion: @escaping(_ message: Message?) -> Void) {
        var message = Message(senderID: userID, conversationID: conversationID, text: text)
        message.save()
        completion(message)
    }
    
    // query for message
    static func queryForMessages(_ conversation: Conversation, completion: @escaping(_ messages: [Message]?) -> Void) {
        if let conversationID = conversation.identifier {
            FirebaseController.ref.child("messages").queryOrdered(byChild: "conversation").queryEqual(toValue: conversationID).observeSingleEvent(of: .value, with: { (snapshot) in
                if let messagesDictionaries = snapshot.value as? [String: AnyObject] {
                    let messages = messagesDictionaries.flatMap({Message(json: $0.1 as! [String : AnyObject] , identifier: $0.0)})
                    conversation.messages = messages
                    completion(conversation.messages)
                }
            })
        }
    }
}
