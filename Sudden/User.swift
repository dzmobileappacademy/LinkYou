//
//  User.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/14/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import Foundation
import UIKit
class User: FirebaseType {
    
    let KFirstName = "firstName"
    let KprofileImageURL = "imageURL"
//    let Kgender = "gender"
    let Kconversations = "conversations"
    let Kmatches = "matches"
    let KblockedUsers = "blockedUsers"
    let KblockedUsersIDs = "blockedUsersIDs"
    let KmatchesIDs = "matchesIDs"
    let KconversationIDs = "conversationIDs"
    
    let firstName: String
    var profileImage: UIImage?
    var profileImageURL: String?
//    let gender: String
    var conversations = [Conversation]()
    var conversationsIDs: [String] = []
    var blockedUsersIDs: [String] = []
    var matchesIDs: [String] = []
    var matches =  [User]()
    var blockedUsers = [User]()
    var identifier: String?
    var endpoint: String {
        return "users"
    }
    // representing our model object in firebase as dictionaries, FIREBASE DOES NOT USE ARRAYS, INSTEAD IT USES DICTIONARIES. [A, B, C] >>>>> {0: A, 1: B, 2: C} in firebase
    
    var jsonValue: [String : AnyObject] {
        return [KFirstName: firstName as AnyObject, KprofileImageURL: profileImageURL as AnyObject]
    }
    
    init(firstName: String, profileImageURL: String) {
        self.firstName = firstName
        self.profileImageURL = profileImageURL
//        self.gender = gender
        
        var conversationIdentifiers: [String] = [] // because we are using the identifiers system we have to do that in the initialization
        for conversation in conversations {
            if let identifier = conversation.identifier {
                conversationIdentifiers.append(identifier)
            }
        }
        self.conversationsIDs = conversationIdentifiers
        
        var blockedUserIdentifiers = [String]()
        for blockedUser in blockedUsers {
            if let identifier = blockedUser.identifier {
                blockedUserIdentifiers.append(identifier)
            }
        }
        self.blockedUsersIDs = blockedUserIdentifiers
        
        var matchesIdentifiers = [String]()
        for match  in matches {
            if let identifier = match.identifier {
                matchesIdentifiers.append(identifier)
            }
        }
        self.matchesIDs = matchesIdentifiers
    }
    
    // converting the firebase dictionaries to model objects we can use
    
    required init?(json: [String : AnyObject], identifier: String) {
        guard let firstName = json[KFirstName] as? String,
//            let gender = json[Kgender] as? String,
            let profileImageURL = json[KprofileImageURL] as? String else {return nil}
        self.firstName = firstName
//        self.gender = gender
        self.profileImageURL = profileImageURL
        self.identifier = identifier
        
        if let blockedUsersIDS = json[KblockedUsers] as? [String: AnyObject] {
            self.blockedUsersIDs = blockedUsersIDS.flatMap({$0.0})  // we are interested only in the IDs that's why we did not put the actual Model in flatmap, the $0 refers to the element of the [String (0): AnyObject (1)]  this is because swift inters that as a tuple (key, value) and it gives $0.0 to the key and $0.1 to the value
        } else {
            self.blockedUsersIDs = []
        }
        
        if let conversationsIDS = json[Kconversations] as? [String] { // the reason why this is only [String] is because we structured it in firebase as a list of conversation IDs in an array
            self.conversationsIDs = conversationsIDS
        } else {
            self.conversationsIDs = []
        }
        
        if let matchesIDS = json[Kmatches] as? [String: AnyObject] {
            self.matchesIDs = matchesIDS.flatMap({$0.0})
        } else {
            self.matchesIDs = []
        }
        
    }
    
}
