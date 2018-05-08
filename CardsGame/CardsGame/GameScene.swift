//
//  GameScene.swift
//  CardsGame
//
//  Created by Enti Mobile on 17/4/18.
//  Copyright © 2018 Enti Mobile. All rights reserved.
//

import SpriteKit
import GameKit

class GameScene: SKScene {
    
    let transitionDuration : TimeInterval = 0.1
    
    //Buttons
    var buttonPlay : SKSpriteNode!
    var easyDifficulty : SKSpriteNode!
    var mediumDifficulty : SKSpriteNode!
    var hardDifficulty : SKSpriteNode!
    var gameBack : SKSpriteNode!
    
    var cardsPerRow : Int = 4
    var cardsPerColumn : Int = 5
    let cardSizeX : CGFloat = 80
    let cardSizeY : CGFloat = 120
    
    var difficulty : Int!
    var timer : CFTimeInterval!
    var time : CFTimeInterval!
    
    var cards : [SKSpriteNode] = []
    var cardsBacks : [SKSpriteNode] = []
    var cardsStatus : [Bool] = []
    
    var cardsSequence : [Int] = []
    
    var selectedCardIndex1 : Int = -1
    var selectedCardIndex2 : Int = -1
    var selectedCard1Value : String = ""
    var selectedCard2Value : String = ""
    
    var gameIsPlaying : Bool = false
    var lockInteraction : Bool = false
    
    var matchesCount : Int = 0
    var tryCount : Int = 0
    var score : Int = 0
    
    var scoreLabel : SKLabelNode!
    
    var timeLabel : SKLabelNode!
    
    var DelayPriorToHidingCards : TimeInterval = 1.5
    var lastUpdateTimeInterval: CFTimeInterval?
    
    override func didMove(to view: SKView) {
        SetDifficulty(difficultyId: 1)
        CreateMenu()
        CreateBackGround()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch =  touches.first
        let positionInScene : CGPoint = touch!.location(in: self)
        let touchedNode : SKSpriteNode = self.atPoint(positionInScene) as! SKSpriteNode
        
        self.ProcessItemTouch(nod: touchedNode)
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        var delta: CFTimeInterval = currentTime
        if let luti  = lastUpdateTimeInterval {
            delta = currentTime - luti
        }
        lastUpdateTimeInterval = currentTime
        
        
        if gameIsPlaying {
            timer = timer - delta
            if timer < 0 { timer = 0 }
            timeLabel?.text = "Time: \(Int(timer))"
            UpdateScore()
        }
        
    }
    
    
    func ProcessItemTouch(nod : SKSpriteNode)
    {
        if(gameIsPlaying == false)
        {
            if(nod.name == "Easy")
            {
                SetDifficulty(difficultyId: 0)
                timer = 120
                time = 120
                PlayGame()
            }
            else if(nod.name == "Medium")
            {
                SetDifficulty(difficultyId: 1)
                timer = 210
                time = 210
                PlayGame()
            }
            else if(nod.name == "Hard")
            {
                SetDifficulty(difficultyId: 2)
                timer = 250
                time = 250
                PlayGame()
            }
        }
        else
        {
            // game is playing
            if(nod.name == nil){
                return
            }
            /*if( nod.name == "reset")
            {
                ResetGame()
                return
            }*/
            if(nod.name == "GameBack")
            {
                GoMenu()
            }
            
            let num: Int? = Int(nod.name!)
            if(num != nil) // it is a number
            {
                if(num! > 0)
                {
                    if(lockInteraction == true)
                    {
                        return
                    }
                    else
                    {
                        print("the card with number \(String(describing: num)) was touched")
                        var i : Int = 0
                        for cardBack in cardsBacks {
                            if(cardBack === nod) {
                                // the nod is identical to the cardback at index i
                                let cardNode : SKSpriteNode = cards[i] as SKSpriteNode
                                if(selectedCardIndex1 == -1) {
                                    selectedCardIndex1 = i
                                    selectedCard1Value = cardNode.name!
                                    cardBack.run(SKAction.hide())
                                }
                                else if(selectedCardIndex2 == -1) {
                                    if(i != selectedCardIndex1) {
                                        lockInteraction = true
                                        selectedCardIndex2 = i
                                        selectedCard2Value = cardNode.name!
                                        cardBack.run(SKAction.hide())
                                        
                                        if(selectedCard1Value == selectedCard2Value) {
                                            print("matched cards")
                                            DispatchQueue.main.asyncAfter(deadline: .now() + DelayPriorToHidingCards)
                                            {
                                                self.SetStatusCardFound(cardIndex: self.selectedCardIndex1)
                                                self.SetStatusCardFound(cardIndex: self.selectedCardIndex2)
                                                self.HideSelectedCards()
                                                self.SetMatchesCount(score: self.matchesCount + 1)
                                                if(self.CheckIfGameOver() == true) {
                                                    self.GoMenu()
                                                }
                                            }
                                        } else {
                                            print("unmatched cards")
                                            DispatchQueue.main.asyncAfter(deadline: .now() + DelayPriorToHidingCards / 2)
                                            {
                                                self.ResetSelectedCards()
                                                self.SetTryCount(score: self.tryCount + 1)
                                            }
                                        }
                                    }
                                }
                            }
                            i += 1
                        }
                    }
                }
            }
        }
    }
    
