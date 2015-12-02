//
//  IceBullet.swift
//  Faceoff
//
//  Created by Huaying Tsai on 11/28/15.
//  Copyright © 2015 Liang. All rights reserved.
//

import Foundation
import SpriteKit

class IceBullet: Weapon {
    
    var frozenEffectImg: SKSpriteNode!
    var damage: Double = 5.0
    var effectTimer: NSTimer!
    var CDTime: Double = 6
    var UseTime: Double = 8
    var mp: Double = 20

    
    override init(sceneNode :SKScene){
        super.init(sceneNode: sceneNode)
        bulletImageName = Constants.Weapon.WeaponImage.IceBullet
    }
    
    override func fire(){
        super.fire()
        
        let character = getCharacter()!
        let bulletPosition = CGPointMake(character.position.x, character.position.y + character.frame.height + 25)
        let bulletVector = CGVectorMake(0, (gameScene!.size.height))
        fire(bulletPosition,vector: bulletVector)
        
        let normalizedX = 1 - (bulletPosition.x/gameScene!.size.width)
        btAdvertiseSharedInstance.update("fire-bullet",data: ["x":normalizedX.description])
    }
    
    override func fireFromEnemy(fireInfo: [String]) {
        
        if let normalizedX = Double(fireInfo[0]) {
            let x = CGFloat(normalizedX) * gameScene!.size.width
            let bulletPosition = CGPoint(x: CGFloat(x), y: gameScene!.size.height)
            let bulletVector = CGVectorMake(0, -gameScene!.size.height)
            fire(bulletPosition,vector: bulletVector,fromEnemy: true)
        }
        
    }
    
    func fire(fromPosition: CGPoint, vector: CGVector, fromEnemy: Bool = false){
        if let bulletImageName = bulletImageName {
            bullet = SKSpriteNode(imageNamed: bulletImageName)
            bullet!.xScale = 0.2
            bullet!.yScale = 0.2
            bullet!.position = fromPosition
            bullet!.name = Constants.GameScene.Fire
            PhysicsSetting.setupFire(bullet!)
            
            if fromEnemy {
                bullet!.size.height *= -1
                bullet!.name = Constants.GameScene.EnemyFire
                PhysicsSetting.setupEnemyFire(bullet!)
            }
            
            let bulletAction = SKAction.sequence([SKAction.moveBy(vector, duration: 1.0), SKAction.waitForDuration(3.0/60.0), SKAction.removeFromParent()])
            
            bullet!.runAction(bulletAction)
            Tools.playSound(Constants.Audio.IceBulletFire, node: bullet!)
            gameScene!.addChild(bullet!)
        }
    }
    override func effect(character:CharacterNode){
        super.effect(character)
        
        removeEffect()
        frozenEffectImg = SKSpriteNode(imageNamed: Constants.Weapon.Effect.Ice)
        frozenEffectImg.xScale = 1
        frozenEffectImg.yScale = 1
        frozenEffectImg.alpha = 0.4
        frozenEffectImg.zPosition = character.zPosition + 1
        gameScene?.velocityMultiplier = 0
        
        character.addChild(frozenEffectImg)
        
        
        effectTimer = NSTimer.scheduledTimerWithTimeInterval(2,
            target: self,
            selector: "removeEffect",
            userInfo: nil,
            repeats: true)

    }
    
    override func positveEffect() {
        gameScene!.decreaseMana(CGFloat(getLosingMp()))
    }
    
    override func removeEffect(){
        effectTimer?.invalidate()
        frozenEffectImg?.removeFromParent()
        gameScene?.velocityMultiplier = Constants.GameScene.Velocity
    }
    override func getCDtime() -> Double {
        return CDTime
    }
    
    override func getUscTime() -> Double {
        return UseTime
    }
    
    override func getLosingMp() -> Double {
        return mp
    }
    override func getDamage() -> Double {
        return damage
    }
}
