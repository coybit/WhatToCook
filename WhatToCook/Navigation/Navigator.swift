//
//  Navigator.swift
//  WhatToCook
//
//  Created by Mohsen Alijanpour on 25/05/2020.
//  Copyright © 2020 mohsen.dev. All rights reserved.
//

import UIKit

protocol Navigator {
    associatedtype NavigationDestination
    
    var presentingViewController: UIViewController? { get }
    
    func navigate(to destination: NavigationDestination)
    func showError(_ error: Error)
}

extension Navigator {
    func showError(_ error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel) { alert in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        
        presentingViewController?.present(alertController, animated: true, completion: nil)
    }
}

class MenuNavigator: Navigator {
    private let navController: UINavigationController
    
    var presentingViewController: UIViewController? {
        return navController.topViewController
    }
    
    var categoryNavigator: CategoriesNavigator {
        return CategoriesNavigator(navigationController: navController)
    }
    
    var searchNavigator: SearchNavigator {
        return SearchNavigator(navigationController: navController)
    }
    
    init(navigationController: UINavigationController) {
        self.navController = navigationController
    }
    
    func navigate(to destination: NavigationDestination) {
        switch destination {
        case .explore(let store):
            let mealsVC = CategoriesViewController(store: store)
            navController.pushViewController(mealsVC, animated: true)
        case .random(let store):
            let randomMealVC = MealViewController(store: store)
            navController.pushViewController(randomMealVC, animated: true)
        case .savedMeals(let store):
            let savedMealsVC = MealsViewController(store: store)
            navController.pushViewController(savedMealsVC, animated: true)
        case .search(let store):
            let searchVC = GridCollectionViewController(store: store)
            navController.pushViewController(searchVC, animated: true)
        }
    }
    
    enum NavigationDestination {
        case explore(StoreFactory.CategoriesStore)
        case random(StoreFactory.MealStore)
        case savedMeals(StoreFactory.MealsStore)
        case search(StoreFactory.IngredientsStore)
    }
}

class CategoriesNavigator: Navigator {
    private let navController: UINavigationController
    
    var presentingViewController: UIViewController? {
        return navController.topViewController
    }
    
    var mealsNavigator: MealsNavigator {
        return ExploreMealsNavigator(navigationController: navController)
    }
    
    init(navigationController: UINavigationController) {
        self.navController = navigationController
    }
    
    func navigate(to destination: NavigationDestination) {
        switch destination {
        case .mealsList(let store):
            let mealsVC = MealsViewController(store: store)
            navController.pushViewController(mealsVC, animated: true)
        }
    }
    
    enum NavigationDestination {
        case mealsList(StoreFactory.MealsStore)
    }
}

class MealsNavigator: Navigator {
    fileprivate let navController: UINavigationController
    
    var presentingViewController: UIViewController? {
        return navController.topViewController
    }
    
    var mealNavigator: MealNavigator {
        return MealNavigator(navigationController: navController)
    }
    
    init(navigationController: UINavigationController) {
        self.navController = navigationController
    }
    
    func navigate(to destination: NavigationDestination) {
        switch destination {
        case .mealDetails(let store):
            let mealVC = MealViewController(store: store)
            navController.pushViewController(mealVC, animated: true)
        }
    }
    
    enum NavigationDestination {
        case mealDetails(StoreFactory.MealStore)
    }
    
}

class SearchMealsNavigator: MealsNavigator {
    override func navigate(to destination: NavigationDestination) {
        switch destination {
        case .mealDetails(let meal):
            // ToDo: This is awful! Find a better way
            UIApplication.shared.open(URL(string: meal.state.meal.strYoutube!)!, options: [:], completionHandler: nil)
        }
    }
}

class ExploreMealsNavigator: MealsNavigator {
    override func navigate(to destination: NavigationDestination) {
        switch destination {
        case .mealDetails(let store):
            let mealVC = MealViewController(store: store)
            navController.pushViewController(mealVC, animated: true)
        }
    }
}

class MealNavigator: Navigator {
    private let navController: UINavigationController
    
    var presentingViewController: UIViewController? {
        return navController.topViewController
    }
    
    init(navigationController: UINavigationController) {
        self.navController = navigationController
    }
    
    func navigate(to destination: NavigationDestination) {
        switch destination {
        case .video(let url):
            UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
        }
    }
    
    enum NavigationDestination {
        case video(url: String)
    }
}

class SearchNavigator: Navigator {
    private let navController: UINavigationController
    
    var presentingViewController: UIViewController? {
        return navController.topViewController
    }
    
    var searchResultNavigator: MealsNavigator {
        return SearchMealsNavigator(navigationController: navController)
    }
    
    init(navigationController: UINavigationController) {
        self.navController = navigationController
    }
    
    func navigate(to destination: NavigationDestination) {
        switch destination {
        case .searchResult(let store):
            let mealsVC = MealsViewController(store: store)
            navController.pushViewController(mealsVC, animated: true)
        }
    }
    
    enum NavigationDestination {
        case searchResult(StoreFactory.MealsStore)
    }
}
