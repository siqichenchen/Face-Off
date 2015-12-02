//
//  EnlargeEnemy.swift
//  Faceoff
//
//  Created by Qiming Chen on 12/1/15.
//  Copyright © 2015 Liang. All rights reserved.
//

import Foundation
import SpriteKit

class EnlargeEnemy: Bullet {
    
    var armor: SKSpriteNode?
    var reduce: Double = 0.3
    var CDTime: Double = 5
    var UseTime: Double = 5
    var mp: Double = 10
    
    override init(sceneNode :SKScene){
        super.init(sceneNode: sceneNode)
    }
    
    override func negativeEffect() {
        Tools.playSound(Constants.Audio.EnlargeFire, node: gameScene!)
        enableEnlarge()
    }
    
    override func positveEffect() {
        gameScene!.decreaseMana(CGFloat(getLosingMp()))
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
    
    func delay(delay:Double, closure:()->()) {
        
        dispatch_after(
            dispatch_time( DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
    }
    
    func enableEnlarge(){
        gameScene!.character.setScale(1)
        delay(UseTime) {
            self.disableEnlarge()
        }
    }
    
    func disableEnlarge() {
        gameScene!.character.setScale(0.5)
    }
    
    deinit {
        disableEnlarge()
    }
}

