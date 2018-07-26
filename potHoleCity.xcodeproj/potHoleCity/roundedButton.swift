//
//  roundedButton.swift
//  potHoleCity
//
//  Created by Victoria George on 11/3/17.
//  Copyright © 2017 Victoria George. All rights reserved.
//

import UIKit

class RoundedShadowButton: UIButton {
    
    override func awakeFromNib() {
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.80
       // self.layer.cornerRadius = self.frame.height / 5
        
    }
    
}
