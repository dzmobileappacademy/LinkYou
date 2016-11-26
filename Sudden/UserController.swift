//
//  UserController.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/14/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import Foundation
import Firebase
import FBSDKLoginKit
import FBSDKShareKit
import FBSDKCoreKit
import FirebaseAuth

class UserController {
    
    static var currentUser = ""
    
    
    // Fetch user from Firebase with the provided identifier
    static func fetchUserForIdentifier(_ identifier: String, completion: @escaping (_ user: User?) -> Void) {
//        FirebaseController.dataAtEndPoint(<#T##endpoint: String##String#>, completion: <#T##(AnyObject?) -> Void#>)
    }
    
    // Create User and Login
    
    static func createAndLogin(_ viewController: UIViewController, completion: @escaping (_ success: Bool) -> Void) {
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: viewController, handler: { (result, error) -> Void in
            if error != nil {
                print("login FAILED")
                completion(false)
            } else if (result?.isCancelled)!{
                print("login is CANCELLED")
                completion(false)
            } else {
                let accessToken = FBSDKAccessToken.current().tokenString
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken!)
                FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                    if error != nil {
                        print("SIGN IN WITH FIREBASE FAILED")
                        completion(false)
                    } else {
                        print("YAY LOGIN SUCCESSFULL!!!!")
                        if let user = FIRAuth.auth()?.currentUser {
                            for profile in user.providerData {
                                let providerID = profile.providerID
                                let uid = profile.uid // provider-specific UID
                                let name = profile.displayName
                                let email = profile.email
                                let photoURL = profile.photoURL
                                
                            var newUser = User(firstName: name!, profileImageURL: ("\(photoURL!)"))
                                newUser.save()
                                self.currentUser = uid
                                completion(true)
                                
                                
                            }
                        } else {
                            print("NO USER IS SIGNED-IN")
                        }
                    }
                })
            }
            
        })
    
    }
    
    
    // Get Facebook Friend List

    
    // Logout
    
    static func logout() {
        FBSDKLoginManager().logOut()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
        
    
    
}
