//
//  FriendCollectionViewCell.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/14/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import UIKit

class FriendCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var friendImage: UIImageView!
    
    func updateWith(_ image: UIImage, username: String) {
        friendImage.image = image
        friendName.text = username
    }
    var isChecked: Bool = false {
        didSet {
            if isChecked {
                self.checkMark.image = UIImage(named: "checkMark.png")
            } else {
                self.checkMark.isHidden = true
            }
        }
    }
    
    
}
