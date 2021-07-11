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
    }
    
    func setupScene() {
        sceneView = (view as! SCNView)
        sceneView.delegate = self
        
        scene = SCNScene()
        sceneView.scene = scene
        
        sceneView.backgroundColor = UIColor(red: 255/255, green: 210/255, blue: 138/255, alpha: 1)
        sceneView.showsStatistics = true
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
        directionalLightNode.light?.maximumShadowDistance = 20.0
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
        let runningScene = SCNScene(named: "art.scnassets/maria/run.dae")!
        for child in runningScene.rootNode.childNodes {
            playerNode.addChildNode(child)
        }
        playerNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        playerNode.eulerAngles = SCNVector3(x: 0, y: convertToRadians(degrees: 180), z: 0)
        let runningAction = SCNAction.repeatForever(SCNAction.moveBy(x: 0, y: 0, z: -3.5, duration: 1.0))
        playerNode.runAction(runningAction)
        sceneView.scene?.rootNode.addChildNode(playerNode)
    }
    
    func loadAnimations() {
        loadAnimation(from: "attack", fadeInDuration: 0.1, fadeOutDuration: 1.15)
        loadAnimation(from: "slide", fadeInDuration: 0.1, fadeOutDuration: 0.2)
        loadAnimation(from: "jump", fadeInDuration: 0.02, fadeOutDuration: 0.02)
        loadAnimation(from: "left", fadeInDuration: 0.1, fadeOutDuration: 0.1)
        loadAnimation(from: "right", fadeInDuration: 0.1, fadeOutDuration: 0.1)
        loadAnimation(from: "roll", fadeInDuration: 0.1, fadeOutDuration: 0.1)
    }
    
    func loadAnimation(from name: String, fadeInDuration: CGFloat, fadeOutDuration: CGFloat) {
        let sceneURL = Bundle.main.url(forResource: "art.scnassets/maria/" + name, withExtension: "dae")
        let sceneSource = SCNSceneSource(url: sceneURL!, options: nil)
        if let animationObject = sceneSource?.entryWithIdentifier(name + "-1", withClass: CAAnimation.self) {
            animationObject.repeatCount = 1
            animationObject.fadeInDuration = fadeInDuration
            animationObject.fadeOutDuration = fadeOutDuration
            animationObject.isRemovedOnCompletion = true
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
                runAnimation(named: "jump")
            case .down:
                runAnimation(named: "slide")
            case .right:
                runAnimation(named: "right")
            case .left:
                runAnimation(named: "left")
            default:
                break
        }
    }
    
    @objc func handleTapGesture(_ sender: UISwipeGestureRecognizer) {
        runAnimation(named: "attack")
    }
    
    func runAnimation(named name: String) {
        if !playerNode.animationKeys.contains(name) {
            playerNode.addAnimation(animations[name]!, forKey: name)
        }
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
