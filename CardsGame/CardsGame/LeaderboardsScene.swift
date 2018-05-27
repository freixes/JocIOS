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
    
    
    var rankTitle : SKLabelNode!
    var rank1 : SKLabelNode!
    var rank2 : SKLabelNode!
    var rank3 : SKLabelNode!
    
    let slider = Slider(width: 300, height: 20, text: NSLocalizedString("Volumen", comment: ""))
    var gameBack : SKSpriteNode!
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "Background")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = CGSize(width: self.view!.bounds.size.width * 2, height: self.view!.bounds.size.height * 2)
        addChild(background)
        
        rankTitle = SKLabelNode(fontNamed: "Chalkduster")
        rankTitle.position = CGPoint(x : size.width/2 , y : size.height/2 + 250)
        rankTitle.text = "Ranking"
        rankTitle.fontSize = 32
        rankTitle.color = SKColor.white
        rankTitle.zPosition = 10
        addChild(rankTitle)
        
        rank1 = SKLabelNode(fontNamed: "Chalkduster")
        rank1.position = CGPoint(x : size.width/2 , y : size.height/2 + 200)
        rank1.text = "\(UserDefaults.standard.integer(forKey: "rankingFirst"))"
        rank1.fontSize = 32
        rank1.color = SKColor.white
        rank1.zPosition = 10
        addChild(rank1)
        
        rank2 = SKLabelNode(fontNamed: "Chalkduster")
        rank2.position = CGPoint(x : size.width/2 , y : size.height/2 + 150)
        rank2.text = "\(UserDefaults.standard.integer(forKey: "rankingSecond"))"
        rank2.fontSize = 32
        rank2.color = SKColor.white
        rank2.zPosition = 10
        addChild(rank2)
        
        rank3 = SKLabelNode(fontNamed: "Chalkduster")
        rank3.position = CGPoint(x : size.width/2 , y : size.height/2 + 100)
        rank3.text = "\(UserDefaults.standard.integer(forKey: "rankingThird"))"
        rank3.fontSize = 32
        rank3.color = SKColor.white
        rank3.zPosition = 10
        addChild(rank3)
        
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
