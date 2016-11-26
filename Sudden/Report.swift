//
//  Report.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/14/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import Foundation

class Report: FirebaseType {
    let KblockerID = "blocker"
    let KuserID = "userID"
    var userID: String
    var blockerID: String
    var identifier: String?
    var endpoint: String {
        return "reports"
    }
    var jsonValue: [String : AnyObject] {
        return [KuserID: userID as AnyObject, KblockerID: blockerID as AnyObject]
    }
    init(userID: String, blockerID: String) {
        self.userID = userID
        self.blockerID = blockerID
    }
    
    required init?(json: [String : AnyObject], identifier: String) {
        guard let userID = json[KuserID] as? String,
            let blockerID = json[KblockerID] as? String else {return nil }
        self.userID = userID
        self.blockerID = blockerID
        self.identifier = identifier
    }
}
