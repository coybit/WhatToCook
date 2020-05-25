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

class GridCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout,  StoreBasedViewController {

    var store: StoreFactory.IngredientsStore
    private let layout = UICollectionViewFlowLayout()
    
    init(store: StoreFactory.IngredientsStore) {
        self.store = store
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        
        collectionView.backgroundColor = .white
        collectionView!.register(IngredientCollectionCell.self, forCellWithReuseIdentifier: IngredientCollectionCell.identifier)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(onSearchTap))
        
        store.on { state in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        store.dispatch(action: .viewDidLoad)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return store.state.ingredients.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IngredientCollectionCell.identifier, for: indexPath) as! IngredientCollectionCell
    
        let ingredient = store.state.ingredients[indexPath.row]
        cell.set(icon: ingredient.icon, title: ingredient.name, selected: ingredient.selected)
    
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
