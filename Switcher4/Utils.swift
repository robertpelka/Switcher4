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

struct Models {
    private static let runningScene = SCNScene(named: "art.scnassets/maria/sprint.scn")!
    static let player = SCNNode()
    
    private static let monsterScene = SCNScene(named: "art.scnassets/monster/monster.scn")!
    static let monster = SCNNode()
    
    private static let logScene = SCNScene(named: "art.scnassets/log/log.scn")!
    static let log = SCNNode()
    
    private static let bridgeScene = SCNScene(named: "art.scnassets/bridge/bridge.scn")!
    static let bridge = SCNNode()
    
    private static let coinScene = SCNScene(named: "art.scnassets/coin/coin.scn")!
    static let coin = SCNNode()
    
    static var animations = [String: CAAnimation]()
    
    static func loadModels() {
        for childNode in runningScene.rootNode.childNodes {
            player.addChildNode(childNode)
        }
        for childNode in monsterScene.rootNode.childNodes {
            monster.addChildNode(childNode)
        }
        for childNode in logScene.rootNode.childNodes {
            log.addChildNode(childNode)
        }
        for childNode in bridgeScene.rootNode.childNodes {
            bridge.addChildNode(childNode)
        }
        for childNode in coinScene.rootNode.childNodes {
            coin.addChildNode(childNode)
        }
    }
    
    static func loadAnimations() {
        loadAnimation(from: "maria", named: "attack", fadeInDuration: 0.1, fadeOutDuration: 1.15, speed: 1.4)
        loadAnimation(from: "maria", named: "slide", fadeInDuration: 0.1, fadeOutDuration: 0.2)
        loadAnimation(from: "maria", named: "jump", fadeInDuration: 0.02, fadeOutDuration: 0.08)
        loadAnimation(from: "maria", named: "moveLeft", fadeInDuration: 0.1, fadeOutDuration: 0.3)
        loadAnimation(from: "maria", named: "moveRight", fadeInDuration: 0.1, fadeOutDuration: 0.3)
        loadAnimation(from: "maria", named: "roll", fadeInDuration: 0.1, fadeOutDuration: 0.1)
        loadAnimation(from: "maria", named: "trip", fadeInDuration: 0.1, fadeOutDuration: 0.1)
        loadAnimation(from: "monster", named: "death1", fadeInDuration: 0.1, fadeOutDuration: 0.1)
        loadAnimation(from: "monster", named: "death2", fadeInDuration: 0.1, fadeOutDuration: 0.1)
        loadAnimation(from: "monster", named: "death3", fadeInDuration: 0.1, fadeOutDuration: 0.1)
    }
    
    static func loadAnimation(from folder: String, named name: String, fadeInDuration: CGFloat, fadeOutDuration: CGFloat, speed: Float = 1.0) {
        let sceneURL = Bundle.main.url(forResource: "art.scnassets/" + folder + "/" + name, withExtension: "dae")
        guard let URL = sceneURL else { return }
        let sceneSource = SCNSceneSource(url: URL, options: nil)
        if let animationObject = sceneSource?.entryWithIdentifier(name + "-1", withClass: CAAnimation.self) {
            animationObject.repeatCount = 1
            animationObject.fadeInDuration = fadeInDuration
            animationObject.fadeOutDuration = fadeOutDuration
            animationObject.isRemovedOnCompletion = true
            animationObject.speed = speed
            animations[name] = animationObject
        }
    }
}
