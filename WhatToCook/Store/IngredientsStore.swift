//
//  IngredientsStore.swift
//  WhatToCook
//
//  Created by Mohsen Alijanpour on 26/05/2020.
//  Copyright © 2020 mohsen.dev. All rights reserved.
//

import Foundation

struct Ingredient: Cloneable {
    let name: String
    let icon: String
    var selected: Bool
}

struct IngredientsState: Cloneable {
    let ingredients: [Ingredient]
}

enum IngredientsAction {
    case viewDidLoad
    case ingredientDidSelect(Int)
    case searchDidTap
}

enum IngredientsSideEffect {
    case navigateToSearch
}

struct IngredientsEnvironment {
    let navigator: SearchNavigator
}

extension StoreFactory {
    typealias IngredientsStore = Store<IngredientsState, IngredientsAction, IngredientsSideEffect, IngredientsEnvironment>
    
    static func ingredients(navigator: SearchNavigator) -> IngredientsStore {
        return IngredientsStore(
            state: IngredientsState(ingredients: [
                .init(name: "Meat", icon: "🥩", selected: false),
                .init(name: "Chicken", icon: "🍗", selected: false),
                .init(name: "Egg", icon: "🥚", selected: false),
                .init(name: "Noodle", icon: "🍜", selected: false),
                .init(name: "Tomato", icon: "🍅", selected: false),
                .init(name: "Apple", icon: "🍎", selected: false),
            ]),
            reducer: reducer(state:action:),
            sideEffectHandler: sideEffectHandler(store:sideEffect:),
            environment: .init(navigator: navigator)
            )
    }
    
    fileprivate static func reducer(state: IngredientsState, action: IngredientsAction) -> IngredientsStore.ReducerResult {
        switch action {
        case .ingredientDidSelect(let index):
            var list = state.ingredients
            list[index].selected.toggle()
            return (state: .init(ingredients: list),
                    sideEffects: [])
        case .searchDidTap:
            return (state: state, sideEffects: [.navigateToSearch])
        case .viewDidLoad:
            return (state: state, sideEffects: [])
        }
    }
    
    fileprivate static func sideEffectHandler(store: IngredientsStore, sideEffect: IngredientsSideEffect) {
        switch sideEffect {
        case .navigateToSearch:
            guard let env = store.environment else { return }
            
            let ingredient = store.state.ingredients.filter { $0.selected }
            let mealsStore = StoreFactory.mealsStore(category: .init(strCategory: "Search", strCategoryThumb: "", strCategoryDescription: ""),
                                                     navigator: env.navigator.searchResultNavigator,
                                                     savedList: SavedMealsList(),
                                                     mealsService: RecipePuppySearchAPI(ingredients: ingredient))
            
            env.navigator.navigate(to: .searchResult(mealsStore))
        }
    }
}
