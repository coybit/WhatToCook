//
//  Cloneable.swift
//  WhatToCook
//
//  Created by Mohsen Alijanpour on 26/05/2020.
//  Copyright © 2020 mohsen.dev. All rights reserved.
//

import Foundation

protocol Cloneable {
    func set<V>(_ path: WritableKeyPath<Self,V>, to newValue: V) -> Self
}

extension Cloneable {
    func set<V>(_ path: WritableKeyPath<Self,V>, to newValue: V) -> Self {
        var copy = self
        copy[keyPath: path] = newValue
        return copy
    }
}
