//
//  AppStore.swift
//  WhatToCook
//
//  Created by Mohsen Alijanpour on 25/05/2020.
//  Copyright © 2020 mohsen.dev. All rights reserved.
//

import UIKit

struct AppState: Cloneable {
}

enum AppAction {
    case appDidLoad
}
enum AppSideEffect {
    case navigateToRoot
}

struct AppEnvironment {
    let savedMealsList: SavedMealsList
    let window: UIWindow?
    let navigationController: UINavigationController
    let mealsService: MealsService
    let savedMealsService: MealsService
}

extension StoreFactory {
    typealias AppStore = Store<AppState, AppAction, AppSideEffect, AppEnvironment>
    
    static func app(window: UIWindow?) -> AppStore {
        let savedMealsList = SavedMealsList()
        return AppStore(
            state: AppState(),
            reducer: reducer(state:action:),
            sideEffectHandler: sideEffectHandler(store:sideEffect:),
            environment: AppEnvironment(savedMealsList: savedMealsList,
                                        window: window,
                                        navigationController: UINavigationController(),
                                        mealsService: APIFoodService(),
                                        savedMealsService: SavedMealsService(savedMealsList: savedMealsList)
            )
        )
    }
    
    fileprivate static func reducer(state: AppState, action: AppAction) -> AppStore.ReducerResult {
        switch action {
        case .appDidLoad:
            return (state: state, sideEffects: [.navigateToRoot])
        }
    }
    
    fileprivate static func sideEffectHandler(store: AppStore, sideEffect: AppSideEffect) {
        switch sideEffect {
        case .navigateToRoot:
            guard let env = store.environment else { return }
            
            let menuStore = StoreFactory.menu(
                navigator: .init(navigationController: env.navigationController),
                savedList: env.savedMealsList,
                mealsService: env.mealsService,
                savedMealsService: env.savedMealsService)
            env.navigationController.setViewControllers([MenuViewController(store: menuStore)], animated: true)
            env.window?.rootViewController = env.navigationController
        }
    }
}
