//
//  ProfileImage.swift
//  Sudden
//
//  Created by youcef bouhafna on 11/14/16.
//  Copyright © 2016 Youcef. All rights reserved.
//

import UIKit

@IBDesignable

class ProfileImage: UIImageView {
    func imageStyle() {
//        self.layer.cornerRadius = self.frame.size.height / 2
//        self.layer.masksToBounds = false
//        self.clipsToBounds = true
        
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        imageStyle()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageStyle()
    }

    

}
