//
//  ChatThreadVC.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/16/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import UIKit

class ChatThreadVC: UIViewController {
    

    @IBOutlet weak var emojiButtonOutlet: UIButton!
    @IBOutlet weak var cameraButtonOutlet: UIButton!
    @IBOutlet weak var typeMessageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var typingTextContainerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
    }
    

    @IBAction func emojiButtonTapped(_ sender: UIButton) {
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
