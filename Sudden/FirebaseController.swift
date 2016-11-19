//
//  FirebaseController.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/18/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth

class FirebaseController {
    
    static let ref = FIRDatabase.database().reference()
    
    // fetch data at endpoint in firebase and return it via completion closure
    static func dataAtEndPoint(_ endpoint: String, completion: @escaping (_ data: AnyObject?) -> Void) {
        let baseForEndPoint = FirebaseController.ref.child(endpoint)
        baseForEndPoint.observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.value is NSNull {
                completion(nil)
            } else {
                completion(snapshot.value as AnyObject?)
            }
        })
    }
    
    // fetch data at endpoint in firebase and run the completion closure each time the data at endpoint changes
    static func observeDataAtEndPoint(_ endpoint: String, completion: @escaping (_ data: AnyObject?) -> Void) {
        let baseForEndPoint = FirebaseController.ref.child(endpoint)
        baseForEndPoint.observe(.value, with: { FIRDataSnapshot in
            if FIRDataSnapshot.value is NSNull {
                completion(nil)
            } else {
                completion(FIRDataSnapshot.value as AnyObject?)
            }
        })
    }
}

protocol FirebaseType {
    var identifier: String? {get set}
    var endpoint: String {get}
    var jsonValue: [String: AnyObject] {get}
    init?(json: [String: AnyObject], identifier: String)
    mutating func save()
    func delete()
}

extension FirebaseType {
    mutating func save() {
        var endpointBase: FIRDatabaseReference
        if let identifier = self.identifier {
            endpointBase = FirebaseController.ref.child(endpoint).child(identifier)
            
        } else {
            endpointBase = FirebaseController.ref.child(endpoint).childByAutoId()
            self.identifier = endpointBase.key
        }
        endpointBase.updateChildValues(self.jsonValue)
    }
    func delete() {
        if let identifier = self.identifier {
            let endpointBase = FirebaseController.ref.child(endpoint).child(identifier)
            endpointBase.removeValue()
        }
    }
}














