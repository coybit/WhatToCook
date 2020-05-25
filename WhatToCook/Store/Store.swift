//
//  Store.swift
//  WhatToCook
//
//  Created by Mohsen Alijanpour on 25/05/2020.
//  Copyright © 2020 mohsen.dev. All rights reserved.
//

import Foundation

class Store<State, Action, SideEffect, Environment> where State: Cloneable {
    typealias Subscriber = ((State) -> Void)
    typealias ReducerResult = (state: State, sideEffects: [SideEffect])
    typealias Reducer = (State, Action) -> ReducerResult
    typealias SideEffectHandler = (Store, SideEffect) -> Void
    
    var sideEffectHandler: SideEffectHandler
    var reducer: Reducer
    var subscriber: Subscriber? = nil
    var environment: Environment? = nil
    var state: State
    
    internal init(state: State,
                  reducer: @escaping Reducer,
                  sideEffectHandler: @escaping SideEffectHandler,
                  environment: Environment? = nil) {
        self.sideEffectHandler = sideEffectHandler
        self.reducer = reducer
        self.state = state
        self.environment = environment
    }
    
    func dispatch(action: Action) {
        let result = reducer(state, action)
        
        state = result.state
        
        subscriber?(result.state)
        
        result.sideEffects.forEach { sideEffectHandler(self, $0) }
    }
    
    func on(stateChange subscriber: @escaping (State) -> Void) {
        self.subscriber = subscriber
    }
}
