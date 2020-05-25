//
//  MealsViewController.swift
//  WhatToCook
//
//  Created by Mohsen Alijanpour on 25/05/2020.
//  Copyright © 2020 mohsen.dev. All rights reserved.
//

import UIKit

class MealsViewController: UIViewController {
    var store: StoreFactory.MealsStore
    
    var tableView = UITableView()
    
    init(store: StoreFactory.MealsStore) {
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
        
        store.on { state in
            DispatchQueue.main.async {
                self.title = state.title
                self.tableView.reloadData()
            }
        }
        
        store.dispatch(action: .viewDidLoad)
    }
}

extension MealsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch store.state.content {
        case .idle:
            return 0
        case .loading, .empty, .error:
            return 1
        case .data(let meals):
            return meals.meals.count
        case .loadingMore(let meals):
            return meals.meals.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FoodTableCell.identifier, for: indexPath) as! FoodTableCell
        
        switch store.state.content {
        case .idle:
            preconditionFailure("In idle state, number of cell must be zero!")
        case .loading:
            cell.set(title: "Loading ...", image: "")
        case .empty:
            cell.set(title: "The list is empty", image: "")
        case .error:
            cell.set(title: "Error. Tap to try again!", image: "")
        case .data(let meals):
            let meal = meals.meals[indexPath.row]
            cell.set(title: meal.strMeal, image: meal.strMealThumb)
        case .loadingMore(let meals):
            let meal = meals.meals[indexPath.row]
            cell.set(title: meal.strMeal, image: meal.strMealThumb)
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch store.state.content {
        case .error:
            store.dispatch(action: .tryAgain)
        case .data(let meals):
            store.dispatch(action: .mealDidSelect(meals.meals[indexPath.row]))
        default:
            break
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.size.height {
            store.dispatch(action: .reachEndOfList)
        }
    }
}
