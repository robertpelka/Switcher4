//
//  Utils.swift
//  Switcher4
//
//  Created by Robert Pelka on 11/07/2021.
//

import Foundation
import SceneKit

func convertToRadians(degrees: Float) -> Float {
    return Float.pi/180 * degrees
}

func convertToRadians(degrees: Float) -> CGFloat {
    return CGFloat.pi/180 * CGFloat(degrees)
}

struct PhysicsCategories {
    static let player = 1
    static let monster = 2
    static let sword = 4
    static let log = 8
    static let bridge = 16
    static let coin = 32
}
