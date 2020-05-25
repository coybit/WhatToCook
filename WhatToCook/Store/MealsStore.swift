//
//  MealsStore.swift
//  WhatToCook
//
//  Created by Mohsen Alijanpour on 25/05/2020.
//  Copyright © 2020 mohsen.dev. All rights reserved.
//

import Foundation

enum ContentPhase<D> {
    case idle
    case loading
    case data(D)
    case loadingMore(D)
    case empty
    case error
}

struct MealsState: Cloneable {
    let title: String
    let category: CategoryResponse
    var content: ContentPhase<MealsResponse>
    var page: Int?
}

enum MealsAction {
    case viewDidLoad
    case mealsDidReceive(MealsResponse)
    case moreMealsDidReceive(MealsResponse)
    case errorOccurred(Error)
    case mealDidSelect(MealResponse)
    case tryAgain
    case reachEndOfList
}

enum MealsSideEffects {
    case fetchMeals
    case fetchMoreMeals
    case navigateToMealDetails(MealResponse)
}

struct MealsEnvironment {
    let savedMealsList: SavedMealsList
    let navigator: MealsNavigator
    let mealsService: MealsService
}

extension StoreFactory {
    typealias MealsStore = Store<MealsState, MealsAction, MealsSideEffects, MealsEnvironment>
    
    static func mealsStore(category: CategoryResponse, navigator: MealsNavigator, savedList: SavedMealsList, mealsService: MealsService) -> MealsStore {
        return .init(
            state: .init(title: category.strCategory, category: category, content: .idle),
            reducer: reducer(state:action:),
            sideEffectHandler: sideEffectHandler(store:sideEffect:),
            environment: MealsEnvironment(savedMealsList: savedList, navigator: navigator, mealsService: mealsService))
    }
    
    private static func reducer(state: MealsState, action: MealsAction) -> MealsStore.ReducerResult {
        switch action {
        case .viewDidLoad:
            return (state: state.set(\.content, to: .loading),
                    sideEffects: [.fetchMeals])
        case .mealsDidReceive(let meals):
            if meals.meals.isEmpty {
                return (state: state.set(\.content, to: .empty),
                        sideEffects: [])
            } else {
                return (state: state.set(\.content, to: .data(meals)).set(\.page, to: meals.nextPage),
                        sideEffects: [])
            }
        case .errorOccurred(_):
            return (state: state.set(\.content, to: .error),
                    sideEffects: [])
        case .mealDidSelect(let meal):
            return (state: state,
                    sideEffects: [.navigateToMealDetails(meal)])
        case .tryAgain:
            return (state: state.set(\.content, to: .loading),
                    sideEffects: [.fetchMeals])
        case .reachEndOfList:
            guard case .data(let data) = state.content else { return (state: state, sideEffects: []) }
            
            return (state: state.set(\.content, to: .loadingMore(data)),
                    sideEffects: [.fetchMoreMeals])
        case .moreMealsDidReceive(let meals):
            if meals.meals.isEmpty {
                return (state: state,
                        sideEffects: [])
            } else {
                guard case .loadingMore(let data) = state.content else { return (state: state, sideEffects: []) }
                
                let allMeals = MealsResponse(meals: data.meals + meals.meals, nextPage: meals.nextPage)
                return (state: state.set(\.content, to: .data(allMeals)).set(\.page, to: meals.nextPage),
                        sideEffects: [])
            }
        }
    }
    
    private static func sideEffectHandler(store: MealsStore, sideEffect: MealsSideEffects) {
        switch sideEffect {
        case .fetchMeals:
            fetchMeals(store: store)
        case .navigateToMealDetails(let meal):
            guard let env = store.environment else { return }
            
            let mealStore = StoreFactory.meal(meal: meal,
                                              navigator: env.navigator.mealNavigator,
                                              savedList: env.savedMealsList,
                                              mealsService: env.mealsService)
            env.navigator.navigate(to: .mealDetails(mealStore))
        case .fetchMoreMeals:
            fetchMeals(store: store, page: store.state.page)
        }
    }
    
    private static func fetchMeals(store: MealsStore, page: Int? = nil) {
        guard let env = store.environment else { return }
        
        env.mealsService.getMeals(category: store.state.category, page: page) { result in
            switch result {
            case .failure(let error):
                store.dispatch(action: .errorOccurred(error))
            case .success(let meals):
                if page == nil {
                    store.dispatch(action: .mealsDidReceive(meals))
                } else {
                    store.dispatch(action: .moreMealsDidReceive(meals))
                }
            }
        }
    }
}
