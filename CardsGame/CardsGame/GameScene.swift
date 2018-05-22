//
//  GameScene.swift
//  CardsGame
//
//  Created by Enti Mobile on 17/4/18.
//  Copyright © 2018 Enti Mobile. All rights reserved.
//  193755 pw iphone enti

import SpriteKit
import GameKit
import Firebase
import UserNotifications
import AVFoundation

class GameScene: SKScene {
    
//    let slider = UISlider(frame:CGRect(x: 50, y: 500, width: 300, height: 20))
    let slider = Slider(width: 300, height: 20, text: NSLocalizedString("Volumen", comment: ""))

    var player: AVAudioPlayer?
    let transitionDuration : TimeInterval = 0.1
    
    
    
    //Buttons
    var buttonPlay : SKSpriteNode!
    var easyDifficulty : SKSpriteNode!
    var mediumDifficulty : SKSpriteNode!
    var hardDifficulty : SKSpriteNode!
    var buttonOptions : SKSpriteNode!
    
    
    var difficulty : Int!
    
    var volume : Float = 0.5

    
    override func didMove(to view: SKView) {
        CreateMenu()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch =  touches.first
        let positionInScene : CGPoint = touch!.location(in: self)
        let touchedNode : SKSpriteNode = self.atPoint(positionInScene) as! SKSpriteNode
        
        self.ProcessItemTouch(nod: touchedNode)
    }
    
    
    
    func ProcessItemTouch(nod : SKSpriteNode)
    {
           if(nod.name == "Easy")
            {
                difficulty = 0
                PlayGame()
            }
            else if(nod.name == "Medium")
            {
                difficulty = 1
                PlayGame()
            }
            else if(nod.name == "Hard")
            {
                difficulty = 2
                PlayGame()
            }
            else if(nod.name == "Options"){
                GoOptions()
            }
    }
    
    func PlayGame()
    {
        
        if let view = self.view {
            let scene = PlayScene(size: view.frame.size.applying(CGAffineTransform(scaleX: 2, y: 2)))
            scene.returnScene = self
            scene.difficulty = difficulty
            scene.scaleMode = .aspectFill
            view.presentScene(scene, transition: .flipHorizontal(withDuration: 0.2))
        }
    }

    func CreateBackGround()
    {
        let background = SKSpriteNode(imageNamed: "Background")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = CGSize(width: self.view!.bounds.size.width * 2, height: self.view!.bounds.size.height * 2)
        addChild(background)
    }
    
    func CreateMenu()
    {
        CreateBackGround()
        
        buttonPlay = SKSpriteNode(imageNamed: "title")
        buttonPlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        buttonPlay.zPosition = 10
        buttonPlay.name = "title"
        addChild(buttonPlay)
        
        easyDifficulty = SKSpriteNode(imageNamed : "easy")
        easyDifficulty.zPosition = 10
        easyDifficulty.position = CGPoint(x: (size.width / 2) - 200, y: (size.height / 2) - 75)
        easyDifficulty.name = "Easy"
        addChild(easyDifficulty)
        
        mediumDifficulty = SKSpriteNode(imageNamed : "normal")
        mediumDifficulty.zPosition = 10
        mediumDifficulty.position = CGPoint(x: (size.width / 2), y: (size.height / 2) - 75)
        mediumDifficulty.name = "Medium"
        addChild(mediumDifficulty)
        
        hardDifficulty = SKSpriteNode(imageNamed : "hard")
        hardDifficulty.zPosition = 10
        hardDifficulty.position = CGPoint(x: (size.width / 2) + 200, y: (size.height / 2) - 75)
        hardDifficulty.name = "Hard"
        addChild(hardDifficulty)
        
        buttonOptions = SKSpriteNode(imageNamed : "normal")
        buttonOptions.zPosition = 10
        buttonOptions.position = CGPoint(x: (size.width / 2), y: (size.height / 2) - 150)
        buttonOptions.name = "Options"
        addChild(buttonOptions)
        
        
        
        do{
            if let url = Bundle.main.url(forResource: "audioTest", withExtension: "mp3"){
                player = try AVAudioPlayer(contentsOf: url) //allo que pot tirar un error es marca amb el try
                volume = UserDefaults.standard.float(forKey: "MUSIC_VOLUME") //si no pot el primer posa el segon
            }
        }catch{
            print(error) //error es una variable implicita el el catch
        }
        
        player?.volume = volume
        player?.play()
    }
    
    
    func GoOptions(){
        if let view = self.view {
            let scene = OptionsScene(size: view.frame.size.applying(CGAffineTransform(scaleX: 2, y: 2)))
            scene.returnScene = self
            scene.slider.value = CGFloat( UserDefaults.standard.float(forKey: "MUSIC_VOLUME"))
            scene.scaleMode = .aspectFill
            view.presentScene(scene, transition: .flipHorizontal(withDuration: 0.2))
        }
    }
    
    
    
}
