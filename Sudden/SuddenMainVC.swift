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
    static var usersList = [User]()
    static var malesUsersList = [User]()
    static var femalesUsersList = [User]()
    static var topFiltredList = [User]()
    static var bottomFiltreredList = [User]()
    // switch property to see if user is selected or not . default to false because users are not selected yet
    static var isUserOneSelected: Bool =  false
    static var isUserTwoSelected: Bool = false
    // array of selected items in the collectionView. if selected add to the array, if not => remove from the array
    var selectedUsersOneList: [String]?
    var selectedUsersTwoList: [String]?
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
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var userCV: UICollectionView!
    @IBOutlet weak var userCVTwo: UICollectionView!
    @IBOutlet weak var conversationsButtonOutlet: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        matchButtonOutlet.isHidden = true
        self.title = "Compatible"
        
        
        // GET USERS
        UserController.fetchAllUsers { (users) in
            DispatchQueue.main.async {
                SuddenMainVC.usersList = users!
                SuddenMainVC.malesUsersList = SuddenMainVC.usersList.filter({$0.gender == "male"})
                SuddenMainVC.femalesUsersList = SuddenMainVC.usersList.filter({$0.gender == "female"})
                
            }
        }
        
        logingAndGetFriendList()
        self.automaticallyAdjustsScrollViewInsets = false
        self.userCV?.delegate = self
        self.userCV?.dataSource = self
        
        // OVSERVERS
        NotificationCenter.default.addObserver(self, selector: #selector(presentLinkButton), name: NSNotification.Name(rawValue: "usersPicked"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideLinkButton), name: NSNotification.Name(rawValue: "usersUnpicked"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentSelectedUserOne), name: NSNotification.Name(rawValue: "userTwoUnpicked"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentSelectedUserTwo), name: NSNotification.Name(rawValue: "userTwoPicked"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeMainBlur), name: NSNotification.Name(rawValue: "MainBlurRemoved"), object: nil)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
    }
    
    // MARK: - REMOVE THE MAIN BLUR VIEW AFTER SELECTING BOTH USERS
    func removeMainBlur() {
        removeBlurViewTwo()
        removeBlurOneView()
        blurEffectViewOne.isHidden = true
        blurEffectViewTwo.isHidden = true
    }
    
    // MARK: - FILTERRED USERS LIST AFTER SELECTION
    func filteredUsersList(_ user: User, list: [User], isTop: Bool, completion: @escaping(_ success: Bool) -> Void) {
        var filtreredArray = [User]()
        var offLimitIdentifiers = [String]()
        UserController.fetchUserForIdentifier(user.identifier!) { (user) in
            if let user = user {
                offLimitIdentifiers = user.matchesIDs
                filtreredArray = list.filter({!offLimitIdentifiers.contains($0.identifier!)})
                if filtreredArray.count != list.count {
                    if isTop {
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
            } else {
                let theUser = SuddenMainVC.malesUsersList[indexPath.item]
                SuddenMainVC.selectedUserOne = theUser
                self.selectedUsersOneList?.append(theUser.profileImageURL!)
                SuddenMainVC.isUserOneSelected = true
            }
            
        } else if collectionView == self.userCVTwo {
            if SuddenMainVC.bottomFiltreredList.count > 0 {
                let theUser = SuddenMainVC.bottomFiltreredList[indexPath.item]
                SuddenMainVC.selectedUserTwo = theUser
                self.selectedUsersTwoList?.append(theUser.profileImageURL!)
                SuddenMainVC.isUserTwoSelected = true
            }
        } else {
            let theUser = SuddenMainVC.femalesUsersList[indexPath.item]
            SuddenMainVC.selectedUserTwo = theUser
            self.selectedUsersTwoList?.append(theUser.profileImageURL!)
            SuddenMainVC.isUserTwoSelected = true
        }
        
        let userPickedNotification = Notification(name: Notification.Name(rawValue: "userPicked"))
        NotificationCenter.default.post(userPickedNotification)
        let allUserPicked = Notification(name: Notification.Name(rawValue: "allUsersPicked"), object: nil, userInfo: nil)
        NotificationCenter.default.post(allUserPicked)
    }
    
    // MARK: - Core Functions
    
    // present link button
    func presentLinkButton() {
        if (SuddenMainVC.isUserTwoSelected == true && SuddenMainVC.isUserOneSelected == true) {
            matchButtonOutlet.isHidden = false
            view.bringSubview(toFront: matchButtonOutlet)
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
        self.userCV.reloadData()
        
    }
    
    // MARK: - Presenting Users after pickup
    func presentSelectedUserOne() {
        let blurEffect = UIBlurEffect(style: .light)
        let tap = UITapGestureRecognizer(target: self, action: #selector(removeBlurOneView))
        blurEffectViewOne = UIVisualEffectView(effect: blurEffect)
        blurEffectViewOne.frame = CGRect(x: 0, y: 121, width: view.frame.width, height: 177)
        blurEffectViewOne.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurEffectViewOne)
        
        // customize view when blur take effect
        // 1- CONTAINER VIEW
        let containerView: UIView = {
            let containerV = UIView()
            containerV.frame = CGRect(x: ((view.frame.width / 2) - 70), y: 13, width: 150, height: 150)
            
            containerV.backgroundColor = .yellow
            containerV.layer.cornerRadius = 8
            return containerV
        }()
        
        // 2- IMAGE VIEW OF THE USER 1
        let userOneImageView: UIImageView = {
            let userOneImage = UIImageView()
            userOneImage.layer.cornerRadius = 8
            userOneImage.frame = CGRect(x: 0, y: 0, width: 124, height: 113)
            userOneImage.contentMode = .scaleAspectFill
            return userOneImage
        }()
        containerView.addSubview(userOneImageView)
        
        
        //3- USER FIRST NAME LABEL
        let userOneFirstName: UILabel = {
            let username = UILabel()
            username.frame = CGRect(x: 0, y: 89, width: 124, height: 21)
            username.translatesAutoresizingMaskIntoConstraints = false
            return username
        }()
        containerView.addSubview(userOneFirstName)
        
        
        let indexPaths = userCV.indexPathsForSelectedItems
        if let selectedUserOneIndex = indexPaths?.first?.item {
            if SuddenMainVC.topFiltredList.count > 0 {
                let user = SuddenMainVC.topFiltredList[selectedUserOneIndex]
                userOneImageView.image = UIImage(contentsOfFile: user.profileImageURL!)
                userOneFirstName.text = user.firstName
                filteredUsersList(user, list: SuddenMainVC.femalesUsersList, isTop: false, completion: { (success) in
                    self.userCVTwo.reloadData()
                })
            } else {
                let user = SuddenMainVC.malesUsersList[selectedUserOneIndex]
                userOneImageView.image = UIImage(contentsOfFile: user.profileImageURL!)
                userOneFirstName.text = user.firstName
                filteredUsersList(user, list: SuddenMainVC.femalesUsersList, isTop: false, completion: { (success) in
                    self.userCVTwo.reloadData()
                })
                
            }
            
            // ADDING VIEWS TO BLUR EFFECT VIEW ONE
            blurEffectViewOne.addGestureRecognizer(tap)
            blurEffectViewOne.addSubview(containerView)
            blurEffectViewOne.addSubview(userOneImageView)
            blurEffectViewOne.addSubview(userOneFirstName)
            
        }
        
    }
    
    // REMOVE BLUR EFFECT FOR USER TWO
    func removeBlurViewTwo() {
        blurEffectViewTwo.removeFromSuperview()
        SuddenMainVC.isUserTwoSelected = false
        let userOneUnpickedNotification = Notification(name: Notification.Name(rawValue: "userTwoUnpicked"))
        NotificationCenter.default.post(userOneUnpickedNotification)
        SuddenMainVC.topFiltredList = []
        self.userCVTwo.reloadData()
        
    }
    // USER 2 SELECTED FROM SECOND COLLECTIONVIEW
    func presentSelectedUserTwo() {
        let blurEffectTwo = UIBlurEffect(style: .light)
        let tap = UIGestureRecognizer(target: self, action: #selector(removeBlurViewTwo))
        blurEffectViewTwo = UIVisualEffectView(effect: blurEffectTwo)
        blurEffectViewTwo.frame = CGRect(x: 0, y: 439, width: view.frame.width, height: 177)
        blurEffectViewTwo.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurEffectViewTwo)
        // customize view when blur take effect
        // 1- CONTAINER VIEW
        let containerViewTwo: UIView = {
            let containerV = UIView()
            containerV.frame = CGRect(x: ((view.frame.width / 2) - 70), y: 13, width: 150, height: 150)
            
            containerV.backgroundColor = .yellow
            containerV.layer.cornerRadius = 8
            return containerV
        }()
        
        // 2- IMAGE VIEW OF THE USER 1
        let userTwoImageView: UIImageView = {
            let userTwoImage = UIImageView()
            userTwoImage.layer.cornerRadius = 8
            userTwoImage.frame = CGRect(x: 0, y: 0, width: 124, height: 113)
            userTwoImage.contentMode = .scaleAspectFill
            return userTwoImage
        }()
        containerViewTwo.addSubview(userTwoImageView)
        
        
        //3- USER FIRST NAME LABEL
        let userTwoFirstName: UILabel = {
            let username = UILabel()
            username.frame = CGRect(x: 0, y: 89, width: 124, height: 21)
            return username
        }()
        containerViewTwo.addSubview(userTwoFirstName)
        
        let indexPaths = userCVTwo.indexPathsForSelectedItems
        if let selectedUserTwoIndex = indexPaths?.first?.item {
            if SuddenMainVC.bottomFiltreredList.count > 0 {
                let user = SuddenMainVC.bottomFiltreredList[selectedUserTwoIndex]
                userTwoImageView.image = UIImage(contentsOfFile: user.profileImageURL!)
                userTwoFirstName.text = user.firstName
                filteredUsersList(user, list: SuddenMainVC.malesUsersList, isTop: true, completion: { (success) in
                    self.userCV.reloadData()
                })
            } else {
                let user = SuddenMainVC.femalesUsersList[selectedUserTwoIndex]
                userTwoImageView.image = UIImage(contentsOfFile: user.profileImageURL!)
                userTwoFirstName.text = user.firstName
                filteredUsersList(user, list: SuddenMainVC.malesUsersList, isTop: true, completion: { (success) in
                    self.userCVTwo.reloadData()
                })
                
                
                
                // ADDING VIEWS TO BLUR EFFECT VIEW ONE
                blurEffectViewOne.addGestureRecognizer(tap)
                blurEffectViewOne.addSubview(containerViewTwo)
                blurEffectViewOne.addSubview(userTwoImageView)
                blurEffectViewOne.addSubview(userTwoFirstName)
                
            }
            
        }
        
    }
}


extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 0.5)
    }
}



























