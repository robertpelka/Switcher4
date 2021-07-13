//
//  GameViewController.swift
//  Switcher4
//
//  Created by Robert Pelka on 11/07/2021.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    var scene: SCNScene!
    var sceneView: SCNView!
    
    let cameraNode = SCNNode()
    let lightNode = SCNNode()
    let playerNode = SCNNode()
    
    var animations = [String: CAAnimation]()
    var score = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeGame()
    }
    
    func initializeGame() {
        setupScene()
        setupCamera()
        setupLight()
        setupFloor()
        setupPlayer()
        loadAnimations()
        setupGestures()
        spawnObstacles()
    }
    
    func setupScene() {
        sceneView = (view as! SCNView)
        sceneView.delegate = self
        
        scene = SCNScene()
        sceneView.scene = scene
        scene.physicsWorld.contactDelegate = self
        
        sceneView.backgroundColor = UIColor(red: 255/255, green: 210/255, blue: 138/255, alpha: 1)
        sceneView.showsStatistics = true
        //sceneView.debugOptions = .showPhysicsShapes
        //sceneView.allowsCameraControl = true
    }
    
    func setupCamera() {
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 3.2)
        cameraNode.eulerAngles = SCNVector3(x: convertToRadians(degrees: -35), y: 0, z: 0)
        scene.rootNode.addChildNode(cameraNode)
    }
    
    func setupLight() {
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.intensity = 100
        lightNode.addChildNode(ambientLightNode)
        
        let directionalLightNode = SCNNode()
        directionalLightNode.light = SCNLight()
        directionalLightNode.light?.type = .directional
        directionalLightNode.light?.temperature = 3500
        directionalLightNode.light?.castsShadow = true
        directionalLightNode.light?.maximumShadowDistance = 32.0
        directionalLightNode.light?.shadowMapSize = CGSize(width: 2048, height: 2048)
        directionalLightNode.eulerAngles = SCNVector3(x: convertToRadians(degrees: -45), y: convertToRadians(degrees: -45), z: 0)
        lightNode.addChildNode(directionalLightNode)
        
        lightNode.position = cameraNode.position
        scene.rootNode.addChildNode(lightNode)
    }
    
    func setupFloor() {
        let floor = SCNFloor()
        floor.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/grass/grassColor.jpg")
        floor.firstMaterial?.diffuse.wrapS = .repeat
        floor.firstMaterial?.diffuse.wrapT = .repeat
        floor.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(15, 15, 15)
        
        floor.firstMaterial?.ambientOcclusion.contents = UIImage(named: "art.scnassets/grass/grassAmbientOcclusion.jpg")
        floor.firstMaterial?.displacement.contents = UIImage(named: "art.scnassets/grass/grassDisplacement.jpg")
        floor.firstMaterial?.normal.contents = UIImage(named: "art.scnassets/grass/grassNormal.jpg")
        floor.firstMaterial?.roughness.contents = UIImage(named: "art.scnassets/grassRoughness.jpg")
        
        floor.reflectivity = 0
        let floorNode = SCNNode(geometry: floor)
        scene.rootNode.addChildNode(floorNode)
    }
    
    func setupPlayer() {
        let runningScene = SCNScene(named: "art.scnassets/maria/sprint.scn")!
        for child in runningScene.rootNode.childNodes {
            playerNode.addChildNode(child)
        }
        
        playerNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        playerNode.eulerAngles = SCNVector3(x: 0, y: convertToRadians(degrees: 180), z: 0)
        let runningAction = SCNAction.repeatForever(SCNAction.moveBy(x: 0, y: 0, z: -5.5, duration: 1.0))
        playerNode.runAction(runningAction)
        
        sceneView.scene?.rootNode.addChildNode(playerNode)
    }
    
    func loadAnimations() {
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
    
    func loadAnimation(from folder: String, named name: String, fadeInDuration: CGFloat, fadeOutDuration: CGFloat, speed: Float = 1.0) {
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
    
    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        sceneView.addGestureRecognizer(tapGesture)
        
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeUpGesture.direction = .up
        sceneView.addGestureRecognizer(swipeUpGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeDownGesture.direction = .down
        sceneView.addGestureRecognizer(swipeDownGesture)
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeRightGesture.direction = .right
        sceneView.addGestureRecognizer(swipeRightGesture)
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeLeftGesture.direction = .left
        sceneView.addGestureRecognizer(swipeLeftGesture)
    }
    
    @objc func handleSwipeGesture(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
            case .up:
                runAnimation(named: "jump", on: playerNode)
            case .down:
                runAnimation(named: "slide", on: playerNode)
            case .right:
                if playerNode.position.x <= 0.01 {
                    runAnimation(named: "moveRight", on: playerNode)
                    let moveRightAction = SCNAction.moveBy(x: 0.8, y: 0, z: 0, duration: 0.35)
                    moveRightAction.timingMode = .easeOut
                    playerNode.runAction(moveRightAction)
                }
            case .left:
                if playerNode.position.x >= -0.01 {
                    runAnimation(named: "moveLeft", on: playerNode)
                    let moveLeftAction = SCNAction.moveBy(x: -0.8, y: 0, z: 0, duration: 0.35)
                    moveLeftAction.timingMode = .easeOut
                    playerNode.runAction(moveLeftAction)
                }
            default:
                break
        }
    }
    
    @objc func handleTapGesture(_ sender: UISwipeGestureRecognizer) {
        runAnimation(named: "attack", on: playerNode)
    }
    
    func runAnimation(named name: String, on node: SCNNode) {
        var animationNames = ["jump", "slide", "attack"]
        animationNames.append(name)
        if !node.animationKeys.contains(where: animationNames.contains) {
            if let animation = animations[name] {
                node.addAnimation(animation, forKey: name)
            }
        }
    }
    
    func spawnObstacles() {
        for i in 2...40 {
            let xPosition = 0.8 * Float(Int.random(in: -1...1))
            let zPosition = Float(-11 * i)
            let randomNumber = Int.random(in: 1...4)
            if randomNumber == 1 {
                spawnMonster(at: SCNVector3(x: xPosition, y: 0, z: zPosition))
            }
            else if randomNumber == 2 {
                spawnBridge(at: SCNVector3(x: xPosition, y: 0, z: zPosition))
            }
            else if randomNumber == 3 {
                spawnCoin(at: SCNVector3(x: xPosition, y: 1.0, z: zPosition))
            }
            else {
                spawnLog(at: SCNVector3(x: xPosition, y: 0, z: zPosition))
            }
        }
    }
    
    func spawnMonster(at position: SCNVector3) {
        let monsterNode = SCNNode()
        let monsterScene = SCNScene(named: "art.scnassets/monster/monster.scn")!
        for child in monsterScene.rootNode.childNodes {
            monsterNode.addChildNode(child)
        }
        
        monsterNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        monsterNode.position = position
        
        sceneView.scene?.rootNode.addChildNode(monsterNode)
    }
    
    func spawnLog(at position: SCNVector3) {
        let logNode = SCNNode()
        let logScene = SCNScene(named: "art.scnassets/log/log.scn")!
        for child in logScene.rootNode.childNodes {
            logNode.addChildNode(child)
        }
        
        logNode.eulerAngles = SCNVector3(x: 0, y: convertToRadians(degrees: Float.random(in: -110 ... -70)), z: 0)
        logNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        logNode.position = position
        
        sceneView.scene?.rootNode.addChildNode(logNode)
    }
    
    func spawnBridge(at position: SCNVector3) {
        let bridgeNode = SCNNode()
        let bridgeScene = SCNScene(named: "art.scnassets/bridge/bridge.scn")!
        for child in bridgeScene.rootNode.childNodes {
            bridgeNode.addChildNode(child)
        }
        
        bridgeNode.scale = SCNVector3(x: 0.065, y: 0.035, z: 0.09)
        bridgeNode.position = position
        
        sceneView.scene?.rootNode.addChildNode(bridgeNode)
    }
    
    func spawnCoin(at position: SCNVector3) {
        let coinNode = SCNNode()
        let coinScene = SCNScene(named: "art.scnassets/coin/coin.scn")!
        for child in coinScene.rootNode.childNodes {
            coinNode.addChildNode(child)
        }
        
        coinNode.scale = SCNVector3(x: 0.0015, y: 0.0015, z: 0.0015)
        coinNode.eulerAngles = SCNVector3(x: convertToRadians(degrees: -90), y: 0, z: 0)
        coinNode.position = position
        coinNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: convertToRadians(degrees: 180), z: 0, duration: 1.0)))
        
        sceneView.scene?.rootNode.addChildNode(coinNode)
    }

}

