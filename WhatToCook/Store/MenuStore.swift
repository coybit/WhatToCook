//
//  MenuStore.swift
//  WhatToCook
//
//  Created by Mohsen Alijanpour on 25/05/2020.
//  Copyright © 2020 mohsen.dev. All rights reserved.
//

import Foundation

struct MenuState: Cloneable {
    let savedList: SavedMealsList
}

enum MenuAction {
    case searchDidSelect
    case exploreDidSelect
    case randomMealDidSelect
    case savedMealsDidSelect
    case newRandomMealDidFetch(MealResponse)
    case errorOccurred(Error)
}

enum MenuSideEffect {
    case navigateToExplore
    case navigateToRandomMeal(MealResponse)
    case navigateToSavedMeals
    case navigateToSearch
    case navigateToError(Error)
    case fetchRandomMeal
}

struct MenuEnvironment {
    let navigator: MenuNavigator
    let savedMealsList: SavedMealsList
    let mealsService: MealsService
    let savedMealsService: MealsService
}


extension StoreFactory {
    typealias MenuStore = Store<MenuState, MenuAction, MenuSideEffect, MenuEnvironment>
    
    static func menu(navigator: MenuNavigator, savedList: SavedMealsList, mealsService: MealsService, savedMealsService: MealsService) -> MenuStore {
        return Store(
            state: .init(savedList: savedList),
            reducer: reducer(state:action:),
            sideEffectHandler: sideEffectHandler(store:sideEffect:),
            environment: .init(navigator: navigator,
                               savedMealsList: savedList,
                               mealsService: mealsService,
                               savedMealsService: savedMealsService)
        )
    }
    
    private static func reducer(state: MenuState, action: MenuAction) -> MenuStore.ReducerResult {
        switch action {
        case .exploreDidSelect:
            return (state: state, sideEffects: [.navigateToExplore])
        case .randomMealDidSelect:
            return (state: state, sideEffects: [.fetchRandomMeal])
        case .newRandomMealDidFetch(let meal):
            return (state: state, sideEffects: [.navigateToRandomMeal(meal)])
        case .errorOccurred(let error):
            return (state: state, sideEffects: [.navigateToError(error)])
        case .savedMealsDidSelect:
            return (state: state, sideEffects: [.navigateToSavedMeals])
        case .searchDidSelect:
             return (state: state, sideEffects: [.navigateToSearch])
        }
    }
    
    private static func sideEffectHandler(store: MenuStore, sideEffect: MenuSideEffect) {
        switch sideEffect {
        case .navigateToExplore:
            guard let env = store.environment else { return }
            let store = StoreFactory.categoriesStore(navigator: env.navigator.categoryNavigator,
                                                     savedList: env.savedMealsList,
                                                     mealsService: env.mealsService)
            env.navigator.navigate(to: .explore(store))
        case .fetchRandomMeal:
            fetchRandomFood(store: store)
        case .navigateToRandomMeal(let meal):
            guard let env = store.environment else { return }
            let store = StoreFactory.meal(meal: meal,
                                          navigator: env.navigator.categoryNavigator.mealsNavigator.mealNavigator,
                                          savedList: env.savedMealsList,
                                          mealsService: env.mealsService)
            env.navigator.navigate(to: .random(store))
        case .navigateToError(let error):
            guard let env = store.environment else { return }
            env.navigator.showError(error)
        case .navigateToSavedMeals:
            guard let env = store.environment else { return }
            let store = StoreFactory.mealsStore(category: .init(strCategory: "Saved", strCategoryThumb: "", strCategoryDescription: ""),
                                                navigator: env.navigator.categoryNavigator.mealsNavigator,
                                                savedList: env.savedMealsList,
                                                mealsService: SavedMealsService(savedMealsList: env.savedMealsList))
            env.navigator.navigate(to: .savedMeals(store))
        case .navigateToSearch:
            guard let env = store.environment else { return }
            let store = StoreFactory.ingredients(navigator: env.navigator.searchNavigator)
            env.navigator.navigate(to: .search(store))
        }
    }
    
    private static func fetchRandomFood(store: MenuStore) {
         guard let env = store.environment else { return }
         
         env.mealsService.getRandomFood { response in
             switch response {
             case .success(let food):
                store.dispatch(action: .newRandomMealDidFetch(food))
             case .failure(let error):
                 store.dispatch(action: .errorOccurred(error))
             }
         }
     }
}
