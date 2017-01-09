//
//  SuddenMainVC.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/14/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase

class SuddenMainVC:  UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LinkAlertDelegate {
    
    // MARK: - Properties
    var usersList = [User]()
    static var isUserSelected: Bool =  false // switch property to see if user is selected or not . default to false because users are not selected yet
    var selectedUsersList: [String]? // array of selected items in the collectionView. if selected add to the array, if not => remove from the array
    static var selectedUser: User?
    var blurEffectView: UIVisualEffectView!
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
    let cellID = "cellIdentifier"
    
    
    //    MARK: - IBOutlets
    @IBOutlet weak var matchButtonOutlet: UIButton!
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var userCV: UICollectionView!
    @IBOutlet weak var userCVTwo: UICollectionView!
    
    //    @IBOutlet weak var friendTableView: UITableView!
    @IBOutlet weak var conversationsButtonOutlet: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        matchButtonOutlet.isHidden = true
        self.title = "Compatible"
        presentSelectedUser()
        
        // GET USERS
        UserController.fetchAllUsers { (users) in
            DispatchQueue.main.async {
                self.usersList = users!
            }
        }
        
        logingAndGetFriendList()
        //        presentLinkButton()
        //        hideLinkButton()
        self.automaticallyAdjustsScrollViewInsets = false
        self.userCV?.delegate = self
        self.userCV?.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    // MARK: -  tap connect button, bring connectionAlert.XIB up front view
    @IBAction func connectButtonTapped(_ sender: UIButton) {
        if let connectAlert = UINib(nibName: "ConnectAlert", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? ConnectAlert {
            connectAlert.connectionDelegate = self
            let blurEffect = UIBlurEffect(style: .light)
            blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            self.view.addSubview(blurEffectView)
            connectAlert.frame = CGRect(x: (UIScreen.main.bounds.width / 2) - ((connectAlert.frame.width) / 2), y: (self.view.frame.height / 2) - ((connectAlert.frame.height) / 2), width: (connectAlert.frame.width), height: (connectAlert.frame.height))
            connectAlert.layer.cornerRadius = 12
            self.view.addSubview(connectAlert)
        }
    }
    
    // MARK: - IBAction for COMPATIBLE BUTTON
    
    @IBAction func compatibleButtonTapped(_ sender: Any) {
    }
    // tap conversationbutton, go to "conversationsList,matches, waiting list" table view
    @IBAction func conversationsButtonTapped(_ sender: UIBarButtonItem) {
        print("traveling to conversations list ")
    }
    
    // MARK: - Collection View DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var userCount: Int = 0
        if collectionView == self.userCV {
         userCount = usersList.count
        } else if collectionView == self.userCVTwo {
            userCount = usersList.count
        }
        return userCount
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! FriendCollectionViewCell
        if collectionView == self.userCV {
            let user = self.usersList[indexPath.item]
            cell.friendName.text = user.firstName
            cell.layer.cornerRadius = 8
            cell.frame.size.height = 130
            cell.frame.size.width = 130
            if let profileImageURL = user.profileImageURL {
                cell.friendImage.loadImageUsingCacheWithUrlString(profileImageURL)
                
            }
            
        } else if collectionView == self.userCVTwo {
            let user = self.usersList[indexPath.item]
            cell.friendName.text = user.firstName
            cell.layer.cornerRadius = 8
            cell.frame.size.height = 130
            cell.frame.size.width = 130
            if let profileImageURL = user.profileImageURL {
                cell.friendImage.loadImageUsingCacheWithUrlString(profileImageURL)
                
            }
        }
        return cell
    }
    
    
    
    // MARK:-  UICollectionViewFlowLayoutDelegate
    
