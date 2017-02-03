//
//  FriendCollectionViewCell.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/14/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import UIKit

class FriendCollectionViewCell: UICollectionViewCell {
    
    //    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var friendImage: UIImageView!
    
    func imageRadius() {
        friendImage.layer.cornerRadius = 8
        friendImage.frame.size.height = 80
    }
    func cellCustomization(cell: FriendCollectionViewCell) {
        cell.layer.cornerRadius = 8
        cell.frame.size.height = 130
        cell.frame.size.width = 130
    }
    var isChecked: Bool = false {
        didSet {
            if isChecked {
                friendImage.layer.borderColor = UIColor.red.cgColor
                print("cell selected")
            }
            
        }
    }
    
    
}

