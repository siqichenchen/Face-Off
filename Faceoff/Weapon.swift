//
//  Weapon.swift
//  Faceoff
//
//  Created by Huaying Tsai on 11/20/15.
//  Copyright © 2015 Liang. All rights reserved.
//

import Foundation
import SpriteKit


class Weapon: NSObject{
    
    var bullet: SKSpriteNode?
    var bulletStart: CGPoint?
    var bulletEnd: CGPoint?
    var bulletImageName: String?
    var firePreparingEmitter: SKEmitterNode!
    
    var gameScene: GameScene2?
    var gameSceneSingle: GameScene3?
    
    var isFirePreparing: Bool = false
    
    init(sceneNode :SKScene){
        if let gameScene = sceneNode as? GameScene2 {
            self.gameScene = gameScene
        }
    }
    
    func fire(){}
    func fireFromEnemy(fireInfo :[String]){}
    
    //Powered Fire
    func fire(preparingTime: NSTimeInterval?){}
    func effect(character:CharacterNode){} //set effect when hit
    func removeEffect(){}
    func positveEffect(){}  //initial effect for self
    func negativeEffect(){} //initial effect for others
    
    func effectToMonster(monster:MonsterNode){} //set effect when hit
    func removeEffectToMonster(){}
    
    func firePreparingAction(){}
    func stopFirePreparingAction() {}
    func getDamage() -> Double { return 0 }
    func getReduce() -> Double { return 1 }
    func getManaUse() -> Double { return 0 }
    func getCDtime() -> Double { return 0 }
    func getUscTime() -> Double { return 0 }
    func getCharacter() -> SKSpriteNode? {
        return gameScene!.character
    }
    func getLosingMp() -> Double { return 0 }
}







