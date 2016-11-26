//
//  Message.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/14/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import Foundation

class Message: FirebaseType {
    let KsenderID = "senderID"
    let KconversationID = "conversationID"
    let Ktext = "text"
    
    var senderID: String
    var text: String
    var conversationID: String
    var identifier: String?
    var endpoint: String {
        return "Messages"
    }
    var jsonValue: [String : AnyObject] {
        return  [KsenderID: senderID as AnyObject, KconversationID: conversationID as AnyObject, Ktext: text as AnyObject]
    }
    
    init(senderID: String, conversationID: String, text: String) {
        self.conversationID = conversationID
        self.senderID = senderID
        self.text = text
    }
    
    required init?(json: [String : AnyObject], identifier: String) {
        guard let senderID = json[KsenderID] as? String,
            let text = json[Ktext] as? String,
            let conversationID = json[KconversationID] as? String else {return nil}
        self.identifier = identifier
        self.senderID = senderID
        self.conversationID = conversationID
        self.text = text
        
    }
    
    
    
}
