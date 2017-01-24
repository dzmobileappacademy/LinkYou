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
import FBSDKCoreKit
import FBSDKLoginKit

class SuddenMainVC:  UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LinkAlertDelegate {
    // MARK: - Properties
    static var usersList = [User]()
    static var malesUsersList = [User]()
    static var femalesUsersList = [User]()
    static var topFiltredList = [User]()
    static var bottomFiltreredList = [User]()
    // switch property to see if user is selected or not . default to false because users are not selected yet
    static var isUserOneSelected: Bool =  false
    static var isUserTwoSelected: Bool = false
    // array of selected items in the collectionView. if selected add to the array, if not => remove from the array
    var selectedUsersOneList: [UIImage]?
    var selectedUsersTwoList: [UIImage]?
    static var selectedUserOne: User?
    static var selectedUserTwo: User?
    var blurEffectView: UIVisualEffectView!
    var blurEffectViewOne: UIVisualEffectView!
    var blurEffectViewTwo: UIVisualEffectView!
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
    let cellID = "cellIdentifier"
    //    MARK: - IBOutlets
    
    @IBOutlet weak var matchButtonOutlet: UIButton!
//    @IBOutlet weak var matchButtonOutlet: UIButton!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var userCV: UICollectionView!
    @IBOutlet weak var userCVTwo: UICollectionView!
    @IBOutlet weak var conversationsButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var backgroundBlurEffect: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        matchButtonOutlet.isHidden = true
        self.title = "Compatible"
        // alpha customization for fadein animation
        userCV.alpha = 0
        userCVTwo.alpha = 0
        // GET USERS
        UserController.fetchAllUsers { (users) in
            DispatchQueue.main.async {
                SuddenMainVC.usersList = users!
                SuddenMainVC.malesUsersList = SuddenMainVC.usersList.filter({$0.gender == "male"})
                SuddenMainVC.femalesUsersList = SuddenMainVC.usersList.filter({$0.gender == "female"})
            }
        }
        logingAndGetFriendList()
        //        presentLinkButton()
        //        hideLinkButton()
        if (SuddenMainVC.isUserTwoSelected == true && SuddenMainVC.isUserOneSelected == true) {
            matchButtonOutlet.isHidden = false
            view.bringSubview(toFront: matchButtonOutlet)
        }
        self.automaticallyAdjustsScrollViewInsets = false
        self.userCV?.delegate = self
        self.userCV?.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        afterLoginAnimation()

    }
    
    // first appearance animation aftr login
    func afterLoginAnimation() {
        UIView.animate(withDuration: 1.5) { 
            self.userCV.alpha = 1
            self.userCVTwo.alpha = 1
            self.view.addSubview(self.userCV)
            self.view.addSubview(self.userCVTwo)
        }
        
    }
    // MARK: - REMOVE THE MAIN BLUR VIEW AFTER SELECTING BOTH USERS
    func removeMainBlur() {
        removeBlurViewTwo()
        removeBlurOneView()
        blurEffectViewOne.isHidden = true
        blurEffectViewTwo.isHidden = true
    }
    
    // MARK: - FILTERRED USERS LIST AFTER SELECTION
    func filteredUsersList(_ user: User, list: [User], isBottom: Bool, completion: @escaping(_ success: Bool) -> Void) {
        var filtreredArray = [User]()
        var offLimitIdentifiers = [String]()
        UserController.fetchUserForIdentifier(user.identifier!) { (user) in
            if let user = user {
                offLimitIdentifiers = user.matchesIDs
                filtreredArray = list.filter({!offLimitIdentifiers.contains($0.identifier!)})
                if filtreredArray.count != list.count {
                    if isBottom {
                        SuddenMainVC.topFiltredList = filtreredArray
                        completion(true)
                    } else {
                        SuddenMainVC.bottomFiltreredList = filtreredArray
                        completion(true)
                    }
                } else {
                    completion(false)
                    print("failed to set filtred list ")
                }
            }
        }
        
        
    }
    
    // MARK: -  tap connect button, bring connectionAlert.XIB up front view
    @IBAction func connectButtonTapped(_ sender: UIButton) {
        if let connectAlert = UINib(nibName: "Connect", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? ConnectAlert {
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
        if collectionView == self.userCV {
            if SuddenMainVC.malesUsersList.count > 0 {
                return  SuddenMainVC.malesUsersList.count
            } else {
                return SuddenMainVC.topFiltredList.count
            }
        } else if collectionView == self.userCVTwo {
            if SuddenMainVC.femalesUsersList.count > 0 {
                return SuddenMainVC.femalesUsersList.count
            } else {
                return SuddenMainVC.bottomFiltreredList.count
            }
        } else {
            return 0
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! FriendCollectionViewCell
        if collectionView == self.userCV {
            if SuddenMainVC.malesUsersList.count > 0 {
                let user = SuddenMainVC.malesUsersList[indexPath.item]
                cell.friendName.text = user.firstName
                cell.layer.cornerRadius = 8
                cell.frame.size.height = 130
                cell.frame.size.width = 130
                if let profileImageURL = user.profileImageURL {
                    cell.friendImage.loadImageUsingCacheWithUrlString(profileImageURL)
                }
            } else {
                let user = SuddenMainVC.topFiltredList[indexPath.item]
                cell.friendName.text = user.firstName
                cell.layer.cornerRadius = 8
                cell.frame.size.height = 130
                cell.frame.size.width = 130
                if let profileImageURL = user.profileImageURL {
                    cell.friendImage.loadImageUsingCacheWithUrlString(profileImageURL)
                }
                
            }
        } else if collectionView == self.userCVTwo {
            
            if SuddenMainVC.femalesUsersList.count > 0 {
                let user = SuddenMainVC.femalesUsersList[indexPath.item]
                cell.friendName.text = user.firstName
                cell.layer.cornerRadius = 8
                cell.frame.size.height = 130
                cell.frame.size.width = 130
                if let profileImageURL = user.profileImageURL {
                    cell.friendImage.loadImageUsingCacheWithUrlString(profileImageURL)
                }
            } else {
                let user = SuddenMainVC.bottomFiltreredList[indexPath.item]
                cell.friendName.text = user.firstName
                cell.layer.cornerRadius = 8
                cell.frame.size.height = 130
                cell.frame.size.width = 130
                if let profileImageURL = user.profileImageURL {
                    cell.friendImage.loadImageUsingCacheWithUrlString(profileImageURL)
                }
                
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
        if collectionView == self.userCV {
            if SuddenMainVC.topFiltredList.count > 0 {
                let user = SuddenMainVC.topFiltredList[indexPath.item]
                SuddenMainVC.selectedUserOne = user
                self.selectedUsersOneList?.append(user.profileImageURL!)
                SuddenMainVC.isUserOneSelected = true
                presentSelectedUserOne()
            } else {
                let theUser = SuddenMainVC.malesUsersList[indexPath.item]
                SuddenMainVC.selectedUserOne = theUser
                self.selectedUsersOneList?.append(theUser.profileImageURL!)
                SuddenMainVC.isUserOneSelected = true
                presentSelectedUserOne()
                
            }
            
        } else if collectionView == self.userCVTwo {
            if SuddenMainVC.bottomFiltreredList.count > 0 {
                let theUser = SuddenMainVC.bottomFiltreredList[indexPath.item]
                SuddenMainVC.selectedUserTwo = theUser
                self.selectedUsersTwoList?.append(theUser.profileImageURL!)
                SuddenMainVC.isUserTwoSelected = true
                presentSelectedUserTwo()
                
                
            } else {
                let theUser = SuddenMainVC.femalesUsersList[indexPath.item]
                SuddenMainVC.selectedUserTwo = theUser
                self.selectedUsersTwoList?.append(theUser.profileImageURL!)
                SuddenMainVC.isUserTwoSelected = true
                presentSelectedUserTwo()
                
            }
            
            let userPickedNotification = Notification(name: Notification.Name(rawValue: "userPicked"))
            NotificationCenter.default.post(userPickedNotification)
            let allUserPicked = Notification(name: Notification.Name(rawValue: "allUsersPicked"), object: nil, userInfo: nil)
            NotificationCenter.default.post(allUserPicked)
        }
    }
    
    // MARK: - Core Functions
    
    // present link button
    func presentLinkButton() {
        if (SuddenMainVC.isUserTwoSelected == true && SuddenMainVC.isUserOneSelected == true) {
            matchButtonOutlet.isHidden = false
            view.bringSubview(toFront: matchButtonOutlet)
            backgroundBlurEffect.addSubview(matchButtonOutlet)
        }
        
    }
    
    // hide link button
    func hideLinkButton() {
        if (SuddenMainVC.isUserOneSelected == true && SuddenMainVC.isUserTwoSelected == false ) || (SuddenMainVC.isUserOneSelected == false && SuddenMainVC.isUserTwoSelected == true) || (SuddenMainVC.isUserOneSelected == false && (SuddenMainVC.isUserTwoSelected == false)){
            self.matchButtonOutlet.isHidden = true
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
    
    
    // REMOVE BLUR VIEW ONE
    func removeBlurOneView() {
        blurEffectViewOne.removeFromSuperview()
        SuddenMainVC.isUserOneSelected = false
        let userOneUnpickedNotification = Notification(name: Notification.Name(rawValue: "userOneUnpicked"))
        NotificationCenter.default.post(userOneUnpickedNotification)
        SuddenMainVC.bottomFiltreredList = []
        self.userCVTwo.reloadData()
        
    }
    // REMOVE BLUR EFFECT FOR USER TWO
    func removeBlurViewTwo() {
        blurEffectViewTwo.removeFromSuperview()
        SuddenMainVC.isUserTwoSelected = false
        let userOneUnpickedNotification = Notification(name: Notification.Name(rawValue: "userTwoUnpicked"))
        NotificationCenter.default.post(userOneUnpickedNotification)
        SuddenMainVC.topFiltredList = []
        self.userCV.reloadData()
        
    }
    
    // MARK: - Presenting Users after pickup
    func presentSelectedUserOne() {
        let blurEffect = UIBlurEffect(style: .regular)
        let tap = UITapGestureRecognizer(target: self, action: #selector(removeBlurOneView))
        blurEffectViewOne = UIVisualEffectView(effect: blurEffect)
        blurEffectViewOne.frame = CGRect(x: 0, y: 121, width: view.frame.width, height: 177)
        blurEffectViewOne.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurEffectViewOne)
        
        // customize view when blur take effect
        // 1- CONTAINER VIEW
        let containerView: UIView = {
            let containerV = UIView()
            containerV.frame = CGRect(x: ((view.center.x / 2) - 85), y: ((view.center.y / 2) - 182), width: ((userCV.frame.width) - 20), height: userCV.frame.height)
            
            containerV.backgroundColor = .yellow
            containerV.layer.cornerRadius = 8
            return containerV
        }()
        
        // 2- IMAGE VIEW OF THE USER 1
        let userOneImageView: UIImageView = {
            let userOneImage = UIImageView()
            userOneImage.frame = CGRect(x: ((view.center.x / 2) + 40), y: ((view.center.y) - 360), width: 120, height: 120)
            
            return userOneImage
        }()
        
        //3- USER FIRST NAME LABEL
        let userOneFirstName: UILabel = {
            let usernameLabel = UILabel()
            usernameLabel.frame = CGRect(x: ((view.frame.width / 2) - 100), y: 150, width: 200, height: 21)
            usernameLabel.textAlignment = .center
            
            return usernameLabel
        }()
        
        
        let indexPaths = userCV.indexPathsForSelectedItems
        if let selectedUserOneIndex = indexPaths?.first?.item {
            if SuddenMainVC.topFiltredList.count > 0 {
                let user = SuddenMainVC.topFiltredList[selectedUserOneIndex]
                userOneImageView.image = UIImage(named: "youcef")
                userOneFirstName.text = user.firstName
                filteredUsersList(user, list: SuddenMainVC.femalesUsersList, isBottom: true, completion: { (success) in
                    self.userCVTwo.reloadData()
                })
            } else {
                let user = SuddenMainVC.malesUsersList[selectedUserOneIndex]
                let url = NSURL(string: user.profileImageURL!)
                let data = NSData(contentsOf: url as! URL)
                userOneImageView.image = UIImage(data: data as! Data)
                userOneFirstName.text = user.firstName
                filteredUsersList(user, list: SuddenMainVC.femalesUsersList, isBottom: true, completion: { (success) in
                    self.userCVTwo.reloadData()
                })
            }
            
        }
        // ADDING VIEWS TO BLUR EFFECT VIEW ONE
        blurEffectViewOne.addGestureRecognizer(tap)
        blurEffectViewOne.addSubview(userOneImageView)
        blurEffectViewOne.addSubview(userOneFirstName)
    }
    
    // USER 2 SELECTED FROM SECOND COLLECTIONVIEW
    func presentSelectedUserTwo() {
        let blurEffectTwo = UIBlurEffect(style: .light)
        let tapTwo = UITapGestureRecognizer(target: self, action: #selector(removeBlurViewTwo))
        blurEffectViewTwo = UIVisualEffectView(effect: blurEffectTwo)
        blurEffectViewTwo.frame = CGRect(x: 0, y: 439, width: view.frame.width, height: 177)
        blurEffectViewTwo.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurEffectViewTwo)
        // customize view when blur take effect
        // 1- CONTAINER VIEW 2
        let containerViewTwo: UIView = {
            let containerV = UIView()
            containerV.frame = CGRect(x: (userCVTwo.center.x), y: view.center.y , width: view.frame.width, height: userCVTwo.frame.height)
            containerV.clipsToBounds = true
            
            containerV.backgroundColor = .yellow
            containerV.layer.cornerRadius = 8
            return containerV
        }()
        
        // 2- IMAGE VIEW OF THE USER 2
        let userTwoImageView: UIImageView = {
            let userTwoImage = UIImageView()
            userTwoImage.layer.cornerRadius = 8
            userTwoImage.frame = CGRect(x: ((view.center.y / 2) - 40), y: 10, width: 130, height: 130)
            userTwoImage.contentMode = .scaleAspectFill
            return userTwoImage
        }()
        
        
        //3- USER FIRST NAME LABEL 2
        let userTwoFirstName: UILabel = {
            let username = UILabel()
            username.frame = CGRect(x: (view.center.x / 2), y: 150, width: 200, height: 21)
            username.textAlignment = .center
            return username
        }()
        
        let indexPaths = userCVTwo.indexPathsForSelectedItems
        if let selectedUserTwoIndex = indexPaths?.first?.item {
            if SuddenMainVC.bottomFiltreredList.count > 0 {
                let user = SuddenMainVC.bottomFiltreredList[selectedUserTwoIndex]
                userTwoImageView.image = UIImage(contentsOfFile: user.profileImageURL!)
                userTwoFirstName.text = user.firstName
                filteredUsersList(user, list: SuddenMainVC.malesUsersList, isBottom: false, completion: { (success) in
                    self.userCV.reloadData()
                })
            } else {
                let user = SuddenMainVC.femalesUsersList[selectedUserTwoIndex]
                userTwoImageView.image = UIImage(contentsOfFile: user.profileImageURL!)
                userTwoFirstName.text = user.firstName
                filteredUsersList(user, list: SuddenMainVC.malesUsersList, isBottom: false, completion: { (success) in
                    self.userCV.reloadData()
                })
                
            }
            
        }
        // ADDING VIEWS TO BLUR EFFECT VIEW ONE
        blurEffectViewTwo.addGestureRecognizer(tapTwo)
        //        blurEffectViewTwo.addSubview(containerViewTwo)
        blurEffectViewTwo.addSubview(userTwoImageView)
        blurEffectViewTwo.addSubview(userTwoFirstName)
        
    }
    
}
extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 0.5)
    }
}



























