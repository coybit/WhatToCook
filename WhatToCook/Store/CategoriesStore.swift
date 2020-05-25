//
//  CategoriesStore.swift
//  WhatToCook
//
//  Created by Mohsen Alijanpour on 25/05/2020.
//  Copyright © 2020 mohsen.dev. All rights reserved.
//

import Foundation

struct CategoriesState: Cloneable {
    let title: String
    let categories: CategoriesResponse
}

enum CategoriesAction {
    case viewDidLoad
    case categoriesDidReceive(CategoriesResponse)
    case errorOccurred(Error)
    case selectCategory(Int)
}

enum CategoriesSideEffects {
    case fetchCategories
    case navigateToDetails(CategoryResponse)
}

struct CategoriesEnvironment {
    let savedMealsList: SavedMealsList
    let navigator: CategoriesNavigator
    let mealsService: MealsService
}

extension StoreFactory {
    typealias CategoriesStore = Store<CategoriesState, CategoriesAction, CategoriesSideEffects, CategoriesEnvironment>
    
    static func categoriesStore(navigator: CategoriesNavigator, savedList: SavedMealsList, mealsService: MealsService) -> CategoriesStore {
        return .init(
            state: .init(title: "Categories", categories: .init(categories: [])),
            reducer: reducer(state:action:),
            sideEffectHandler: sideEffectHandler(store:sideEffect:),
            environment: .init(savedMealsList: savedList, navigator: navigator, mealsService: mealsService)
        )
    }
    
    private static func reducer(state: CategoriesState, action: CategoriesAction) -> CategoriesStore.ReducerResult {
        switch action {
        case .viewDidLoad:
            return (state: state, sideEffects: [.fetchCategories])
        case .categoriesDidReceive(let categories):
            return (state: .init(title: "Categories", categories: categories), sideEffects: [])
        case .errorOccurred(_):
            return (state: .init(title: "Error", categories: .init(categories: [])), sideEffects: [])
        case .selectCategory(let index):
            return (state: state, sideEffects: [.navigateToDetails(state.categories.categories[index])])
        }
    }
    
    private static func sideEffectHandler(store: CategoriesStore, sideEffect: CategoriesSideEffects) {
        switch sideEffect {
        case .fetchCategories:
            fetchCategories(store: store)
        case .navigateToDetails(let category):
            guard let env = store.environment else { return }
            
            let mealsStore = StoreFactory.mealsStore(
                category: category,
                navigator: env.navigator.mealsNavigator,
                savedList: env.savedMealsList,
                mealsService: env.mealsService)
            env.navigator.navigate(to: .mealsList(mealsStore))
        }
    }
    
    private static func fetchCategories(store: CategoriesStore) {
        guard let env = store.environment else { return }
        
        env.mealsService.getCategories { result in
            switch result {
            case .failure(let error):
                store.dispatch(action: .errorOccurred(error))
            case .success(let categories):
                store.dispatch(action: .categoriesDidReceive(categories))
            }
        }
    }
}
