//
//  Armor.swift
//  Faceoff
//
//  Created by Huaying Tsai on 11/29/15.
//  Copyright © 2015 Liang. All rights reserved.
//

import Foundation
import SpriteKit

class Armor: Bullet {
    
    var armor: SKSpriteNode?
    var reduce: Double = 0.3
    var CDTime: Double = 5
    var UseTime: Double = 5
    var mp: Double = 10
    var effectTimer: NSTimer!
    
    override init(sceneNode :SKScene){
        super.init(sceneNode: sceneNode)
    }
    
    override func positveEffect() {
        enableArmor()
        Tools.playSound(Constants.Audio.ArmorFire, node: gameScene!)
        gameScene!.decreaseMana(CGFloat(getLosingMp()))
    }
    
    override func getReduce() -> Double {
        return reduce
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
    
    func enableArmor(){
        
        armor = SKSpriteNode(imageNamed: Constants.Weapon.WeaponImage.Armor)
        let character = getCharacter()!
        
        armor!.name = Constants.Weapon.WeaponImage.Armor
        armor!.size.height = character.size.height * 2
        armor!.size.width = character.size.width * 2
        armor!.position.y = character.size.width
        armor?.zPosition = character.zPosition+1
        character.addChild(armor!)
        effectTimer = NSTimer.scheduledTimerWithTimeInterval(UseTime,
            target: self,
            selector: "disableArmor",
            userInfo: nil,
            repeats: false)
    }
    
    func disableArmor(){
        armor?.removeFromParent()
    }
    
    deinit {
        disableArmor()
    }
}

