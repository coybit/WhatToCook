//
//  MenuViewController.swift
//  WhatToCook
//
//  Created by Mohsen Alijanpour on 25/05/2020.
//  Copyright © 2020 mohsen.dev. All rights reserved.
//

import UIKit
import SnapKit

class MenuViewController: UIViewController, StoreBasedViewController {

    var store: StoreFactory.MenuStore
    
    private let stackView = UIStackView()
    private let buttonSearch = RoundButton()
    private let buttonExplorer = RoundButton()
    private let buttonSavedList = RoundButton()
    private let buttonRandomMeal = RoundButton()
    
    init(store: StoreFactory.MenuStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(buttonSearch)
        stackView.addArrangedSubview(buttonExplorer)
        stackView.addArrangedSubview(buttonSavedList)
        stackView.addArrangedSubview(buttonRandomMeal)
        
        stackView.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
            maker.width.equalTo(200)
            maker.height.equalTo(300)
        }
        
        view.backgroundColor = .white
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        
        buttonSearch.setTitle("🔍 Search", for: .normal)
        buttonExplorer.setTitle("🧭 Explorer", for: .normal)
        buttonSavedList.setTitle("❤️ Saved", for: .normal)
        buttonRandomMeal.setTitle("🎁 Random", for: .normal)
       
        buttonSearch.addTarget(self, action: #selector(onSearch), for: .touchUpInside)
        buttonExplorer.addTarget(self, action: #selector(onExplorer), for: .touchUpInside)
        buttonSavedList.addTarget(self, action: #selector(onSaved), for: .touchUpInside)
        buttonRandomMeal.addTarget(self, action: #selector(onRandom), for: .touchUpInside)
    }
    
    @objc
    func onSearch(_ sender: Any) {
        store.dispatch(action: .searchDidSelect)
    }
    
    @objc
    func onExplorer(_ sender: Any) {
        store.dispatch(action: .exploreDidSelect)
    }
    
    @objc
    func onSaved(_ sender: Any) {
        store.dispatch(action: .savedMealsDidSelect)
    }
    
    @objc
    func onRandom(_ sender: Any) {
        store.dispatch(action: .randomMealDidSelect)
    }
}
