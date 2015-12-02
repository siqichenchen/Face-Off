//
//  Laser.swift
//  Faceoff
//
//  Created by Huaying Tsai on 11/28/15.
//  Copyright © 2015 Liang. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

class Laser: Weapon {
    
    var damage: Double = 0
    var mana: Double = 1.5
    let chargeWait = SKAction.waitForDuration(0.3)
    var kameCharge : AVAudioPlayer! = nil
    
    override init(sceneNode :SKScene){
        super.init(sceneNode: sceneNode)
    }
    override func fire(){
        super.fire()
        bullet!.xScale = 0.2
        bullet!.yScale = 0.2
    }
    
    //Powered Fire
    override func fire(preparingTime: NSTimeInterval?){
        stopFirePreparingAction()
        
        if let preparingTime = preparingTime{
            
            let laserWidth = 400.0
            var laserFinalWidth: Double!
            if preparingTime > 3.0 {
                laserFinalWidth = laserWidth
            }else{
                laserFinalWidth = laserWidth * preparingTime/3.0
            }
            
            let character = getCharacter()
            
            let bulletPosition = CGPoint(x: character!.position.x, y: character!.position.y + character!.size.height/2 + gameScene!.size.height/2 * 1.5)
            
            fire(bulletPosition,laserWidth: CGFloat(laserFinalWidth))
            
            let normalizedX = 1 - (bulletPosition.x/gameScene!.size.width)
            btAdvertiseSharedInstance.update("fire-laser",data: ["x":normalizedX.description,"laserWidth":laserFinalWidth.description])
        
            kameCharge?.stop()
            Tools.playSound(Constants.Audio.LaserFire, node: self.gameScene!)
        }
    }
    override func fireFromEnemy(fireInfo: [String]) {
        
        if let normalizedX = Double(fireInfo[0]) {
            let x = CGFloat(normalizedX) * gameScene!.size.width
            if let laserWidth = Double(fireInfo[1]) {
                
                let bulletPosition = CGPointMake(x, gameScene!.frame.height/2)
                fire(bulletPosition,laserWidth: CGFloat(laserWidth),fromEnemy: true)
                
                damage = laserWidth/20
            }
        }
        
    }
    
    
    func fire(fromPosition: CGPoint, laserWidth: CGFloat, fromEnemy: Bool = false){
        
        bullet = SKSpriteNode(imageNamed: "a01")
        
        bullet!.size.width = CGFloat(laserWidth)
        bullet!.size.height = CGFloat(gameScene!.size.height * 1.5)
        bullet!.name = Constants.GameScene.PoweredFire
        PhysicsSetting.setupFire(bullet!)
        
        if fromEnemy {
            bullet!.size.height *= -1
            bullet!.name = Constants.GameScene.EnemyPoweredFire
            PhysicsSetting.setupEnemyFire(bullet!)
        }
        
        bullet!.position = fromPosition
        
        let ebAtlas = SKTextureAtlas(named: "animation")
        var energyBlastAnim:[SKTexture] = []
        
        for index in 1...ebAtlas.textureNames.count {
            let imgName = String(format: "a%02d", index)
            energyBlastAnim += [ebAtlas.textureNamed(imgName)]
        }
        let animation = SKAction.animateWithTextures(energyBlastAnim, timePerFrame: 0.1)
        bullet!.runAction(animation, completion: {
            self.bullet!.removeFromParent()
        })
        
        gameScene!.addChild(bullet!)
        
    }
    
    
    override func firePreparingAction(){
        
        isFirePreparing = true
        
        let character = getCharacter()!
        
        let chargeAction = {
            if self.isFirePreparing {
                
                self.gameScene!.velocityMultiplier = 0
                self.stopFirePreparingAction()
                
                let sksPath = NSBundle.mainBundle().pathForResource("MyParticle", ofType: "sks")
                
                self.firePreparingEmitter = NSKeyedUnarchiver.unarchiveObjectWithFile(sksPath!) as! SKEmitterNode
                self.firePreparingEmitter!.zPosition = 0;
                self.firePreparingEmitter!.alpha = 0.6
                self.firePreparingEmitter!.particleBirthRate = 500
                
                do {
                    try self.kameCharge = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("kameCharge", ofType: "wav")!))
                    
                    self.kameCharge.play()
                } catch {
                    print(error)
                }

                
                
                character.addChild(self.firePreparingEmitter!)
            }
        }
        character.runAction(SKAction.sequence([chargeWait,SKAction.runBlock(chargeAction)]),withKey: "chargeAction")
    }
    
    override func stopFirePreparingAction() {
        let character = getCharacter()!
        isFirePreparing = false
        character.removeActionForKey("chargeAction")
        firePreparingEmitter?.removeFromParent()
    }
    
    override func getDamage() -> Double {
        return damage
    }
    override func getManaUse() -> Double { return mana }
}