//MARK: - SCNSceneRendererDelegate

extension GameViewController: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        updateCameraPosition()
    }
    
    func updateCameraPosition() {
        let differenceZ = playerNode.position.z + 3.2 - cameraNode.position.z
        cameraNode.position.z += differenceZ
    }
    
}

//MARK: - SCNPhysicsContactDelegate

extension GameViewController: SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        guard let categoryA = contact.nodeA.physicsBody?.categoryBitMask, let categoryB = contact.nodeB.physicsBody?.categoryBitMask else { return }
        
        let mask = categoryA | categoryB
        
        switch mask {
        case PhysicsCategories.player | PhysicsCategories.monster:
            endGame(withAnimation: "death1")
        case PhysicsCategories.sword | PhysicsCategories.monster:
            let monster = contact.nodeA.name == "Monster" ? contact.nodeA : contact.nodeB
            if playerNode.animationKeys.contains("attack") {
                monster.physicsBody?.categoryBitMask = 0
                if let monster = monster.parent {
                    runAnimation(named: "death" + String(Int.random(in: 1...3)), on: monster)
                }
            }
        case PhysicsCategories.player | PhysicsCategories.log:
            if !playerNode.animationKeys.contains("jump") {
                endGame(withAnimation: "trip")
            }
        case PhysicsCategories.player | PhysicsCategories.bridge:
            let bridge = contact.nodeA.name == "Bridge" ? contact.nodeA : contact.nodeB
            guard let bridgeParent = bridge.parent else { return }
            if !playerNode.animationKeys.contains("slide") || abs(playerNode.position.x - bridgeParent.position.x) > 0.1 {
                endGame(withAnimation: "death2")
            }
        case PhysicsCategories.player | PhysicsCategories.coin:
            let coin = contact.nodeA.name == "Coin" ? contact.nodeA : contact.nodeB
            coin.removeFromParentNode()
            score += 1
        default:
            break
        }
    }
    
    func endGame(withAnimation name: String) {
        playerNode.removeAllActions()

        if let animation = animations[name] {
            playerNode.addAnimation(animation, forKey: name)
        }
        
        let wait = SCNAction()
        wait.duration = 1.6
        playerNode.runAction(wait) {
            self.playerNode.removeFromParentNode()
        }
        
        DispatchQueue.main.async {
            if let gestureRecognizers = self.sceneView.gestureRecognizers {
                for recognizer in gestureRecognizers {
                    self.sceneView.removeGestureRecognizer(recognizer)
                }
            }
        }
    }
    
}
