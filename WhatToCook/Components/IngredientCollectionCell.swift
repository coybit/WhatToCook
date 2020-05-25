//
//  IngredientCollectionCell.swift
//  WhatToCook
//
//  Created by Mohsen Alijanpour on 26/05/2020.
//  Copyright © 2020 mohsen.dev. All rights reserved.
//

import UIKit
import SnapKit

class IngredientCollectionCell: UICollectionViewCell {
    static var identifier: String = "IngredientCollectionCell"
    
    private let stackView = UIStackView()
    private let iconLabel = UILabel()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(iconLabel)
        stackView.addArrangedSubview(titleLabel)
        
        stackView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        
        stackView.axis = .vertical
        stackView.alignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(icon: String, title: String, selected: Bool) {
        iconLabel.text = icon
        titleLabel.text = title
        
        backgroundColor = selected ? .yellow : .systemGray6
    }
}
