//
//  Utils.swift
//  Switcher4
//
//  Created by Robert Pelka on 11/07/2021.
//

import Foundation

func convertToRadians(degrees: Float) -> Float {
    return Float.pi/180 * degrees
}

struct PhysicsCategories {
    static let player = 1
    static let monster = 2
    static let sword = 4
}
