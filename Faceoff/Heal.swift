//
//  Cure.swift
//  Faceoff
//
//  Created by Qiming Chen on 12/1/15.
//  Copyright © 2015 Liang. All rights reserved.
//

import Foundation
import SpriteKit

class Heal: Bullet {
    
    var armor: SKSpriteNode?
    var reduce: Double = 0.3
    var CDTime: Double = 25
    var UseTime: Double = 1
    var mp: Double = 20
    var effectTimer: NSTimer!
    
    override init(sceneNode :SKScene){
        super.init(sceneNode: sceneNode)
    }
    
    override func positveEffect() {
        enableCure()
        Tools.playSound(Constants.Audio.HealFire, node: gameScene!)
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
    
    func enableCure(){
        gameScene!.decreaseHealth(-50.0)
    }
}