    func CreateCardboard()
    {
        let totalEmptyScapeX : CGFloat = self.size.width - (CGFloat(cardsPerRow)) * cardSizeX
        let offsetX : CGFloat = totalEmptyScapeX / (CGFloat(cardsPerRow + 1))
        
        let totalEmptySpaceY : CGFloat = self.size.height - (CGFloat(cardsPerColumn)) * cardSizeY
        let offsetY : CGFloat = totalEmptySpaceY / ( CGFloat(cardsPerColumn + 1))
        
        cards = []; cardsBacks = []
        
        for i in 0...cardsPerRow - 1
        {
            for j in 0...cardsPerColumn - 1
            {
                let posX : CGFloat = -self.size.width/2 + offsetX + cardSizeX / 2 + CGFloat(i) * (cardSizeX + offsetX)
                let posY : CGFloat = self.size.height/2 - offsetY - cardSizeY / 2 - CGFloat(j) * (cardSizeY + offsetY)
                CreateCard(posX : posX, posY : posY, idx : (i * cardsPerColumn) + j)
            }
        }
    }
    
    func CreateCard(posX : CGFloat, posY : CGFloat, idx : Int)
    {
        let anchorPoint = CGPoint(x : 0.5, y : 0.5)
        let zPosition = CGFloat(9.0)
        
        let cardIndex : Int = cardsSequence[idx]
        let cardName : String = String(format: "Number-%i",cardIndex)
        let card : SKSpriteNode = SKSpriteNode(imageNamed: cardName)
        card.size = CGSize(width: cardSizeX, height:cardSizeY)
        card.anchorPoint = anchorPoint
        
        card.position = CGPoint(x:posX, y:posY)
        card.zPosition = zPosition
        card.name = String(format: "%i", cardIndex)
        addChild(card)
        cards.append(card)
        
        let cardBack : SKSpriteNode = SKSpriteNode(imageNamed: "CardBack")
        cardBack.size = CGSize(width:cardSizeX, height:cardSizeY)
        cardBack.anchorPoint = anchorPoint
        cardBack.zPosition = zPosition + 1
        cardBack.position = CGPoint(x:posX, y:posY)
        cardBack.name = String(format: "%i", cardIndex)
        addChild(cardBack)
        cardsBacks.append(cardBack)
    }
    
    func ShuffleArray<T>( array: inout Array<T>) -> Array<T>
    {
        var index = array.count - 1
        while index > 0 {
            //for var index = array.count - 1; index > 0; index -= 1 {
            // Random int from 0 to index-1
            let j = Int(arc4random_uniform(UInt32(index-1)))
            
            // Swap array elements
            let temp = array[index]
            array[index] = array[j]
            array[j] = temp
            
            index -= 1
        }
        return array
    }
    
