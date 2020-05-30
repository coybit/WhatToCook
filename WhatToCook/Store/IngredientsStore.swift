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
    var ingredients: [Ingredient]
    let title: String = "Ingredients"
    var filter: String
    var displayingIngredients: [Ingredient] {
        return filter.isEmpty ? ingredients : ingredients.filter { $0.name.contains(filter) }
    }
}

enum IngredientsAction {
    case viewDidLoad
    case ingredientDidSelect(Int)
    case filterDidChange(String)
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
                .init(name: "Pasta", icon: "🍝", selected: false),
                .init(name: "Rice", icon: "🍚", selected: false),
                .init(name: "Bread", icon: "🍞", selected: false),
                .init(name: "Tomato", icon: "🍅", selected: false),
                .init(name: "Corn", icon: "🌽", selected: false),
                .init(name: "Avocado", icon: "🥑", selected: false),
                .init(name: "Eggplant", icon: "🍆", selected: false),
                .init(name: "Carrot", icon: "🥕", selected: false),
                .init(name: "Union", icon: "🧅", selected: false),
                .init(name: "Garlic", icon: "🧄", selected: false),
                .init(name: "Potato", icon: "🥔", selected: false),
                .init(name: "Sweet Potato", icon: "🍠", selected: false),
                .init(name: "Cheese", icon: "🧀", selected: false),
                .init(name: "Lettuce", icon: "🥬", selected: false),
                .init(name: "Broccoli", icon: "🥦", selected: false),
                .init(name: "Cucumber", icon: "🥒", selected: false),
                .init(name: "Coconut", icon: "🥥", selected: false),
                .init(name: "Peanut", icon: "🥜", selected: false),
            ], filter: ""),
            reducer: reducer(state:action:),
            sideEffectHandler: sideEffectHandler(store:sideEffect:),
            environment: .init(navigator: navigator)
            )
    }
    
    fileprivate static func reducer(state: IngredientsState, action: IngredientsAction) -> IngredientsStore.ReducerResult {
        switch action {
        case .ingredientDidSelect(let index):
            let newIngredients = state.ingredients.map { (ingredient: Ingredient) -> Ingredient in
                if ingredient.name == state.displayingIngredients[index].name {
                    return ingredient.set(\.selected, to: !ingredient.selected)
                } else {
                    return ingredient
                }
            }
            return (state: state.set(\.ingredients, to: newIngredients), sideEffects: [])
        case .searchDidTap:
            return (state: state, sideEffects: [.navigateToSearch])
        case .viewDidLoad:
            return (state: state, sideEffects: [])
        case .filterDidChange(let filter):
            return (state: state.set(\.filter, to: filter),
                    sideEffects: [])
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
