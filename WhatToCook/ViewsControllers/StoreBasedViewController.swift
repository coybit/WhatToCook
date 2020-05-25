//
//  StoreBasedViewController.swift
//  WhatToCook
//
//  Created by Mohsen Alijanpour on 25/05/2020.
//  Copyright © 2020 mohsen.dev. All rights reserved.
//

import Foundation

protocol StoreBasedViewController {
    associatedtype State where State: Cloneable
    associatedtype Action
    associatedtype SideEffect
    associatedtype Environment
    var store: Store<State, Action, SideEffect, Environment> { get }
}
