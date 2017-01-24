//
//  PrivacyPolicyVC.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/14/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import UIKit

class PrivacyPolicyVC: UIViewController {
    
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    @IBOutlet weak var backgroundImageParis: UIImageView!
    @IBOutlet weak var privacyPolicyTextView: UITextView!
    @IBOutlet weak var doneButtonOutlet: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animationFadeIn()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 1.0) {
            self.privacyPolicyTextView.alpha = 1
            self.doneButtonOutlet.alpha = 1
        }
    }
    
    func animationFadeIn() {
        privacyPolicyTextView.layer.cornerRadius = 10
        privacyPolicyTextView.alpha = 0
        doneButtonOutlet.alpha = 0
        view.addSubview(privacyPolicyTextView)
        view.addSubview(doneButtonOutlet)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
