//
//  LoginVC.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/14/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth


class LoginVC: UIViewController {
    
    @IBOutlet weak var suddenLogoImage: UIImageView!
    
    @IBOutlet weak var welcomeTextLabel: UILabel!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }


    @IBAction func facebookLoginButtonTapped(_ sender: UIButton) {
        UserController.createAndLogin(self) { (success) in
            if success {
                self.performSegue(withIdentifier: "toMainStoryBoard", sender: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            
        
    }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
