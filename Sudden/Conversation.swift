//
//  Conversation.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/14/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import Foundation

class Conversation: FirebaseType{
    
    let KUserOneID = "userOne"
    let KUserTwoID = "userTwo"
    let KCreatorID = "creatorID"
    var creatorID: String
    var userOneID: String
    var userTwoID: String
    var messages: [Message] = []
    var identifier: String?
    var endpoint: String {
        return "conversations"
    }
    
    var jsonValue: [String : AnyObject] {
        return [KUserOneID: userOneID as AnyObject, KUserTwoID: userTwoID as AnyObject, KCreatorID: creatorID as AnyObject]
    }
    
    init(userOneID: String, userTwoID: String, creatorID: String) {
        self.userOneID = userOneID
        self.userTwoID = userTwoID
        self.creatorID = creatorID
    }
    
    required init?(json: [String : AnyObject], identifier: String) {
        guard let userOneID = json[KUserOneID] as? String,
            let creatorID = json[KCreatorID] as? String,
            let userTwoID = json[KUserTwoID] as? String else {return nil}
        self.userTwoID = userTwoID
        self.userOneID = userOneID
        self.identifier = identifier
        self.creatorID = creatorID
    }
    
    
    
}
