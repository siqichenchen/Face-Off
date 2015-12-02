//
//  ScrollNode.swift
//  Faceoff
//
//  Created by Huaying Tsai on 9/27/15.
//  Copyright © 2015 huaying. All rights reserved.
//

import SpriteKit

class ScrollNode: SKNode{
    
    let coefficientOfSliding = 0.05
    let coefficientOfTransition = 0.3
    
    let yPadding: CGFloat = 40
    
    var maxYPosition: CGFloat {
        get {
            if let sizeHeight = self.parent?.frame.size.height {
                return yPadding - sizeHeight/2
            }
            return 0
        }
    }
    var minYPosition: CGFloat {
        get {
            if let sizeHeight = self.parent?.frame.size.height {
                return sizeHeight/2 - self.calculateAccumulatedFrame().size.height - yOffset - yPadding
            }
            return 0
        }
    }
    var yOffset: CGFloat = 0
    var recognizer:UIPanGestureRecognizer?
    var view: SKView?
    
    
    override init(){
        super.init()
        self.zPosition = 5
    }
    
    override func addChild(node: SKNode) {
        super.addChild(node)
        self.position.y = 0
        yOffset = self.calculateAccumulatedFrame().origin.y
        self.scrollToTop()
    }
    
    func scrollToBottom(){
        self.position = CGPoint(x: position.x,y: self.maxYPosition)
    }
    func scrollToTop(){
        self.position = CGPoint(x: position.x,y: self.minYPosition)
        
    }
    
    func setScrollingView(view: SKView){
        
        recognizer = UIPanGestureRecognizer(target: self, action:Selector("handlePan:"))
        self.view = view
        view.addGestureRecognizer(recognizer!)
        
    }
    
    func handlePan(regcognizer: UIPanGestureRecognizer){
        if regcognizer.state == UIGestureRecognizerState.Changed{
            let translation = regcognizer.translationInView(regcognizer.view)
            panForTranslation(translation)
            regcognizer.setTranslation(CGPointZero, inView:regcognizer.view)
        }
        if regcognizer.state == UIGestureRecognizerState.Ended{
            let velocity = regcognizer.velocityInView(regcognizer.view)
            let distanceOfSliding = velocity.y * CGFloat(coefficientOfSliding)
            
            var newYPosition = self.position.y-distanceOfSliding
            newYPosition = max(min(newYPosition,self.maxYPosition),self.minYPosition)
            
            let moveTo = SKAction.moveTo(CGPoint(x:self.position.x,y: newYPosition), duration: coefficientOfTransition)
            moveTo.timingMode = SKActionTimingMode.EaseInEaseOut
            self.runAction(moveTo)
        }
        
    }
    func panForTranslation(translation:CGPoint){
        self.position = CGPoint(x:position.x,y: position.y-translation.y)
    }
    
    deinit{
        self.view!.removeGestureRecognizer(recognizer!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
