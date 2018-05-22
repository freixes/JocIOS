//
//  LeaderboardsScene.swift
//  CardsGame
//
//  Created by Enti Mobile on 15/5/18.
//  Copyright © 2018 Enti Mobile. All rights reserved.
//

import SpriteKit
import GameKit
import Firebase
import AVFoundation

class LeaderboardsScene: SKScene {
    
    var returnScene: SKScene?
    
    let slider = Slider(width: 300, height: 20, text: NSLocalizedString("Volumen", comment: ""))
    var gameBack : SKSpriteNode!
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "Background")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = CGSize(width: self.view!.bounds.size.width * 2, height: self.view!.bounds.size.height * 2)
        addChild(background)
        
        gameBack = SKSpriteNode(imageNamed: "back")
        gameBack.position = CGPoint(x: (size.width / 2) - 300, y: 75)
        gameBack.anchorPoint = CGPoint(x : 0.5, y : 0.5)
        gameBack.size = CGSize(width: gameBack.size.width, height: gameBack.size.height / 2)
        gameBack.position = CGPoint(x: gameBack.size.width/2, y: 75)
        gameBack.zPosition = 10
        gameBack.name = "GameBack"
        addChild(gameBack)
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch =  touches.first
        let positionInScene : CGPoint = touch!.location(in: self)
        let touchedNode : SKSpriteNode = self.atPoint(positionInScene) as! SKSpriteNode
        
        self.ProcessItemTouch(nod: touchedNode)
    }
    
    
    func ProcessItemTouch(nod : SKSpriteNode)
    {
        if(nod.name == "GameBack")
        {
            GoMenu()
        }
    }
    
    func GoMenu(){
        if let view = self.view, let returnScene = returnScene {
            view.presentScene(returnScene, transition: .flipVertical(withDuration: 0.2))
        }
    }
}
