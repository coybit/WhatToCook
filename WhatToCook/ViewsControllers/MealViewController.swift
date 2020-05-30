//
//  MealViewController.swift
//  WhatToCook
//
//  Created by Mohsen Alijanpour on 25/05/2020.
//  Copyright © 2020 mohsen.dev. All rights reserved.
//

import UIKit
import SnapKit

class MealViewController: UIViewController, StoreBasedViewController {
    var store: StoreFactory.MealStore
    
    let labelTitle = UILabel()
    let labelInstruction = UILabel()
    let imageViewMeal = UIImageView()
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    let buttonFavourite = RoundButton()
    let buttonOpenVideo = RoundButton()
    var imageHeightConstraint: NSLayoutConstraint!
    
    init(store: StoreFactory.MealStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(imageViewMeal)
        stackView.addArrangedSubview(labelTitle)
        stackView.addArrangedSubview(buttonFavourite)
        stackView.addArrangedSubview(buttonOpenVideo)
        stackView.addArrangedSubview(labelInstruction)
        
        scrollView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview().inset(16)
            maker.width.equalTo(view.snp.width).inset(16)
        }
        
        imageViewMeal.snp.makeConstraints { maker in
            maker.height.equalTo(imageViewMeal.snp.width)
        }
        
        view.backgroundColor = .systemGray6
        
        labelTitle.font = .preferredFont(forTextStyle: .title1)
        
        labelInstruction.numberOfLines = 0
        labelInstruction.font = .preferredFont(forTextStyle: .body)
        
        stackView.axis = .vertical
        stackView.spacing = 16
        
        imageViewMeal.contentMode = .scaleAspectFill
        imageViewMeal.clipsToBounds = true
        
        buttonFavourite.isHidden = true
        buttonFavourite.addTarget(self, action: #selector(onSaveTap), for: .touchUpInside)
        
        buttonOpenVideo.isHidden = true
        buttonOpenVideo.addTarget(self, action: #selector(onOpenVideoTap), for: .touchUpInside)
        buttonOpenVideo.setTitle("Watch Video 📹", for: .normal)
        
        store.on { state in
            DispatchQueue.main.async {
                self.labelTitle.text = state.title
                self.labelInstruction.text = state.instruction
                self.imageViewMeal.image = state.image
                self.buttonFavourite.isHidden = false
                self.buttonFavourite.setTitle(state.saved ? "Unsave 💔" : "Save ❤️", for: .normal)
                self.buttonOpenVideo.isHidden = state.meal.strYoutube == nil
            }
        }
        
        store.dispatch(action: .viewDidLoad)
    }
    
    @objc
    func onSaveTap(_ sender: Any) {
        store.dispatch(action: .saveDidTap)
    }
    
    @objc
    func onOpenVideoTap(_ sender: Any) {
        store.dispatch(action: .openVideoTap)
    }
}
