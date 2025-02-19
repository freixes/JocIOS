/*
 Copyright (C) 2018 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A basic `SKNode` based slider.
 */

import SpriteKit

protocol SliderDelegate: class {
    func sliderValueChanged(sender: Slider, value: CGFloat)
}

class Slider: SKNode {
    
    weak var sliderDelegate: SliderDelegate?
    
    var value: CGFloat = 0.0 {
        didSet {
            slider!.position = CGPoint(x: CGFloat(background!.position.x + value * width ), y: CGFloat(0.0))
        }
    }
    
    var label: SKLabelNode?
    var slider: SKShapeNode?
    var background: SKSpriteNode?
    
    init(width: Int, height: Int, text txt: String) {
        super.init()
        
        // create a label
        let fontName: String = "Optima-ExtraBlack"
        label = SKLabelNode(fontNamed: fontName)
        label!.text = txt
        label!.fontSize = 18
        label!.fontColor = SKColor.white
        label!.position = CGPoint(x: 0.0, y: -8.0)
        
        // create background & slider
        background = SKSpriteNode(color: SKColor.white, size: CGSize(width: CGFloat(width), height: CGFloat(2)))
        slider = SKShapeNode(circleOfRadius: CGFloat( height ) )
        slider!.fillColor = SKColor.white
        background!.anchorPoint = CGPoint(x: CGFloat(0.0), y: CGFloat(0.5))
        
        slider!.position = CGPoint(x: CGFloat(label!.frame.size.width / 2.0 + 15), y: CGFloat(0.0))
        background!.position = CGPoint(x: CGFloat(label!.frame.size.width / 2.0 + 15), y: CGFloat(0.0))
        
        // add to the root node
        addChild(label!)
        addChild(background!)
        addChild(slider!)
        
        // track mouse event
        isUserInteractionEnabled = true
        value = 0.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var width: CGFloat {
        return background!.frame.size.width
    }
    
    var height: CGFloat {
        return slider!.frame.size.height
    }
    
    func setBackgroundColor(_ col: SKColor) {
        background!.color = col
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        setBackgroundColor(SKColor.gray)
        let x = touches.first!.location(in: self).x - background!.position.x
        let pos = max(fmin(x, width), 0.0)
        
        slider!.position = CGPoint(x: CGFloat(background!.position.x + pos), y: CGFloat(0.0))
        value = pos / width
        if let sliderDelegate = sliderDelegate {
            sliderDelegate.sliderValueChanged(sender: self, value: value)
        }
    }
}
