//
//  ConversationController.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/14/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class ConversationController {
    
    // fetch conversation with the provided identifier
    static func conversationForIdentifier(_ identifier: String, completion: @escaping (_ conversation: Conversation?) -> Void) {
        FirebaseController.dataAtEndPoint("conversations/\(identifier)") { (data) -> Void in
            if let json = data as? [String: AnyObject] {
                let conversation = Conversation(json: json, identifier: identifier)
                completion(conversation)
            } else {
                completion(nil)
                print("ERROR RETREIVING CONVERSATION")
            }
            
        }
    }
    
    // fetch all conversations (conversation list (array)) for that user
    static func fetchAllConversationsForUser(_ userIdentifier: String, completion: @escaping(_ conversation: [Conversation]) -> Void) {
        FirebaseController.observeDataAtEndPoint("users/\(userIdentifier)/conversations") { (data) -> Void in
            if let conversationIDsDictionary = data as? [String: AnyObject] {
                var conversationArray = [Conversation]()
                for conversationID in conversationIDsDictionary {
                    conversationForIdentifier(conversationID.0, completion: { (conversation) in
                        if let conversation = conversation {
                            conversationArray.append(conversation)
                            completion(conversationArray)
                        }
                    })
                }
                
            } else {
                completion([])
            }
            
            
            
        }
    }
    
    // create conversation between current user and selected user
    static func createConversation(_ userOneID: String, conversationID: Conversation ,  userTwoID: String, conversationCreatorID: String, completion: @escaping(_ success: Bool, _ conversation: Conversation?) -> Void) {
        if conversationID.identifier != nil {
            var conversationCreated = Conversation(userOneID: userOneID, userTwoID: userTwoID, creatorID: conversationCreatorID)
            conversationCreated.save()
            UserController.fetchUserForIdentifier(userOneID, completion: { (user) in
                if var userOne = user {
                    saveConversationUnderUser(userOne, conversation: conversationCreated)
                    addMatchIDToUser(userOneID, matchIdentifier: userTwoID)
                    userOne.save()
                }
            })
            UserController.fetchUserForIdentifier(userTwoID, completion: { (user) in
                if var userTwo = user {
                    saveConversationUnderUser(userTwo, conversation: conversationCreated)
                    addMatchIDToUser(userTwoID, matchIdentifier: userOneID)
                    userTwo.save()
                }
            })
            completion(true, conversationCreated)
            
        }
        
    }
    
    // save the conversationIDs and the matchIDs under the usersIDs
    static func saveConversationUnderUser(_ user: User, conversation: Conversation ) {
        var user = user
        let conversation = conversation
        guard let conversationIdentifier = conversation.identifier else {return}
        if let userIdentifier = user.identifier {
            addConversationIDToUser(userIdentifier, conversationIdentifier: conversationIdentifier)
            user.save()
        }
        
    }
    
    // set identifier's value to true to add under the user's ID
    static func addConversationIDToUser(_ userIdentifier: String, conversationIdentifier: String) {
        FirebaseController.ref.child("users/\(userIdentifier)/conversations/\(conversationIdentifier))").setValue(true)
    }
    
    // add match to that user
    static func addMatchIDToUser(_ userIdentifier: String, matchIdentifier: String) {
        FirebaseController.ref.child("users/\(userIdentifier)/matches/\(matchIdentifier)").setValue(true)
    }
    
    // remove conversation from user's conversations
    static func removeConversation(_ conversation: Conversation, completion: @escaping(_ success: Bool) -> Void) {
        if let converationIdentifier = conversation.identifier {
            conversation.delete()
            UserController.fetchUserForIdentifier(converationIdentifier, completion: { (user) in
                completion(true)
            })
        }
        
    }
    // remove match from user's matches
    
    static func removeMatch(_ user: User,  _ matchedUser: User, completion: @escaping(_ success: Bool, _ user: User?) -> Void) {
        
        if let userID = user.identifier {
            
            FirebaseController.ref.child("users/\(userID)/matches/").updateChildValues([matchedUser.identifier! : false])
            UserController.fetchUserForIdentifier(userID, completion: { (user) in
                completion(true, user)
                print("MATCH WAS REMOVED")
            })
        }
        
    }
    
    // get title for the conversation on top , the user who the currentUser is talking to
    static func oppositeUser(conversation: Conversation, userID: String, completion: @escaping(_ user: User?) -> Void) {
        if userID == conversation.userOneID {
            UserController.fetchUserForIdentifier(conversation.userTwoID, completion: { (user) in
                if let user = user {
                    completion(user)
                }
            })
        } else {
            UserController.fetchUserForIdentifier(conversation.userOneID, completion: { (user) in
                if let user = user {
                    completion(user)
                }
            })
        }
    }
    
    // add user to blockedusers list
    static func addUserToBlockedUsersList(_ conversation: Conversation) {
        let currentUserID = UserController.currentUserID
        oppositeUser(conversation: conversation, userID: currentUserID, completion: { (user) in
            
            if let userID = user?.identifier {
                FirebaseController.ref.child("users/\(currentUserID)/blockedUsers").updateChildValues([userID: true])
            }
        })
        removeConversation(conversation, completion: { (true) in
            print("CONVERSATION WAS DELETED")
            
        })
        
        
    }
}
