//
//  OptionsScene.swift
//  CardsGame
//
//  Created by Enti Mobile on 15/5/18.
//  Copyright © 2018 Enti Mobile. All rights reserved.
//

import SpriteKit
import GameKit
import AVFoundation

class OptionsScene: SKScene, SliderDelegate {
    
    var returnScene: SKScene?
    
    let slider = Slider(width: 300, height: 20, text: NSLocalizedString("Volumen", comment: ""))
    var gameBack : SKSpriteNode!
    
    override func didMove(to view: SKView) {
        slider.position = position
        slider.sliderDelegate = self
        addChild(slider)
        
        gameBack = SKSpriteNode(imageNamed: "back")
        gameBack.position = CGPoint(x: (size.width / 2) + 200, y: (size.height / 2) - 75)
        gameBack.anchorPoint = CGPoint(x : 0.5, y : 0.5)
        gameBack.size = CGSize(width: gameBack.size.width, height: gameBack.size.height / 2)
        gameBack.zPosition = 10
        gameBack.name = "GameBack"
        addChild(gameBack)
        
    }
    
    
    func sliderValueChanged(sender: Slider, value: CGFloat) {
        
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
