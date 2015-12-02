//
//  HPManager.swift
//  Faceoff
//
//  Created by Huaying Tsai on 11/17/15.
//  Copyright © 2015 Liang. All rights reserved.
//

import Foundation
import SpriteKit

class PowerManger {
    let maxOfPower:CGFloat = 100
    let minOfPower:CGFloat = 0
    
    let barWidth:CGFloat = 5
    
    
    var barContainer: SKNode?
    var barBack: SKSpriteNode?
    var bar: SKSpriteNode?
    
    var view: SKView?
    var gameScene :GameScene2?
    
    var slefStatusNode: SKSpriteNode?
    var enemyStatusNode: SKSpriteNode?
    var statusNode: SKSpriteNode?
    
    var position:CGPoint? {
        set {
            barContainer!.position = newValue!
        }
        get {
            return barContainer!.position
        }
    }
    var powerValue:CGFloat = 0 {
        didSet {
            powerValueReactedToBar()
            
        }
    }

    init(view: SKView){
        self.view = view
    }
    
    func load(node: SKNode,positionX: CGFloat? = nil){
        gameScene = node as? GameScene2
        powerValue = maxOfPower
        makeBar(positionX)
        show(node)
    }
    
    func load(scene: SKNode,enemy: Bool = false){
        gameScene = scene as? GameScene2
        makePanel(enemy)
        powerValue = maxOfPower
    }
    
    func increase(increasedValue: CGFloat){
        let value = powerValue + increasedValue
        powerValue = min(value,maxOfPower)
        
    }
    
    func decrease(decreasedValue: CGFloat){
        let value = powerValue - decreasedValue
        powerValue = max(value,minOfPower)
    }
    
    func makePanel(enemy: Bool = false){
        if !enemy {
            if let statusNode = gameScene!.childNodeWithName(Constants.GameScene.SelfStatusPanel) as? SKSpriteNode {
                
                self.statusNode = statusNode
            }else{
                statusNode = makeStatusNode()
                statusNode!.name = Constants.GameScene.SelfStatusPanel
                statusNode!.position = CGPoint(x:statusNode!.frame.width/2 + 20 , y: statusNode!.frame.height/2 + 20)
                gameScene!.addChild(statusNode!)
            }
        }else{
            if let statusNode = gameScene!.childNodeWithName(Constants.GameScene.EnemyStatusPanel) as? SKSpriteNode {
                
                self.statusNode = statusNode
            }else{
                statusNode = makeStatusNode()
                statusNode!.name = Constants.GameScene.EnemyStatusPanel
                statusNode!.position = CGPoint(x:gameScene!.frame.width - statusNode!.frame.width/2 + 10, y: gameScene!.frame.height - statusNode!.frame.height/2 - 35)
                gameScene!.addChild(statusNode!)

            }
        }
    }
    
    func makeStatusNode() -> SKSpriteNode {
        let statusNode = SKSpriteNode(texture: nil, size: CGSizeMake(133.4, 62.5))
        
        let statusBar = SKSpriteNode(texture: SKTexture(imageNamed: Constants.GameScene.StatusBar),size:statusNode.size )
        
        statusNode.addChild(statusBar)
        return statusNode
    }
    
    func makeBar(positionX: CGFloat?){
        barContainer?.removeFromParent()
        bar?.removeFromParent()
        barBack?.removeFromParent()
        barContainer = SKNode()
        
        if positionX != nil {
            barContainer!.position = CGPoint(x:positionX!,y:view!.frame.height/2)
        }else{
            barContainer!.position = CGPoint(x:barWidth/2,y:view!.frame.height/2)
        }
        bar = SKSpriteNode()
        bar!.size = CGSizeMake(barWidth,view!.frame.height)
        barBack = SKSpriteNode(color: UIColor.grayColor(), size: CGSizeMake(barWidth,view!.frame.height))
        
        barContainer!.addChild(barBack!)
        barContainer!.addChild(bar!)
    }
    
