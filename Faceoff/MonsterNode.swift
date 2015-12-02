//
//  Character.swift
//  Faceoff
//
//  Created by Huaying Tsai on 11/20/15.
//  Copyright © 2015 Liang. All rights reserved.
//

import Foundation
import SpriteKit

class MonsterNode: SKSpriteNode {
    
    var sceneNode: SKScene!
    
    func setup(sceneNode :SKScene){
        
        self.sceneNode = sceneNode
        xScale = 0.6
        yScale = 0.6
        zPosition = 1000
        position = CGPointMake(self.sceneNode.size.width / 2, self.sceneNode.size.height + 150)
        name = Constants.GameScene.Monster
        PhysicsSetting.setupMonster(self)
        sceneNode.addChild(self)
    }
    
    func getEffect(weaponManger :WeaponManager){
        weaponManger.effectToMonster(self)
    }
    
    func shake(){
        let action = SKAction.shake(0.5, amplitudeX: 10, amplitudeY: 10)
        runAction(action)
    }
}