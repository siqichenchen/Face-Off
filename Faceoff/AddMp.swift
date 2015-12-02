//
//  AddMp.swift
//  Faceoff
//
//  Created by Qiming Chen on 12/1/15.
//  Copyright © 2015 Liang. All rights reserved.
//
import Foundation
import SpriteKit

class AddMp: Bullet {
    
    var armor: SKSpriteNode?
    var CDTime: Double = 20
    var UseTime: Double = 1
    var mp: Double = 30
    var effectTimer: NSTimer!
    
    override init(sceneNode :SKScene){
        super.init(sceneNode: sceneNode)
    }
    
    override func positveEffect() {
        Tools.playSound(Constants.Audio.AddMp, node: gameScene!)
        gameScene!.increaseMana(CGFloat(mp))
    }
    
    override func getCDtime() -> Double {
        return CDTime
    }
    
    override func getUscTime() -> Double {
        return UseTime
    }
}



