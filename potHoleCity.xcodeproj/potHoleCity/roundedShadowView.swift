//
//  roundedShadowView.swift
//  potHoleCity
//
//  Created by Victoria George on 11/3/17.
//  Copyright © 2017 Victoria George. All rights reserved.
//

import UIKit

class roundedShadowView: UIView {

    override func awakeFromNib() {
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.75
      //  self.layer.cornerRadius = self.frame.height / 15
        
    }

}
