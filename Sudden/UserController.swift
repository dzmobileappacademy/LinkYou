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
    
//    static var currentUserID = ""
    static var usersArray = [User]()
    static var userOne: User?
    static var userTwo: User?
    fileprivate let kUser = "userKey"
    static let sharedInstance = UserController()
    
     var currentUser: User! {
        get {
            
            guard let uid = FIRAuth.auth()?.currentUser?.uid,
                let userDictionary = UserDefaults.standard.value(forKey: kUser) as? [String: AnyObject] else {
                    
                    return nil
            }
            
            return User(json: userDictionary, identifier: uid)
        }
        
        set {
            
            if let newValue = newValue {
                UserDefaults.standard.setValue(newValue.jsonValue, forKey: kUser)
                UserDefaults.standard.synchronize()
            } else {
                UserDefaults.standard.removeObject(forKey: kUser)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    
    
    // Fetch user from Firebase with the provided identifier
    static func fetchUserForIdentifier(_ identifier: String, completion: @escaping (_ user: User?) -> Void) {
        FirebaseController.dataAtEndPoint("users/\(identifier)") { (data) -> Void in
            
            if let json = data as? [String: AnyObject] {
                let user = User(json: json, identifier: identifier)
                completion(user)
            } else {
                completion(nil)
            }
        }
    }
    
    // Fetch All Users images From Firebase
    
    static func fetchAllUsers(_ completion: @escaping(_ users: [User]?) -> Void) {
        FirebaseController.observeDataAtEndPoint("users") { (data) in
            if let json = data as? [String: AnyObject] {
                let users = json.flatMap({User(json: $0.1 as! [String: AnyObject], identifier: $0.0)})
                completion(users)
            } else {
                completion([])
                print("empty array ya si youcef")
            }

        }
        
    }
    
    // Create User and Login
    
        static func createAndLogin(_ viewController: UIViewController, completion: @escaping(_ success: Bool) -> Void) {
        let loginManager = FBSDKLoginManager()
        loginManager.loginBehavior = .systemAccount
        loginManager.logOut()
        
        loginManager.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: viewController) { (result, error) in
            if error != nil {
                print("login failed")
                completion(false)
            } else if (result?.isCancelled)! {
                print("login is canceled")
                completion(false)
                
            } else {
                let accessToken = FBSDKAccessToken.current().tokenString
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken!)
                FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                    if error != nil {
                        print("sign in with firebase failed")
                        completion(false)
                    } else {
                        print("login successfull")
                        if let user = FIRAuth.auth()?.currentUser?.providerData {
                            for profile in user {
//                                let providerID = profile.providerID
                                let uid = profile.uid
                                let name = profile.displayName
                                let photoURL = profile.photoURL
                                if(FBSDKAccessToken.current() != nil) {
                                    let facebookRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, gender, first_name, last_name, middle_name, picture.type(normal) "])
                                    facebookRequest?.start(completionHandler: { (connection, result, error) in
                                        if error == nil {
                                            let data = result as! NSDictionary
                                            let gender = data.object(forKey: "gender") as! String
                                            var newUser = User(firstName: name!, profileImageURL: ("\(photoURL!)"), gender: gender)
                                            newUser.save()
                                            UserController.fetchUserForIdentifier(newUser.identifier!, completion: { (user) in
                                                if let user = user {
                                                    sharedInstance.currentUser = user
                                                    completion(true)
                                                    print(uid)
                                                } else {
                                                    completion(false)
                                                }
                                            })
                                            
                                            
                                            
                                            
                                        }
                                    })
                                }
                                completion(true)
                            }
                        }
                    }
                })
            }
        }
        
    }
    
    
    // Get Facebook Friend List for future reference only. not used on this app
    
    //    static func getFriendsList(_ completion: @escaping (_ users: [User]) -> Void) {
    //        let facebookRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: ["fields": "id, first_name, last_name, middle_name, email, images, picture"])
    //        facebookRequest?.start(completionHandler: { (connection:FBSDKGraphRequestConnection?, result: Any?, error: Error?) in
    //            if error == nil {
    //
    //
    //                // no errors!! great.. now get some facebook friends
    //                var users = [User]()
    //                let resultDictionary = result as! NSDictionary
    //                print("RESULT DICTIOINARY: \(resultDictionary)")
    //                var data: Array = resultDictionary["data"] as! NSArray as Array
    //                for i in 0..<data.count {
    //                    let valueDictionary = data[i]  as? NSDictionary
    //                    let firstName = valueDictionary?.object(forKey: "first_name") as! String
    //                    let id = valueDictionary?.object(forKey: "id") as! String
    //                    guard let picture = valueDictionary?.object(forKey: "picture") as? [String: AnyObject] else  {return}
    //                    guard let data = picture["data"] as? [String: AnyObject] else {return}
    //                    guard let imageURL = data ["url"] as? String else {return print("failed loading the profile picture")}
    //
    //                    let user = User(firstName: firstName, profileImageURL: imageURL)
    //                    users.append(user)
    //                }
    //
    //
    //
    //                completion(users)
    //                print("FACEBOOK FRIENDS LIST: \(users)")
    //
    //
    //
    //
    //            } else {
    //                print("ERROR LOADING FRIENDS FROM FACEBOOK: \(error?.localizedDescription)")
    //            }
    //
    //
    //        })
    //
    //
    //    }
    
    
    // Logout
    
    static func logout() {
        FBSDKLoginManager().logOut()
    }
    
}
