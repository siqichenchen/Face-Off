//
//  GameSceneBeta.swift
//  Faceoff
//
//  Created by Huaying Tsai on 11/18/15.
//  Copyright © 2015 Liang. All rights reserved.
//

import Foundation
import SpriteKit
import CoreMotion
import AVFoundation
import AudioToolbox

class GameScene3: GameScene2{
   
    var monster: MonsterNode!
    let MonsterName = Constants.GameScene.Monster
    var wasHit = false
    var charging = false
    var rush = false
    var canMonsterMove = true
    
    var Stage = 1
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */

        if (!self.contentCreated) {
            self.setupGame()
            self.contentCreated = true
            
            // Accelerometer starts
            self.motionManager.startAccelerometerUpdates()
        }
    }
    
    override func setupGame(){
        super.setupGame()
        
        setupMonster()
        monsterBeginMove(2)
        monsterBeginFire(1,range: 5)

    }
    

    
    func setupMonster() {
        
        var monsterName = String()
        switch(Stage){
        case 1:
            monsterName = "fireMonster"
            break
        case 2:
            monsterName = "iceMonster"
            break
        default:
            monsterName = "fireMonster"
            break
            
        }
        monster = MonsterNode(texture: SKTexture(image: UIImage(named: monsterName)!))
        monster.setup(self)
        monster.getEffect(weaponManager)
        
        wasHit = false
        charging = false
        rush = false
    }
    
    func monsterRush(){
        
        monster.removeAllActions()
        enemyMark.removeAllActions()
        
        self.rush = true
        let rushPoint = CGPoint(x: self.monster.position.x, y:100)
        let rushBackPoint = CGPoint(x: self.monster.position.x, y: self.size.height + 150)
        
        let rushAction = SKAction.moveTo(rushPoint, duration: 0.5)
        let rushBackAction = SKAction.moveTo(rushBackPoint, duration: 3)
        self.monster.runAction(SKAction.sequence([rushAction, rushBackAction]), completion: {
            self.rush = false
        })
    }
    
    func monsterBeginMove(speed : NSTimeInterval){
        
        let movingWait = SKAction.waitForDuration(0.1)
        let move = SKAction.runBlock {
            
            if(!self.wasHit && !self.charging && !self.rush){
                self.monsterMovement(speed)
            }
        }
        let moveSequence = SKAction.sequence([movingWait, move])
        self.runAction(SKAction.repeatActionForever(moveSequence))
        
    }
    
    func monsterBeginFire(interval : Float, range : Float){
        
        if isGameStart {
        
            let wait = SKAction.waitForDuration(NSTimeInterval(interval), withRange: NSTimeInterval(Float(arc4random_uniform(10))/range))
            let spawn = SKAction.runBlock {
                
                if(!self.charging && !self.rush){
                    self.monsterWeaponType()
                }
            }
            let sequence = SKAction.sequence([wait, spawn])
            self.runAction(SKAction.repeatActionForever(sequence))
        
        }
    }
    
    func monsterMovement(speed : NSTimeInterval){
        
        if canMonsterMove{
            let monsterPoint = CGPoint(x:  self.character.position.x, y: self.size.height + 150)
            let markPoint = CGPoint(x: self.character.position.x, y:enemyMark.position.y)
            self.monster.runAction(SKAction.moveTo(monsterPoint, duration: speed))
            self.enemyMark.runAction(SKAction.moveTo(markPoint, duration: speed))
        }
        
    }
    func monsterWeaponType(){
        
        let normalizedX = (self.enemyMark.position.x/self.size.width)
        
        switch(arc4random_uniform(10)){
        case 1:
            
            charging = true
            monster.removeAllActions()
            enemyMark.removeAllActions()
            
            let duration = NSTimeInterval(arc4random_uniform(4) + 3)
            let width = String(50 * duration)
            let durationAction = SKAction.waitForDuration(duration)
            let completion = SKAction.runBlock({
                self.charging = false
                self.weaponManager.setEnemyWeapon(Constants.Weapon.WeaponType.Laser,powered: true)
                self.weaponManager.poweredFireFromEnemy([String(normalizedX), width])
            })
            
            let sequence = SKAction.sequence([durationAction, completion])
            runAction(sequence, withKey:"MonsterCharging")
            
            break
        case 2:
            if(Stage == 1){
                self.weaponManager.setEnemyWeapon(Constants.Weapon.WeaponType.FireBullet,powered: false)
                self.weaponManager.fireFromEnemy([String(normalizedX)])
            }
            break
        case 3:
            if(Stage == 2){
                self.weaponManager.setEnemyWeapon(Constants.Weapon.WeaponType.IceBullet,powered: false)
                self.weaponManager.fireFromEnemy([String(normalizedX)]);
                
            }
            break
        case 4:
            if(!rush){
                monsterRush()
            }
            break
        default:
            self.weaponManager.setEnemyWeapon(Constants.Weapon.WeaponType.Bullet,powered: false)
            self.weaponManager.fireFromEnemy([String(normalizedX)]);
            
            break
        }
    }
    
    
    
    override func setupEnemyCharacter(){
        
        let image = UIImage(named: Constants.GameScene.EnemySlot)
        let texture = SKTexture(image: image!)
        let enemySlot = SKSpriteNode(texture: texture,size:CGSizeMake(55,55))
        
        enemySlot.position = CGPointMake(self.frame.width - enemySlot.frame.width/2 - 20 ,self.frame.height - enemySlot.frame.height/2 - 5 )
        addChild(enemySlot)
        
        let monsterHead = UIImage(named: Constants.GameScene.MonsterHead)
        enemy = SKSpriteNode(texture: SKTexture(image: monsterHead!),size:CGSizeMake(50,50))
        enemySlot.addChild(enemy)
        
    }
    
    func decreaseMonsterHealth( value : CGFloat){
        
        if isGameStart {
            enemyHp!.decrease(value)
            //btAdvertiseSharedInstance.update("hp",data: ["hp":hp!.powerValue.description])
            
            if(enemyHp!.powerValue <= 50 && enemyHp!.powerValue > 0){
                //do something but not profEmitterActionAtPosition
            }
            else if(enemyHp!.powerValue <= 0){
                stopGame()
                setupGameEndPanel(true)
            }
        }
    }

    // Physics Contact Helpers
    override func didBeginContact(contact: SKPhysicsContact) {
        
        if contact as SKPhysicsContact? != nil {
            self.handleContact(contact)
        }
    }
    
    override func handleContact(contact: SKPhysicsContact) {
        
        if (contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil) {
            return
        }
        
        let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!] as NSArray
        
        //Character is attacked
        if nodeNames.containsObject(CharacterName) && nodeNames.containsObject(EnemyFireName) {
            
            if contact.bodyA.node == character {
                contact.bodyB.node!.removeFromParent()
            } else {
                contact.bodyA.node!.removeFromParent()
            }
            
            character?.shake()
            character.getEffect(weaponManager)
            decreaseHealth(CGFloat(weaponManager.fireDamage()))
        }
        else if nodeNames.containsObject(CharacterName) && nodeNames.containsObject(EnemyPoweredFire) {
            
            character?.shake()
            character.getEffect(weaponManager)
            decreaseHealth(CGFloat(weaponManager.poweredFireDamage()))
        }
        if nodeNames.containsObject(MonsterName) && nodeNames.containsObject(FireName) {
            
            if contact.bodyA.node == monster {
                contact.bodyB.node!.removeFromParent()
            }
            else{
                contact.bodyA.node!.removeFromParent()
            }
            
            monster?.shake()
            monster.getEffect(weaponManager)
            decreaseMonsterHealth(CGFloat(weaponManager.fireDamage()))
            
        }
        else if nodeNames.containsObject(MonsterName) && nodeNames.containsObject(PoweredFire) {
            
            monster?.shake()
            decreaseMonsterHealth(CGFloat(20))
        }
        else if nodeNames.containsObject(CharacterName) && nodeNames.containsObject(MonsterName) {
            
            character?.shake()
            decreaseHealth(CGFloat(20))
            
        }
        
    }
    
}
