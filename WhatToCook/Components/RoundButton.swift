//
//  RoundButton.swift
//  WhatToCook
//
//  Created by Mohsen Alijanpour on 25/05/2020.
//  Copyright © 2020 mohsen.dev. All rights reserved.
//

import UIKit

class RoundButton: UIButton {
    init() {
        super.init(frame: .zero)
        
        backgroundColor = UIColor.systemGray6
        setTitleColor(UIColor.black, for: .normal)
        clipsToBounds = true
        layer.cornerRadius = 8
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
