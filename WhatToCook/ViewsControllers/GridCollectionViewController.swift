//
//  GridCollectionViewController.swift
//  WhatToCook
//
//  Created by Mohsen Alijanpour on 26/05/2020.
//  Copyright © 2020 mohsen.dev. All rights reserved.
//

import UIKit
import SnapKit

private let reuseIdentifier = "Cell"

class GridCollectionViewController: UIViewController, UICollectionViewDelegateFlowLayout,  StoreBasedViewController {

    var store: StoreFactory.IngredientsStore
    private let layout = UICollectionViewFlowLayout()
    private let collectionView: UICollectionView!
    private let searchBar: UISearchBar!
    
    init(store: StoreFactory.IngredientsStore) {
        self.store = store
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.searchBar = UISearchBar(frame: .zero)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        view.addSubview(searchBar)
        
        searchBar.snp.makeConstraints { maker in
            maker.leading.equalToSuperview()
            maker.top.equalTo(view.snp.topMargin)
            maker.trailing.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { maker in
            maker.leading.equalToSuperview()
            maker.top.equalTo(searchBar.snp.bottom)
            maker.bottom.equalToSuperview()
            maker.trailing.equalToSuperview()
        }
        
        self.view.backgroundColor = .systemGray6
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemGray6
        collectionView!.register(IngredientCollectionCell.self, forCellWithReuseIdentifier: IngredientCollectionCell.identifier)
        
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(onSearchTap))

        searchBar.barStyle = .default
        searchBar.delegate = self
        
        store.on { state in
            DispatchQueue.main.async {
                self.title = state.title
                self.collectionView.reloadData()
            }
        }
        
        store.dispatch(action: .viewDidLoad)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.navigationItem.searchController?.searchBar.sizeToFit()
    }
}

extension GridCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return store.state.displayingIngredients.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IngredientCollectionCell.identifier, for: indexPath) as! IngredientCollectionCell
    
        let ingredient = store.state.displayingIngredients[indexPath.row]
        cell.set(icon: ingredient.icon, title: ingredient.name, selected: ingredient.selected)
    
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        store.dispatch(action: .ingredientDidSelect(indexPath.row))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let cellSquareSize: CGFloat = screenWidth / 4.0 - 2 * 8
        return CGSize(width: cellSquareSize, height: cellSquareSize);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8.0, right: 8.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    @objc
    func onSearchTap(_ sender: Any) {
        store.dispatch(action: .searchDidTap)
    }
}

extension GridCollectionViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        store.dispatch(action: .filterDidChange(searchText))
    }
}
