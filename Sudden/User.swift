//
//  User.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/14/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import Foundation

class User: FirebaseType {
    
    let KFirstName = "firstName"
    let imageURL = "imageURL"
    let gender = "gender"
    let conversations = "conversations"
    let matches = "matches"
    let blockedUsers = "blockedUsers"
    
    
    let firstName: String
    var imageURL: String
    var gender: String
    var conversations: [Conversation]
    var messages: [Message]
    var matches: [User]
    var blockedUsers: [User]
    var identifier: String?
    var endpoint: String {
        return "users"
    }
    
    var jsonValue: [String : AnyObject] {
        return
    }
    
    init(firstName: String, imageURL: String, gender: String, conversations: [Converssation] = [], messages: [Message] = [], blockedUsers: [User] = [],  ) {
        <#statements#>
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
