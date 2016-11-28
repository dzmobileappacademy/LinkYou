//
//  Friend.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/14/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import Foundation

class Friend: Equatable {
    
    var id: String
    var firstName: String
//    var profileURL: String
    var profilePicture: String
//    var gender: String
    
    init(id: String, profilePicture: String, firstName: String) {
//        self.gender = gender
//        self.profileURL = profileURL
        self.profilePicture = profilePicture
        self.id = id
        self.firstName = firstName
    }
    
}

// equatable function to conform to equatable protocol and to be able to compare stuff together

func ==(rhs: Friend, lhs: Friend) -> Bool {
    return lhs.id == rhs.id
}
