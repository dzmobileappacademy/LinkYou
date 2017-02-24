//
//  ReportController.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/14/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import Foundation
class ReportController {
    
    // create the report endpoint in firebase
    static func createReport(_ conversation: Conversation) {
        let currentUserID = UserController.sharedInstance.currentUser.identifier
        ConversationController.oppositeUser(conversation: conversation, userID: currentUserID!) { (user) in
            if let userID = user?.identifier {
                var report = Report(userID: userID, blockerID: currentUserID!)
                report.save()
                print("\(userID) blocked by \(currentUserID)")
            }
            
            
        }
        
    }
}
