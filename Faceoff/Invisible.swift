//
//  Invisible.swift
//  Faceoff
//
//  Created by Qiming Chen on 12/1/15.
//  Copyright © 2015 Liang. All rights reserved.
//

//
//  Armor.swift
//  Faceoff
//
//  Created by Huaying Tsai on 11/29/15.
//  Copyright © 2015 Liang. All rights reserved.
//

import Foundation
import SpriteKit

class Invisible: Bullet {
    
    var armor: SKSpriteNode?
    var reduce: Double = 0.3
    var CDTime: Double = 8
    var UseTime: Double = 8
    var mp: Double = 10
    var effectTimer: NSTimer!
    
    override init(sceneNode :SKScene){
        super.init(sceneNode: sceneNode)
    }
    
    override func negativeEffect() {
        enableInvisible()
    }
    
    override func positveEffect() {
        Tools.playSound(Constants.Audio.InvisibilityFire, node: gameScene!)
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
    
    func enableInvisible(){
        gameScene!.enemyMark.alpha = 0
        
        delay(UseTime) {
            self.disableInvisible()
        }
    }
    
    func disableInvisible() {
        gameScene!.enemyMark.alpha = 1
    }
    
    deinit {
        disableInvisible()
    }
}