    private func powerValueReactedToBar(){
        bar?.size.height = (powerValue/maxOfPower) * view!.frame.height
        bar?.position.y = -(view!.frame.height - bar!.size.height)/2
    }
    
    func show(node: SKNode){
        node.addChild(barContainer!)
        node.zPosition = 10
    }

}

class HPManager: PowerManger{
    
    var hpBarControl: SKSpriteNode!
    var hpBar: SKSpriteNode!
    var hp:SKSpriteNode!
    
    override func makeBar(positionX: CGFloat?) {
        super.makeBar(positionX)
        bar?.color = UIColor.redColor()
    }
    
    override func makePanel(enemy: Bool = false) {
        super.makePanel(enemy)
        
        let hpCropNode = SKCropNode()
        
        hp = SKSpriteNode(texture: SKTexture(imageNamed: Constants.GameScene.Hp),size:CGSizeMake(statusNode!.size.width*0.15,27))
        hpBar = SKSpriteNode(texture: SKTexture(imageNamed: Constants.GameScene.HpBar),size:CGSizeMake(statusNode!.size.width*0.87,9))
        hpBarControl  = SKSpriteNode(color: UIColor.whiteColor(),size:hpBar.size)

        hpBar.position = CGPointMake(7, -23)
        hp.position = CGPointMake(hpBar.position.x + hpBar.frame.width/2 + 14, -26)
        hpBarControl.position = hpBar.position
        hpBarControl.size.width = hpBar.size.width

        hpCropNode.maskNode = hpBarControl
        hpCropNode.addChild(hpBar)
        statusNode!.addChild(hp)
        statusNode!.addChild(hpCropNode)
        
    }
    
    override func powerValueReactedToBar(){
        hpBarControl.size.width = (powerValue/maxOfPower) * hpBar.size.width
        hpBarControl.position.x = hpBar.position.x - (hpBar.size.width - hpBarControl.size.width)/2
    }
}
class MPManager: PowerManger{
    
    var mpBarControl: SKSpriteNode!
    var mpBar: SKSpriteNode!
    var mp:SKSpriteNode!
    
    override func makeBar(positionX: CGFloat?) {
        super.makeBar(positionX)
        bar?.color = UIColor.blueColor()
    }
    
    override func makePanel(enemy: Bool = false) {
        super.makePanel(enemy)
        
        let mpCropNode = SKCropNode()
        let mpLast = SKSpriteNode(texture: SKTexture(imageNamed: Constants.GameScene.MpLast),size:CGSizeMake(statusNode!.size.width*0.07,37))
        
        mp = SKSpriteNode(texture: SKTexture(imageNamed: Constants.GameScene.Mp),size:CGSizeMake(statusNode!.size.width*0.15,27))
        mpBar = SKSpriteNode(texture: SKTexture(imageNamed: Constants.GameScene.MpBar),size:CGSizeMake(statusNode!.size.width*0.85,9))
        mpBarControl = SKSpriteNode(color: UIColor.whiteColor(),size:mpBar.size)
        
        mpBar.position = CGPointMake(7, -10)
        mp.position = CGPointMake(mpBar.position.x + mpBar.frame.width/2 + 16, -12)


        mpLast.position = CGPointMake(-statusNode!.size.width/2 + 9, -8)
        
        mpBarControl.position = mpBar.position
        mpBarControl.size.width = mpBar.size.width
        
        mpCropNode.maskNode = mpBarControl
        mpCropNode.addChild(mpBar)
        statusNode!.addChild(mp)
        statusNode!.addChild(mpCropNode)
        statusNode!.addChild(mpLast)
        
        if enemy {
            statusNode!.xScale = 0.6
            statusNode!.yScale = 0.6
        }
        
    }
    
    override func powerValueReactedToBar(){
        mpBarControl.size.width = (powerValue/maxOfPower) * mpBar.size.width
        mpBarControl.position.x = mpBar.position.x - (mpBar.size.width - mpBarControl.size.width)/2
    }
}

