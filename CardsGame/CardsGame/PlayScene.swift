//
//  PlayScene.swift
//  CardsGame
//
//  Created by victor on 16/05/2018.
//  Copyright © 2018 Enti Mobile. All rights reserved.
//

import SpriteKit
import GameKit
import AVFoundation
import CoreMotion

class PlayScene: SKScene {
    
    var motionManager = CMMotionManager()
    let motionQueue = OperationQueue()
    var returnScene: SKScene?
    var difficulty: Int!
    
    var cardsPerRow : Int = 4
    var cardsPerColumn : Int = 5
    let cardSizeX : CGFloat = 80
    let cardSizeY : CGFloat = 120
    
    var timer : CFTimeInterval!
    var time : CFTimeInterval!
    var gyroTimer : Timer!
    
    var pauseLayer : SKSpriteNode!
    var pauseImg : SKSpriteNode!
    var pauseState : Bool = false
    var pauseTimer : TimeInterval!
    var scoreLabel : SKLabelNode!
    
    var cards : [SKSpriteNode] = []
    var cardsBacks : [SKSpriteNode] = []
    var cardsStatus : [Bool] = []
    
    var cardsSequence : [Int] = []
    
    var selectedCardIndex1 : Int = -1
    var selectedCardIndex2 : Int = -1
    var selectedCard1Value : String = ""
    var selectedCard2Value : String = ""
    
    var lockInteraction : Bool = false
    
    var matchesCount : Int = 0
    var tryCount : Int = 0
    var score : Int = 0
    
    var f : SKLabelNode!
    
    var timeLabel : SKLabelNode!
    
    var DelayPriorToHidingCards : TimeInterval = 1.5
    var lastUpdateTimeInterval: CFTimeInterval? = 0
    
    var gameBack : SKSpriteNode!
    var firstFrame = true
    var lastZ = 0.0
    
