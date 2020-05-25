//
//  CategoriesViewController.swift
//  WhatToCook
//
//  Created by Mohsen Alijanpour on 25/05/2020.
//  Copyright © 2020 mohsen.dev. All rights reserved.
//

import UIKit

class CategoriesViewController: UIViewController, StoreBasedViewController {
    var store: StoreFactory.CategoriesStore
    
    var tableView = UITableView()
    
    init(store: StoreFactory.CategoriesStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(FoodTableCell.self, forCellReuseIdentifier: FoodTableCell.identifier)
        
        store.dispatch(action: .viewDidLoad)
        
        store.on { state in
            DispatchQueue.main.async {
                self.title = state.title
                self.tableView.reloadData()
            }
        }
    }
}

extension CategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.state.categories.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FoodTableCell.identifier, for: indexPath) as! FoodTableCell
        let category = store.state.categories.categories[indexPath.row]
        cell.set(title: category.strCategory, image: category.strCategoryThumb)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        store.dispatch(action: .selectCategory(indexPath.row))
    }
}
