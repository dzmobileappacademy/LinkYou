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
    static var sharedInstance = UserController()
    static var facebookFriendsArray = [Friend]()
    
    
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
                                
                                // call facebook friends list function
                                getFriendsList({ (friends) in
                                    DispatchQueue.main.async {
                                        self.facebookFriendsArray = friends
                                        
                                    }
                                })
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
    
    static func getFriendsList(_ completion: @escaping (_ friends: [Friend]) -> Void) {
        let facebookRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: ["fields": "id, first_name, last_name, middle_name, email, picture.type(large)"])
        facebookRequest?.start(completionHandler: { (connection:FBSDKGraphRequestConnection?, result: Any?, error: Error?) in
            if error == nil {
                
                
                // no errors!! great.. now get some facebook friends
                var friends = [Friend]()
                let resultDictionary = result as! NSDictionary
                print("RESULT DICTIOINARY: \(resultDictionary)")
                var data: Array = resultDictionary["data"] as! NSArray as Array
                for i in 0..<data.count {
                    let valueDictionary = data[i]  as? NSDictionary
                    let firstName = valueDictionary?.object(forKey: "first_name") as! String
                    let id = valueDictionary?.object(forKey: "id") as! String
                    guard let picture = valueDictionary?.object(forKey: "picture") as? [String: AnyObject] else  {return}
                    guard let data = picture["data"] as? [String: AnyObject] else {return}
                    guard let imageURL = data ["url"] as? String else {return print("failed loading the profile picture")}
                    
                    let friend = Friend(id: id, profilePicture: imageURL, firstName: firstName)
                    friends.append(friend)
                    print("FACEBOOK FRIENDS LIST: \(friends)")
                }
                
                completion(friends)
                print("FACEBOOK FRIENDS LIST: \(friends)")
                
                
                
                
            } else {
                print("ERROR LOADING FRIENDS FROM FACEBOOK: \(error?.localizedDescription)")
            }
            
            
        })
        
        
    }
    
    
    // Logout
    
    static func logout() {
        FBSDKLoginManager().logOut()
    }
    
}