    override func didMove(to view: SKView) {
        
        SetDifficulty(difficultyId: difficulty)
        CreateGameButtons()
        RemoveAllCards()
        FillCardSequence()
        CreateCardboard()
        ResetCardsStatus()
        
        if motionManager.isAccelerometerAvailable{
            motionManager.accelerometerUpdateInterval=0.1; //Intervalo actualización
            motionManager.startAccelerometerUpdates(to: motionQueue, withHandler:
                {[weak self](data: CMAccelerometerData?,error: Error?) in //[weak self] self dentro del contexto es un optional
                    if let data=data{
                        self?.physicsWorld.gravity=CGVector(dx:
                            data.acceleration.x, dy:
                            data.acceleration.y);
                        
                        if((self?.lastZ)! < 0.5 && data.acceleration.x > 0.5){
                            self?.GoMenu()
                        }
                        
                        self?.lastZ = data.acceleration.x
                        //print("x: \(data.acceleration.x), y: \(data.acceleration.y), z: \(data.acceleration.z)");
                    }
            })
        }
        pauseTimer = Date().timeIntervalSinceReferenceDate
        startGyros()
 
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        var delta: CFTimeInterval = currentTime
        if let luti  = lastUpdateTimeInterval {
            delta = currentTime - luti
        }
        lastUpdateTimeInterval = currentTime
        
        
        if(!firstFrame){
            if(!pauseState){
                timer = timer - delta
                if timer < 0 { timer = 0 }
                timeLabel?.text = "Time: \(Int(timer))"
                UpdateScore()
            }
        }
        firstFrame = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch =  touches.first
        let positionInScene : CGPoint = touch!.location(in: self)
        let touchedNode : SKSpriteNode = self.atPoint(positionInScene) as! SKSpriteNode
        
        self.ProcessItemTouch(nod: touchedNode)
    }
    
    
    func ProcessItemTouch(nod : SKSpriteNode)
    {
        if(pauseState)
        {
            return
        }
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
                                                self.UpdateRanking()
                                                self.GoLeaderBoard()
                                                //self.GoMenu()
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
    
    func UpdateRanking()
    {
        if(UserDefaults.standard.integer(forKey: "rankingFirst") < score){
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "rankingSecond"), forKey: "rankingThird")
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "rankingFirst"), forKey: "rankingSecond")
            UserDefaults.standard.set(score, forKey: "rankingFirst")
        }
        else if(UserDefaults.standard.integer(forKey: "rankingSecond") < score){
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "rankingSecond"), forKey: "rankingThird")
            UserDefaults.standard.set(score, forKey: "rankingSecond")
        }
        else if(UserDefaults.standard.integer(forKey: "rankingThird") < score){
                UserDefaults.standard.set(score, forKey: "rankingThird")
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
                let posX : CGFloat = /*-self.size.width/2 + */offsetX + cardSizeX / 2 + CGFloat(i) * (cardSizeX + offsetX)
                let posY : CGFloat = /*self.size.height/2 - */offsetY + cardSizeY / 2 + CGFloat(j) * (cardSizeY + offsetY)
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
    
    func SetDifficulty(difficultyId : Int)
    {
        difficulty = difficultyId
        
        if(difficulty == 0)
        {
            timer = 120
            time = 120
            cardsPerColumn = 4
            cardsPerRow = 3
        }
        else if(difficulty == 1)
        {
            timer = 210
            time = 210
            cardsPerColumn = 4
            cardsPerRow = 4
        }
        else if(difficulty == 2)
        {
            timer = 250
            time = 250
            cardsPerColumn = 5
            cardsPerRow = 4
        }
    }
    
    func TogglePause()
    {
        if(pauseTimer + 0.5 < Date.timeIntervalSinceReferenceDate)
        {
            pauseState = !pauseState
            pauseTimer = Date.timeIntervalSinceReferenceDate
            
            print("pauseFunc: \(pauseState)")
            
            if(pauseState)
            {
                pauseLayer.run(SKAction.unhide())
                pauseImg.run(SKAction.unhide())
            }
            else
            {
                pauseLayer.run(SKAction.hide())
                pauseImg.run(SKAction.hide())
            }
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
    
    
    func GoMenu(){
        /*if let view = self.view, let returnScene = returnScene {
            view.presentScene(returnScene, transition: .flipVertical(withDuration: 0.2))
        }*/
        if let view = self.view {
            let scene = GameScene(size: view.frame.size.applying(CGAffineTransform(scaleX: 2, y: 2)))
            //scene.returnScene = self
            
            scene.scaleMode = .aspectFill
            view.presentScene(scene, transition: .flipHorizontal(withDuration: 0.2))
        }
    }
    
    func UpdateScore()
    {
        score = matchesCount * (difficulty + 1) * 5
        score = score - tryCount + Int(timer)
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
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = CGSize(width: self.view!.bounds.size.width * 2, height: self.view!.bounds.size.height * 2)
        background.name = "Background"
        addChild(background)
    }
    
    func CreateGameButtons()
    {
        CreateBackGround()
        
        gameBack = SKSpriteNode(imageNamed: "back")
        gameBack.anchorPoint = CGPoint(x : 0.5, y : 0.5)
        gameBack.size = CGSize(width: gameBack.size.width * 0.75, height: gameBack.size.height / 2)
        gameBack.position = CGPoint(x: gameBack.size.width/2, y: 45)
        gameBack.zPosition = 10
        gameBack.name = "GameBack"
        addChild(gameBack)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x : size.width/2 - 150 , y : size.height - 40)
        scoreLabel.text = "hello"
        scoreLabel.fontSize = 32
        scoreLabel.color = SKColor.white
        scoreLabel.zPosition = 10
        addChild(scoreLabel)
 
        timeLabel = SKLabelNode(fontNamed: "Chalkduster")
        timeLabel.position = CGPoint(x : size.width - 150 , y : size.height - 40)
        timeLabel.text = "hello"
        timeLabel.fontSize = 32
        timeLabel.color = SKColor.white
        timeLabel.zPosition = 10
        addChild(timeLabel)
        
        pauseLayer = SKSpriteNode(imageNamed: "Background")
        pauseLayer.position = CGPoint(x: size.width / 2, y: size.height / 2)
        pauseLayer.zPosition = 100
        pauseLayer.size = CGSize(width: self.view!.bounds.size.width * 2, height: self.view!.bounds.size.height * 2)
        pauseLayer.name = "pauseLayer"
        pauseLayer.run(SKAction.hide())
        addChild(pauseLayer)
        
        pauseImg = SKSpriteNode(imageNamed: "pause")
        pauseImg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        pauseImg.zPosition = 100
        pauseImg.size = CGSize(width: self.view!.bounds.size.width, height: self.view!.bounds.size.height)
        pauseImg.name = "pauseImg"
        pauseImg.run(SKAction.hide())
        addChild(pauseImg)
    }
    
    func startGyros() {
        if motionManager.isGyroAvailable {
            self.motionManager.gyroUpdateInterval = 1.0 / 60.0
            self.motionManager.startGyroUpdates()
            
            // Configure a timer to fetch the accelerometer data.
            self.gyroTimer = Timer(fire: Date(), interval: (1.0/60.0),
                               repeats: true, block: { (timer) in
                                // Get the gyro data.
                                if let data = self.motionManager.gyroData {
                                    let x = data.rotationRate.x
                                    //let y = data.rotationRate.y
                                    //let z = data.rotationRate.z
                                    if(x > 5){
                                        self.TogglePause()
                                    }
                                    // Use the gyroscope data in your app.
                                }
            })
            
            // Add the timer to the current run loop.
            RunLoop.current.add(self.gyroTimer!, forMode: .defaultRunLoopMode)
        }
    }
    
    func stopGyros() {
        if self.gyroTimer != nil {
            self.gyroTimer?.invalidate()
            self.gyroTimer = nil
            
            self.motionManager.stopGyroUpdates()
        }
    }
    
    func GoLeaderBoard(){
        if let view = self.view {
            let scene = LeaderboardsScene(size: view.frame.size.applying(CGAffineTransform(scaleX: 2, y: 2)))
            //scene.returnScene = self
            
            scene.scaleMode = .aspectFill
            view.presentScene(scene, transition: .flipHorizontal(withDuration: 0.2))
        }
    }
}
