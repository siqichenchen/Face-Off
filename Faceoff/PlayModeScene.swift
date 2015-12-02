//
//  PlayModeScene.swift
//  Faceoff
//
//  Created by Huaying Tsai on 9/26/15.
//  Copyright © 2015 huaying. All rights reserved.
//

import SpriteKit

class PlayModeScene: SKScene {
    var 選擇單人遊戲按鈕: SKNode! = nil
    var 選擇雙人遊戲按鈕: SKNode! = nil
    var 返回按鈕: SKNode! = nil
    var single = false

    
    override func didMoveToView(view: SKView) {
        
        loadBackground()
        loadBackButton()
        loadStoryButton()
        loadVersusButton()
    
    }
    func loadBackground(){
        let background = SKSpriteNode(texture: nil, size: frame.size)
    
        let textureAtlas = SKTextureAtlas(named: Constants.PlayModeScene.Background)
        var textures: [SKTexture] = []
        var animation:SKAction!
        
        for index in 1...textureAtlas.textureNames.count {
            let imgName = String(format: "\(Constants.PlayModeScene.Background)%02d", index)
            textures.append(textureAtlas.textureNamed(imgName))
        }
        animation = SKAction.animateWithTextures(textures, timePerFrame: 0.15)
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        background.alpha = 0.5
        background.zPosition = -10
        addChild(background)
        background.runAction(SKAction.repeatActionForever(animation))
    }
    func loadBackButton(){
        
        let texture = SKTexture(image: UIImage(named: Constants.PlayModeScene.BackButton)!)
        返回按鈕 = SKSpriteNode(texture: texture, size: CGSizeMake(CGFloat(Constants.Scene.BackButtonSizeWidth) ,CGFloat(Constants.Scene.BackButtonSizeHeight)))
        返回按鈕.position = CGPoint(x:返回按鈕.frame.width/2,y: 返回按鈕.frame.height/2)
        addChild(返回按鈕)
    }
    
    func loadStoryButton(){
        
        let texture = SKTexture(image: UIImage(named: Constants.PlayModeScene.StoryButton)!)
        選擇單人遊戲按鈕 = SKSpriteNode(texture: texture, size: CGSizeMake(130.0,41.0))
        選擇單人遊戲按鈕.position = CGPoint(x:frame.midX - 80,y: frame.midY + 80)
        print(選擇單人遊戲按鈕.position)
        addChild(選擇單人遊戲按鈕)
        
    }
    
    func loadVersusButton(){
        
        let texture = SKTexture(image: UIImage(named: Constants.PlayModeScene.VersusButton)!)
        選擇雙人遊戲按鈕 = SKSpriteNode(texture: texture, size: CGSizeMake(130.0,41.0))
        選擇雙人遊戲按鈕.position = CGPoint(x:frame.midX - 80,y: frame.midY + 40)
        addChild(選擇雙人遊戲按鈕)        

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let location = touches.first?.locationInNode(self){
            if 選擇單人遊戲按鈕.containsPoint(location){
                Tools.playSound(Constants.Audio.TransButton, node: self)
                print("single play")
                
                btAdvertiseSharedInstance.single = true
                
                let nextScene = SelectWeaponScene(size: scene!.size)
                nextScene.backgroundColor = UIColor.grayColor()
                nextScene.scaleMode =  .AspectFill
                transitionForNextScene(nextScene)
                
                //                let nextScene = GameScene3(size: scene!.size)
                //                nextScene.backgroundColor = UIColor.grayColor()
                //                nextScene.scaleMode =  .AspectFill
                //                transitionForNextScene(nextScene)
                
            }else if 選擇雙人遊戲按鈕.containsPoint(location){
                Tools.playSound(Constants.Audio.TransButton, node: self)
                print("multiplayer")
                let nextScene = BuildConnectionScene(size: scene!.size)
                nextScene.scaleMode = SKSceneScaleMode.ResizeFill
                transitionForNextScene(nextScene)
                
            }else if 返回按鈕.containsPoint(location){
                Tools.playSound(Constants.Audio.TransButton, node: self)
                let nextScene = MainScene(size: scene!.size)
                nextScene.scaleMode = SKSceneScaleMode.AspectFill
                transitionForNextScene(nextScene)
            }
        }
    }

    func transitionForNextScene(nextScene: SKScene){
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Up, duration: 0.5)
        removeAllChildren()
        scene?.view?.presentScene(nextScene, transition: transition)
    }
    
    override func update(currentTime: NSTimeInterval) {
        
    }
}