    func FillCardSequence()
    {
        cardsSequence.removeAll(keepingCapacity: false)
        
        for i in 1...(cardsPerRow * cardsPerColumn / 2)
        {
            cardsSequence.append(i)
            cardsSequence.append(i)
        }
        
        let newSequence = ShuffleArray(array: &cardsSequence)
        cardsSequence.removeAll(keepingCapacity: false)
        cardsSequence += newSequence
    }
    
    func HideSelectedCards()
    {
        let card1 : SKSpriteNode = cards[selectedCardIndex1] as SKSpriteNode
        let card2 : SKSpriteNode = cards[selectedCardIndex2] as SKSpriteNode
        
        card1.run(SKAction.hide())
        card2.run(SKAction.hide())
        
        DeselectCards()
    }
    
    func DeselectCards()
    {
        selectedCardIndex1 = -1
        selectedCardIndex2 = -1
        lockInteraction = false
    }
    
    func SetStatusCardFound(cardIndex : Int)
    {
        cardsStatus[cardIndex] = true
    }
    
    func ResetCardsStatus()
    {
        cardsStatus.removeAll(keepingCapacity: false)
        for _ in 0...(cardsSequence.count - 1)
        {
            cardsStatus.append(false)
        }
    }
    
    func ResetSelectedCards()
    {
        if(selectedCardIndex1 >= cardsBacks.count || selectedCardIndex2 >= cardsBacks.count || selectedCardIndex1 < 0 || selectedCardIndex2 < 0){
            return
        }
        let card1 : SKSpriteNode = cardsBacks[selectedCardIndex1] as SKSpriteNode
        let card2 : SKSpriteNode = cardsBacks[selectedCardIndex2] as SKSpriteNode
        
        card1.run(SKAction.unhide())
        card2.run(SKAction.unhide())
        
        DeselectCards()
    }
    
    func CheckIfGameOver() -> Bool
    {
        var gameOver : Bool = true
        for i : Int in 0...(cardsStatus.count - 1)
        {
            if(cardsStatus[i] as Bool == false)
            {
                gameOver = false
                break
            }
        }
        return gameOver
    }
    
    func PlayGame()
    {
        ResetGame()
        GoGame()
    }
    
    func SetDifficulty(difficultyId : Int)
    {
        difficulty = difficultyId
        
        if(difficulty == 0)
        {
            cardsPerColumn = 4
            cardsPerRow = 3
        }
        else if(difficulty == 1)
        {
            cardsPerColumn = 4
            cardsPerRow = 4
        }
        else if(difficulty == 2)
        {
            cardsPerColumn = 5
            cardsPerRow = 4
        }
    }
    
    func ResetGame()
    {
        CreateGameButtons()
        
        RemoveAllCards()
        FillCardSequence()
        CreateCardboard()
        ResetCardsStatus()
        ResetStats()
    }
    
    func ResetStats()
    {
        SetTryCount(score : 0)
        SetMatchesCount(score: 0)
        timer = time
    }
    
    func SetTryCount(score : Int!)
    {
        tryCount = score
        UpdateScore()
    }
    
    func SetMatchesCount(score : Int!)
    {
        matchesCount = score
        UpdateScore()
    }
    
    func UpdateScore()
    {
        
        score = matchesCount * (difficulty + 1) * 5 - tryCount + Int(timer)
        scoreLabel?.text = "Score: \(score)"
    }
    
    func RemoveAllCards()
    {
        for card in cards
        {
            card.removeFromParent()
        }
        
        for card in cardsBacks
        {
            card.removeFromParent()
        }
        
        cards.removeAll(keepingCapacity: false)
        cardsBacks.removeAll(keepingCapacity: false)
        cardsStatus.removeAll(keepingCapacity: false)
        cardsSequence.removeAll(keepingCapacity: false)
        
        selectedCard1Value = ""
        selectedCard2Value = ""
        selectedCardIndex1 = -1
        selectedCardIndex2 = -1
    }
    //Scene management
    