    // function responsible for telling the layout the size of a given cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem  , height: widthPerItem)
    }
    // returns the spacing between the cells, headers and footers
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    // this method controls the spacing between each line in the layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    // MARK: - Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if FriendController.filtredListOfUsers.count > 0 {
            let user = FriendController.filtredListOfUsers[indexPath.item]
            SuddenMainVC.selectedUser = user
            self.selectedUsersList?.append(user.profileImageURL!)
            SuddenMainVC.isUserSelected = true
            
        }
        let userPickedNotification = Notification(name: Notification.Name(rawValue: "userPicked"))
        NotificationCenter.default.post(userPickedNotification)
        let allUserPicked = Notification(name: Notification.Name(rawValue: "allUsersPicked"), object: nil, userInfo: nil)
        NotificationCenter.default.post(allUserPicked)
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
    
    // MARK: - login and load friend's List
    func logingAndGetFriendList() {
        UserController.createAndLogin(self) { (success) in
            if success {
                for user in UserController.usersArray {
                    ImageLoader.sharedLoader.imageForUrl(urlString: user.profileImageURL!  , completionHandler: { (image, url) in
                        if let userImage = image {
                            user.profileImage = userImage
                            print("\(user.profileImageURL)")
                            print(user.firstName)
                        }
                    })
                }
                DispatchQueue.main.async {
                    self.userCV.reloadData()
                    self.userCVTwo.reloadData()
                }
                
            } else {
                self.performSegue(withIdentifier: "toLogin", sender: nil)
            }
        }
        
    }
    
    // MARK: - Delegate required method
    func removeBlurEffect(_ sender: ConnectAlert) {
        self.blurEffectView.removeFromSuperview()
    }
    
    
    // remove blur view
    func removeBlurView() {
        
    }
    // MARK: - Presenting Users after pickup
    func presentSelectedUser() {
        let blurEffect = UIBlurEffect(style: .light)
        let tap = UITapGestureRecognizer(target: self, action: #selector(removeBlurView))
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = CGRect(x: 0, y: 121, width: view.frame.width, height: 177)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurEffectView)
        
//        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        // blur effect view constraints
//        blurEffectView.centerXAnchor.constraint(equalTo: userCV.centerXAnchor).isActive = true
//        blurEffectView.centerYAnchor.constraint(equalTo: userCV.centerYAnchor).isActive = true
//        blurEffectView.widthAnchor.constraint(equalTo: userCV.widthAnchor).isActive = true
//        blurEffectView.heightAnchor.constraint(equalTo: userCV.heightAnchor).isActive = true
        
        // customize view when blur take effect
        // 1- container view
        let containerView: UIView = {
            let containerV = UIView()
            containerV.frame = CGRect(x: ((view.frame.width / 2) - 70), y: 13, width: 150, height: 150)

            containerV.backgroundColor = .yellow
//            containerV.translatesAutoresizingMaskIntoConstraints = false
            containerV.layer.cornerRadius = 3
            return containerV
        }()
        // container view constraints
//        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: ).isActive = true
//        containerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
//        containerView.heightAnchor.constraint(equalTo: userCV.heightAnchor).isActive = true
//        containerView.topAnchor.constraint(equalTo: userCV.topAnchor).isActive = true
//        containerView.bottomAnchor.constraint(equalTo: userCV.bottomAnchor).isActive = true
        
        
        // 2- image view of the user
        let userImageView: UIImageView = {
            let userImage = UIImageView()
            userImage.frame = CGRect(x: 0, y: 0, width: 124, height: 113)
//            userImage.translatesAutoresizingMaskIntoConstraints = false
            userImage.contentMode = .scaleAspectFill
            return userImage
        }()
//        containerView.addSubview(userImageView)
        
        // userImageView constraints
//        userImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
//        userImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//        userImageView.widthAnchor.constraint(equalToConstant: 125).isActive = true
//        userImageView.heightAnchor.constraint(equalToConstant: 125).isActive = true
        
        //3- user first name label
        let userFirstName: UILabel = {
            let username = UILabel()
            username.frame = CGRect(x: 0, y: 89, width: 124, height: 21)
            username.translatesAutoresizingMaskIntoConstraints = false
            return username
        }()
//        containerView.addSubview(userFirstName)
        
        // user name label constraints
//        userFirstName.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 2).isActive = true
//        userFirstName.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 2).isActive = true
//        userFirstName.widthAnchor.constraint(equalTo: userImageView.widthAnchor).isActive = true
//        userFirstName.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        
        blurEffectView.addGestureRecognizer(tap)
        blurEffectView.addSubview(containerView)
        blurEffectView.addSubview(userImageView)
        blurEffectView.addSubview(userFirstName)
        
        
        
        
        let indexPaths = userCV.indexPathsForSelectedItems
        if let selectedUser = indexPaths?.first?.item {
            if FriendController.filtredListOfUsers.count > 0 {
                let user = FriendController.filtredListOfUsers[selectedUser]
                
            }
        }
        
    }
    
    
}


extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 0.5)
    }
}



























