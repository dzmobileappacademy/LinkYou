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
    
    static var currentUserID = ""
    static var usersArray = [User]()
    static var userOne: User?
    static var userTwo: User?
    
    
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
        FirebaseController.dataAtEndPoint("users/") { (data) in
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
                if FBSDKAccessToken.current() != nil {
                    let accessToken = FBSDKAccessToken.current().tokenString
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken!)
                    FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                        if error != nil {
                            print("SIGN IN WITH FIREBASE FAILED")
                            completion(false)
                        } else {
                            print("YAY LOGIN SUCCESSFULL!!!!")
                            if let mainUser = FIRAuth.auth()?.currentUser?.providerData{
                                for profile in mainUser {
                                    let providerID = profile.providerID
                                    let uid = profile.uid // provider-specific UID
                                    let name = profile.displayName
                                    let email = profile.email
                                    let photoUrl = profile.photoURL
                                    let facebookRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, gender, first_name, last_name, middle_name, picture"])
                                    facebookRequest?.start(completionHandler: { (connection, result, error) in
                                        
                                        if error == nil {
                                            print(result as Any)
                                            let data = result as! NSDictionary
                                            let gender = data.object(forKey: "gender") as! String
                                            
                                            var newUser = User(firstName: name!, profileImageURL: ("\(photoUrl!)"), gender: gender)
                                            newUser.save()
                                            self.currentUserID = uid
                                            completion(true)
                                            
                                        }
                                    })
                                    
                                }
                                
                            }
                        }
                    })
                } else {
                    completion(false)
                }
            }
            
        })
        
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
