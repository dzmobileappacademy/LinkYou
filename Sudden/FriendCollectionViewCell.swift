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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        friendImage.layer.cornerRadius = friendImage.frame.height / 2

    }
    
    func imageRadius() {
//        friendImage.layer.cornerRadius = friendName.frame.height / 2
        friendImage.clipsToBounds = true
        friendImage.layer.masksToBounds = true
        
    }
    func cellCustomization(cell: FriendCollectionViewCell) {
//        cell.layer.cornerRadius = cell.lay
//        cell.frame.size.height = 170
//        cell.frame.size.width = 150
    }
}

