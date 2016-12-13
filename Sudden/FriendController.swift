//
//  FriendController.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/14/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import Foundation
class FriendController {
    
    static var friendList = [Friend]()
    static func filterFriends(_ friend: Friend, completion: @escaping(_ success: Bool) -> Void) {
        // create place holder arrays to isoalate already matched users and  display only the users who are not a match yet
        var filteredArray = [Friend]()
        var arrayOfIDs = [String]()
        UserController.fetchUserForIdentifier(friend.id) { (user) in
            if let user = user {
                arrayOfIDs = user.matchesIDs
                filteredArray += friendList.filter({!arrayOfIDs.contains($0.id)})
                completion(true)
            } else {
                print("ERROR SETTING THE FILTRED LIST")
                completion(false)
            }
            
        }
        
        
    }
}
