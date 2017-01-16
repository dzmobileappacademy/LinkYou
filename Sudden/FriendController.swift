//
//  FriendController.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/14/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import Foundation
class FriendController {
    static var totalUsersList: [User] = []
    static var topFiltredListOfUsers = [User]()
    static var bottomFiltredListOfUsers = [User]()
    static var sameGenderUserList = [User]()
    static var oppositeGenderList = [User]()
    
    
    // get the complete array of facebook friends to use to display friends
//    static func getUsers() -> [User] {
//        UserController.fetchUserForIdentifier(UserController.currentUserID) { (user) in
//            if user != nil {
//                self.totalUsersList.append(user)
//                
//            }
//            
//        }
//        return totalUsersList
//    }
    // get opposite users list
    static func oppositeUserGenderList(_ users: [User]) -> [User] {
        UserController.fetchUserForIdentifier(UserController.currentUserID) { (user) in
            if let user = user {
                if user.gender == "male" {
                    oppositeGenderList += users.filter({$0.gender == "female"})
                } else {
                    oppositeGenderList += users.filter({$0.gender == "male"})
                }
            }
        }
        return oppositeGenderList
    }
    
    // get same gender users list
    static func sameGenderList(_ users: [User]) -> [User] {
        UserController.fetchUserForIdentifier(UserController.currentUserID) { (user) in
            if let user = user {
                if user.gender == "male" {
                    sameGenderUserList += users.filter({$0.gender == "male"})
                } else {
                    sameGenderUserList += users.filter({$0.gender == "female"})
                    
                }
                
            }
        }
        return sameGenderUserList
    }
    
    
    // logic for the filtered array that does not contain already matched Identifers (matchIDS)
    static func filtredUsers(_ user: User, isBottom: Bool, usersListKind: [User], completion: @escaping(_ success: Bool) -> Void) {
        // create place holder arrays to isoalate already matched users and  display only the users who are not a match yet
        var filteredArray = [User]()
        var AlreadyMatchedIDs = [String]()
        if let identifier = user.identifier {
            UserController.fetchUserForIdentifier(identifier) { (user) in
                if let user = user {
                    AlreadyMatchedIDs = user.matchesIDs
                    filteredArray += usersListKind.filter({!AlreadyMatchedIDs.contains($0.identifier!)})
                    if isBottom {
                        bottomFiltredListOfUsers = filteredArray
                        completion(true)
                        
                    } else {
                        topFiltredListOfUsers = filteredArray
                        completion(true)
                    }
                } else {
                    print("ERROR SETTING TOP OR BOTTOM LIST")
                    completion(false)
                }
            }
            
        }
    }
}
