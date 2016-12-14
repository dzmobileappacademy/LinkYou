//
//  SuddenMainVC.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/14/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import UIKit

class SuddenMainVC: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    // MARK: - Properties
    static var isUserSelected: Bool =  false // switch property to see if user is selected or not . default to false because users are not selected yet at first.
    var selectedUsersList = [UIImage]()  // array of selected items in the collectionView. if selected => add to the array, if not => remove from the array
    var checkedIndexPaths = Set<IndexPath>()
    var selectedUser: Friend?
    var blurEffectView: UIVisualEffectView!
    
    //MARK: - IBOutlets
    @IBOutlet weak var matchButtonOutlet: UIButton!
    
    @IBOutlet weak var userCV: UICollectionView!
    
    @IBOutlet weak var conversationsButtonOutlet: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userCV.reloadData()
        matchButtonOutlet.isHidden = true
        
    }
    
    // tap connect button, bring connectionAlert.XIB up front view
    @IBAction func connectButtonTapped(_ sender: UIButton) {
        let connectAlert = UINib(nibName: "ConnectAlert", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UIView
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view.addSubview(blurEffectView)
        connectAlert?.frame = CGRect(x: (UIScreen.main.bounds.width / 2) - ((connectAlert?.frame.width)! / 2), y: (self.view.frame.height / 2) - ((connectAlert?.frame.height)! / 2), width: (connectAlert?.frame.width)!, height: (connectAlert?.frame.height)!)
        connectAlert?.layer.cornerRadius = 12
        self.view.addSubview(connectAlert!)
        
    }
    
    // tap conversationbutton, go to "conversationsList,matches, waiting list" table view
    @IBAction func conversationsButtonTapped(_ sender: UIBarButtonItem) {
    }
    
    // MARK: - Collection View DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserController.facebookFriendsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "friendCollectionViewIdentifier", for: indexPath) as! FriendCollectionViewCell
        let friend = UserController.facebookFriendsArray[indexPath.item]
        if let friendImage = friend.profilePicture {
            cell.updateWith(friendImage, username: friend.firstName)
            cell.isChecked = self.checkedIndexPaths.contains(indexPath)
        }
        return cell
    }
    
    
    
    
    // MARK: - Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! FriendCollectionViewCell
        if self.checkedIndexPaths.contains(indexPath) == false {
            self.checkedIndexPaths.insert(indexPath)
            cell.isChecked = false
            SuddenMainVC.isUserSelected = true
            
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! FriendCollectionViewCell
        if self.checkedIndexPaths.contains(indexPath) {
            self.checkedIndexPaths.remove(indexPath)
            cell.isChecked = true
            SuddenMainVC.isUserSelected = false
        }
        
        
    }
    
    
    // MARK: - Core Functions
    
    // present link button
    func presentLinkButton() {
        if SuddenMainVC.isUserSelected == true {
            matchButtonOutlet.isHidden = false
            view.bringSubview(toFront: matchButtonOutlet)
        }
        
    }
    
    // hide link button
    func hideLinkButton() {
        if SuddenMainVC.isUserSelected == false {
            matchButtonOutlet.isHidden = true
        }
        
    }
    
    // login and load friend's List
    
    func logingAndGetFriendList() {
        UserController.createAndLogin(self) { (success) in
            if success {
        UserController.getFriendsList({ (friends) in
            UserController.facebookFriendsArray = friends
            DispatchQueue.main.async {
                print("SUCCESSFULLY GETTING FACEBOOK FRIENDS")
                print(UserController.facebookFriendsArray)
                self.userCV.reloadData()

            }
        })
            } else {
                self.performSegue(withIdentifier: "", sender: nil)
            }
        
    }
    }
    
    
    
    
}

































