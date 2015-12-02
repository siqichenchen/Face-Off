//
//  Character.swift
//  Faceoff
//
//  Created by Huaying Tsai on 11/20/15.
//  Copyright © 2015 Liang. All rights reserved.
//

import Foundation
import SpriteKit

class CharacterNode: SKSpriteNode {
    
    var sceneNode: SKScene!
    
    func setup(sceneNode :SKScene){
        
        self.sceneNode = sceneNode
        xScale = 0.5
        yScale = 0.5
        zPosition = 1000
        position = CGPointMake(self.sceneNode.size.width / 2, 8)
        name = Constants.GameScene.Character
        PhysicsSetting.setupCharacter(self)
        sceneNode.addChild(self)
    }
    
    func getEffect(weaponManger :WeaponManager){
        weaponManger.effect(self)
    }
    
    func shake(){
        let action = SKAction.shake(0.5, amplitudeX: 10, amplitudeY: 10)
        runAction(action)
    }
}