//
//  FriendController.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/14/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import Foundation
class FriendController {
    
    static var allUsersList = [User]()
    static var filtredListOfUsers = [User]()
    
    // get the complete array of facebook friends to use to display friends
    static func getUsers(_ users: [User]) -> [User] {
        UserController.fetchUserForIdentifier(UserController.currentUserID) { (user) in
            if user != nil {
                allUsersList = users
                
            }
            
        }
        return allUsersList
    }
    
    
    
    // logic for the filtered array that does not contain already matched Identifers (matchIDS)
    static func filtredUsers(_ user: User, completion: @escaping(_ success: Bool) -> Void) {
        // create place holder arrays to isoalate already matched users and  display only the users who are not a match yet
        var filteredArray = [User]()
        var AlreadyMatchedIDs = [String]()
        if let identifier = user.identifier {
            UserController.fetchUserForIdentifier(identifier) { (user) in
                if let user = user {
                    AlreadyMatchedIDs = user.matchesIDs
                    filteredArray += allUsersList.filter({!AlreadyMatchedIDs.contains($0.identifier!)})
                    filtredListOfUsers = filteredArray
                    completion(true)
                } else {
                    print("ERROR SETTING THE FILTRED LIST")
                    completion(false)
                }
            }
        
        }
    }
}
