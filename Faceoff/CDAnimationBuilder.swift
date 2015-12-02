//
//  CDAnimationBuilder.swift
//  BTtest
//
//  Created by Qiming Chen on 11/14/15.
//  Copyright © 2015 Liang. All rights reserved.
//

import SpriteKit

class CDAnimationBuilder {
    func initCdAnimation(atlasStr: String, time: Double) -> SKAction {
        let cdAtlas = SKTextureAtlas(named: atlasStr)
        var cdAnim = [SKTexture]()
        var animation = SKAction()
        cdAnim = []
        
        for index in 1...cdAtlas.textureNames.count {
            let imgName = String(format: atlasStr + "%02d", index)
            cdAnim += [cdAtlas.textureNamed(imgName)]
        }
        
        animation = SKAction.animateWithTextures(cdAnim, timePerFrame: time / 8)
        return animation
    }
}