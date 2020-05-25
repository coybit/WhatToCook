//
//  MealStore.swift
//  WhatToCook
//
//  Created by Mohsen Alijanpour on 25/05/2020.
//  Copyright © 2020 mohsen.dev. All rights reserved.
//

import UIKit

struct MealState: Cloneable {
    let title: String
    let instruction: String?
    let image: UIImage?
    let meal: MealResponse
    let saved: Bool
    
    internal init(meal: MealResponse, image: UIImage? = nil, saved: Bool = false) {
        self.title = meal.strMeal
        self.instruction = meal.strInstructions
        self.image = image
        self.meal = meal
        self.saved = saved
    }
}

enum MealAction {
    case mealReceived(MealResponse)
    case mealImageReceived(UIImage)
    case errorOccurred(Error)
    case viewDidLoad
    case saveDidTap
    case openVideoTap
    case saved
    case unsaved
    case savedStateDidFetch(Bool)
}

enum MealSideEffect {
    case fetchFoodImage(String)
    case fetchFood(MealResponse)
    case save
    case unsave
    case fetchSavedState
    case openVideo
}

struct MealEnvironment {
    let navigator: MealNavigator
    let savedMealsList: SavedMealsList
    let mealsService: MealsService
}

extension StoreFactory {
    typealias MealStore = Store<MealState, MealAction, MealSideEffect, MealEnvironment>
    
    static func meal(meal: MealResponse, navigator: MealNavigator, savedList: SavedMealsList, mealsService: MealsService) -> MealStore {
        return .init(
            state: .init(meal: meal),
            reducer: reducer(state:action:),
            sideEffectHandler: sideEffectHandler(store:sideEffect:),
            environment: MealEnvironment(navigator: navigator, savedMealsList: savedList, mealsService: mealsService)
        )
    }
    
    private static func reducer(state: MealState, action: MealAction) -> MealStore.ReducerResult {
        switch action {
        case .mealReceived(let meal):
            return (state: .init(meal: meal, saved: state.saved),
                    sideEffects: [.fetchFoodImage(meal.strMealThumb)])
        case .errorOccurred(_):
            return (state: .init(meal: state.meal, saved: state.saved),
                    sideEffects: [])
        case .mealImageReceived(let image):
            return (state: .init(meal: state.meal, image: image, saved: state.saved),
                    sideEffects: [])
        case .viewDidLoad:
             return (state: state,
                     sideEffects: [.fetchFood(state.meal), .fetchSavedState])
        case .saveDidTap:
            return (state: state,
                    sideEffects: [state.saved ? .unsave : .save])
        case .saved:
            return (state: .init(meal: state.meal, image: state.image, saved: true),
                    sideEffects: [])
        case .unsaved:
            return (state: .init(meal: state.meal, image: state.image, saved: false),
                    sideEffects: [])
        case .savedStateDidFetch(let saved):
            return (state: .init(meal: state.meal,
                                 image: state.image,
                                 saved: saved),
            sideEffects: [])
        case .openVideoTap:
            return (state: state,
                    sideEffects: [.openVideo])
        }
    }
    
    private static func sideEffectHandler(store: MealStore, sideEffect: MealSideEffect) {
        switch sideEffect {
        case .fetchFoodImage(let imageUrl):
            self.fetchImage(store: store, imageUrl)
        case .fetchFood(let meal):
            self.fetchMeal(store: store, meal: meal)
        case .save:
             guard let env = store.environment else { return }
             self.save(store: store, savedList: env.savedMealsList)
        case .unsave:
             guard let env = store.environment else { return }
            self.unsave(store: store, savedList: env.savedMealsList)
        case .fetchSavedState:
            guard let env = store.environment else { return }
            store.dispatch(action: .savedStateDidFetch(env.savedMealsList.isSaved(meal: store.state.meal)))
        case .openVideo:
            if let videoUrl = store.state.meal.strYoutube, let env = store.environment {
                env.navigator.navigate(to: .video(url: videoUrl))
            }
        }
    }
    
    private static func fetchMeal(store: MealStore, meal: MealResponse) {
        guard let env = store.environment else { return }
        
        env.mealsService.getMeal(meal: meal) { response in
                switch response {
                case .success(let meal):
                    store.dispatch(action: .mealReceived(meal))
                case .failure(let error):
                    store.dispatch(action: .errorOccurred(error))
                }
            }
        }
    
    private static func fetchImage(store: MealStore, _ imageUrl: String) {
         guard let env = store.environment else { return }
         
         env.mealsService.getImage(imageUrl) { response in
             switch response {
             case .success(let image):
                store.dispatch(action: .mealImageReceived(image))
             case .failure(let error):
                 store.dispatch(action: .errorOccurred(error))
             }
         }
     }
    
     private static func save(store: MealStore, savedList: SavedMealsList) {
        savedList.save(meal: store.state.meal)
        store.dispatch(action: .saved)
     }
    
    private static func unsave(store: MealStore, savedList: SavedMealsList) {
        savedList.unsave(meal: store.state.meal)
       store.dispatch(action: .unsaved)
    }
}
