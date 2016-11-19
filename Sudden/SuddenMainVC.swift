//
//  SuddenMainVC.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/14/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import UIKit

class SuddenMainVC: UIViewController {
    
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var admobBannerView: UIView!
    
    @IBOutlet weak var friendOneCV: UICollectionView!
    
    @IBOutlet weak var friendTwoCV: UICollectionView!
    
    @IBOutlet weak var conversationsButtonOutlet: UIBarButtonItem!
    
    @IBOutlet weak var connectButtonOutlet: UIButton!
    
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func connectButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func conversationsButtonTapped(_ sender: UIBarButtonItem) {
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
