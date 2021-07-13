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
    
    var obstacleCounter = 0
    var score = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeGame()
    }
    
    func initializeGame() {
        Models.loadModels()
        Models.loadAnimations()
        setupScene()
        setupCamera()
        setupLight()
        setupFloor()
        setupPlayer()
        setupGestures()
        spawnStartingObstacles()
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
        floor.firstMaterial?.roughness.contents = UIImage(named: "art.scnassets/grass/grassRoughness.jpg")
        
        floor.reflectivity = 0
        let floorNode = SCNNode(geometry: floor)
        scene.rootNode.addChildNode(floorNode)
    }
    
    func setupPlayer() {
        playerNode.addChildNode(Models.player.clone())
        
        playerNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        playerNode.eulerAngles = SCNVector3(x: 0, y: convertToRadians(degrees: 180), z: 0)
        let runningAction = SCNAction.repeatForever(SCNAction.moveBy(x: 0, y: 0, z: -5.5, duration: 1.0))
        playerNode.runAction(runningAction)
        
        sceneView.scene?.rootNode.addChildNode(playerNode)
    }
    
    func spawnStartingObstacles() {
        for _ in 1...8 {
            spawnObstacle()
        }
    }
    
    func spawnObstacle() {
        let xPosition = 0.8 * Float(Int.random(in: -1...1))
        let zPosition = Float(-12 * (obstacleCounter + 2))
        let oneInThree = Int.random(in: 1...3)
        if oneInThree == 1 {
            spawnMonster(at: SCNVector3(x: xPosition, y: 0, z: zPosition))
        }
        else if oneInThree == 2 {
            spawnBridge(at: SCNVector3(x: xPosition, y: 0, z: zPosition))
        }
        else {
            spawnLog(at: SCNVector3(x: xPosition, y: 0, z: zPosition))
        }
        spawnCoins(at: SCNVector3(x: Float(Int.random(in: -1...1)), y: 1.0, z: zPosition - 6))
        obstacleCounter += 1
    }
    
    func spawnMonster(at position: SCNVector3) {
        let monsterNode = Models.monster.clone()
        
        monsterNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        monsterNode.position = position
        
        sceneView.scene?.rootNode.addChildNode(monsterNode)
    }
    
    func spawnLog(at position: SCNVector3) {
        let logNode = Models.log.clone()
        
        logNode.eulerAngles = SCNVector3(x: 0, y: convertToRadians(degrees: Float.random(in: -110 ... -70)), z: 0)
        logNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        logNode.position = position
        
        sceneView.scene?.rootNode.addChildNode(logNode)
    }
    
    func spawnBridge(at position: SCNVector3) {
        let bridgeNode = Models.bridge.clone()
        
        bridgeNode.scale = SCNVector3(x: 0.065, y: 0.035, z: 0.09)
        bridgeNode.position = position
        
        sceneView.scene?.rootNode.addChildNode(bridgeNode)
    }
    
    func spawnCoins(at position: SCNVector3) {
        for i in -1...1 {
            let coinNode = Models.coin.clone()
            
            coinNode.scale = SCNVector3(x: 0.0015, y: 0.0015, z: 0.0015)
            coinNode.eulerAngles = SCNVector3(x: convertToRadians(degrees: -90), y: 0, z: 0)
            coinNode.position = SCNVector3(x: position.x, y: position.y, z: position.z + Float(2 * i))
            coinNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: convertToRadians(degrees: 180), z: 0, duration: 1.0)))
            
            sceneView.scene?.rootNode.addChildNode(coinNode)
        }
    }
    
    func removePassedObstacles() {
        guard let scene = sceneView.scene else { return }
        for childNode in scene.rootNode.childNodes {
            if !sceneView.isNode(childNode, insideFrustumOf: cameraNode) && childNode.worldPosition.z > playerNode.worldPosition.z {
                if !(childNode.childNodes.first?.name == "Coin") {
                    spawnObstacle()
                }
                childNode.removeFromParentNode()
            }
        }
    }

}

//MARK: - Gesture Recognizers

extension GameViewController {
    
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
            if let animation = Models.animations[name] {
                node.addAnimation(animation, forKey: name)
            }
        }
    }
    
}

//MARK: - SCNSceneRendererDelegate

extension GameViewController: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        updateCameraPosition()
        removePassedObstacles()
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

        if let animation = Models.animations[name] {
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