    func CreateBackGround()
    {
        let background = SKSpriteNode(imageNamed: "Background")
        background.anchorPoint = CGPoint(x:0.5, y:0.5)
        background.position = CGPoint(x:0, y:0)
        background.zPosition = 0
        background.size = CGSize(width: self.view!.bounds.size.width * 2, height: self.view!.bounds.size.height * 2)
        addChild(background)
    }
    
    func CreateMenu()
    {
        buttonPlay = SKSpriteNode(imageNamed: "title")
        buttonPlay.position = CGPoint(x:0, y:100)
        buttonPlay.zPosition = 10
        buttonPlay.name = "title"
        addChild(buttonPlay)
        
        easyDifficulty = SKSpriteNode(imageNamed : "easy")
        easyDifficulty.zPosition = 10
        easyDifficulty.position = CGPoint(x : -200, y : -50)
        easyDifficulty.name = "Easy"
        addChild(easyDifficulty)
        
        mediumDifficulty = SKSpriteNode(imageNamed : "normal")
        mediumDifficulty.zPosition = 10
        mediumDifficulty.position = CGPoint(x : 0, y : -50)
        mediumDifficulty.name = "Medium"
        addChild(mediumDifficulty)
        
        hardDifficulty = SKSpriteNode(imageNamed : "hard")
        hardDifficulty.zPosition = 10
        hardDifficulty.position = CGPoint(x : 200, y : -50)
        hardDifficulty.name = "Hard"
        addChild(hardDifficulty)
    }
    
    func CreateGameButtons()
    {
        gameBack = SKSpriteNode(imageNamed: "back")
        gameBack.position = CGPoint(x: -self.view!.bounds.size.width + 125, y: -self.view!.bounds.size.height + 120)
        gameBack.anchorPoint = CGPoint(x : 0.5, y : 0.5)
        gameBack.size = CGSize(width: gameBack.size.width, height: gameBack.size.height / 2)
        gameBack.zPosition = 10
        gameBack.name = "GameBack"
        addChild(gameBack)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x : self.view!.bounds.size.width - 175, y : self.view!.bounds.size.height - 150)
        scoreLabel.text = "hello"
        scoreLabel.fontSize = 32
        scoreLabel.color = SKColor.white
        scoreLabel.zPosition = 10
        addChild(scoreLabel)
        
        timeLabel = SKLabelNode(fontNamed: "Chalkduster")
        timeLabel.position = CGPoint(x : -self.view!.bounds.size.width + 175, y : self.view!.bounds.size.height - 150)
        timeLabel.text = "hello"
        timeLabel.fontSize = 32
        timeLabel.color = SKColor.white
        timeLabel.zPosition = 10
        addChild(timeLabel)
    }
    
    func GoMenu()
    {
        gameIsPlaying = false
        
        ToggleGame(b: false)
        ToggleMenu(b: true)
    }
    
    func GoGame()
    {
        gameIsPlaying = true
        
        ToggleMenu(b: false)
        ToggleGame(b: true)
    }
    
    func ToggleMenu(b : Bool)
    {
        let value = BoolToCGFloat(b: b)
        
        buttonPlay.run(SKAction.fadeAlpha(to: value, duration: transitionDuration))
        easyDifficulty.run(SKAction.fadeAlpha(to: value, duration: transitionDuration))
        mediumDifficulty.run(SKAction.fadeAlpha(to: value, duration: transitionDuration))
        hardDifficulty.run(SKAction.fadeAlpha(to: value, duration: transitionDuration))
    }
    
    func ToggleGame(b : Bool)
    {
        let value = BoolToCGFloat(b: b)
        
        if(!b)
        {
            RemoveAllCards()
        }
        
        scoreLabel.run(SKAction.fadeAlpha(to: value, duration: transitionDuration))
        gameBack.run(SKAction.fadeAlpha(to: value, duration: transitionDuration))
        timeLabel.run(SKAction.fadeAlpha(to: value, duration: transitionDuration))
    }
    
    func BoolToCGFloat(b : Bool) -> CGFloat
    {
        if(b)
        {
            return CGFloat(1)
        }
        else
        {
            return CGFloat(0)
        }
    }
    
}
