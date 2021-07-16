//
//  HUD.swift
//  Switcher4
//
//  Created by Robert Pelka on 16/07/2021.
//

import SpriteKit

class HUD: SKScene {
    
    let gameScore = SKLabelNode(fontNamed: "CormorantInfant-Light")
    var isGameEnded = false
    
    init(withSize sceneViewSize: CGSize, isMenu: Bool, isGameEnded: Bool) {
        super.init(size: sceneViewSize)
        self.isGameEnded = isGameEnded
        
        if isMenu {
            addBackground()
            addLogo()
            addScores()
            addButton()
        }
        else {
            setGameScore()
        }
    }
    
    func addBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.scaleToWidth(of: frame.size)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(background)
    }
    
    func addLogo() {
        let logo = SKSpriteNode(imageNamed: "logo")
        logo.scaleToWidth(of: frame.size, multiplier: 1.35)
        logo.position = CGPoint(x: frame.midX, y: frame.maxY*0.8)
        addChild(logo)
    }
    
    func addScores() {
        let gradientName = isGameEnded ? "gradientHigher" : "gradient"
        let gradient = SKSpriteNode(imageNamed: gradientName)
        gradient.scaleToWidth(of: frame.size)
        gradient.position = CGPoint(x: frame.midX, y: gradient.frame.size.height/2)
        addChild(gradient)
        
        let bestScore = SKLabelNode(fontNamed: "CormorantInfant-Light")
        bestScore.text = "Best Score: \(UserDefaults.standard.integer(forKey: "bestScore"))"
        bestScore.fontSize = 36
        bestScore.fontColor = UIColor.init(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
        bestScore.position = CGPoint(x: frame.midX, y: frame.maxY*0.07)
        addChild(bestScore)
        
        if isGameEnded {
            gameScore.fontSize = 48
            gameScore.fontColor = UIColor.init(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
            gameScore.position = CGPoint(x: frame.midX, y: frame.maxY*0.14)
            addChild(gameScore)
        }
    }
    
    func addButton() {
        let button = SKSpriteNode(imageNamed: "playButton")
        if isGameEnded {
            button.position = CGPoint(x: frame.midX, y: frame.maxY*0.21 + button.frame.size.height/2)
        }
        else {
            button.position = CGPoint(x: frame.midX, y: frame.maxY*0.14 + button.frame.size.height/2)
        }
        addChild(button)
    }
    
    func setGameScore() {
        gameScore.text = "0"
        gameScore.fontSize = 48
        gameScore.position = CGPoint(x: frame.midX, y: frame.maxY*0.9)
        addChild(gameScore)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension SKNode {

    func scaleToWidth(of size: CGSize, multiplier: CGFloat = 1.0) {
        let scale = size.width / self.frame.size.width * multiplier
        self.setScale(scale)
    }
    
}
