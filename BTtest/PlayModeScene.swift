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
    let background: SKNode! = SKSpriteNode(imageNamed: "spaceship2.jpg")
    var Img: UIImage! = nil
    override func didMoveToView(view: SKView) {
        
    
        選擇單人遊戲按鈕 = SKSpriteNode(color: UIColor.blueColor().colorWithAlphaComponent(0.3), size: CGSize(width: 200, height: 40))
        選擇單人遊戲按鈕.position = CGPoint(x:CGRectGetMidX(self.frame),y:CGRectGetMidY(self.frame)+CGFloat(75.0))
        addChild(選擇單人遊戲按鈕)
        
        let 製造角色文字 = SKLabelNode(fontNamed:"Chalkduster")
        製造角色文字.text = "Fight";
        製造角色文字.fontSize = 14;
        製造角色文字.position = CGPoint(x:CGFloat(0),y:CGFloat(-5))
        選擇單人遊戲按鈕.addChild(製造角色文字)
        
        選擇雙人遊戲按鈕 = SKSpriteNode(color: UIColor.blueColor().colorWithAlphaComponent(0.3), size: CGSize(width: 200, height: 40))
        選擇雙人遊戲按鈕.position = CGPoint(x:CGRectGetMidX(self.frame),y:CGRectGetMidY(self.frame)+CGFloat(25.0))
        addChild(選擇雙人遊戲按鈕)
        
        let 進入遊戲文字 = SKLabelNode(fontNamed:"Chalkduster")
        進入遊戲文字.text = "2-Players Fight";
        進入遊戲文字.fontSize = 14;
        進入遊戲文字.position = CGPoint(x:CGFloat(0),y:CGFloat(-5))
        選擇雙人遊戲按鈕.addChild(進入遊戲文字)
        
        返回按鈕 = SKSpriteNode(color: UIColor.blueColor().colorWithAlphaComponent(0.3), size: CGSize(width: 200, height: 40))
        返回按鈕.position = CGPoint(x:CGRectGetMidX(self.frame),y:CGRectGetMidY(self.frame)-CGFloat(25.0))
        addChild(返回按鈕)
        
        let 返回文字 = SKLabelNode(fontNamed:"Chalkduster")
        返回文字.text = "Back";
        返回文字.fontSize = 14;
        返回文字.position = CGPoint(x:CGFloat(0),y:CGFloat(-5))
        返回按鈕.addChild(返回文字)

        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.scene?.size = frame.size
        background.xScale = 0.8
        background.yScale = 0.8
        background.zPosition = -100
        addChild(background)

        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let location = touches.first?.locationInNode(self){
            if 選擇單人遊戲按鈕.containsPoint(location){
                選擇單人遊戲按鈕.runAction(SKAction.playSoundFileNamed(FaceoffGameSceneEffectAudioName.ButtonAudioName.rawValue, waitForCompletion: false))
                print("single play")
//                let nextScene = GameScene(size: scene!.size)
//                nextScene.backgroundColor = UIColor.grayColor()
//                nextScene.scaleMode =  .AspectFill
//                transitionForNextScene(nextScene)
                
            }else if 選擇雙人遊戲按鈕.containsPoint(location){
                選擇雙人遊戲按鈕.runAction(SKAction.playSoundFileNamed(FaceoffGameSceneEffectAudioName.ButtonAudioName.rawValue, waitForCompletion: false))
                print("multiplayer")
                let nextScene = BuildConnectionScene(size: scene!.size)
                nextScene.Img = Img
                nextScene.scaleMode = SKSceneScaleMode.AspectFill
                transitionForNextScene(nextScene)
                
            }else if 返回按鈕.containsPoint(location){
                返回按鈕.runAction(SKAction.playSoundFileNamed(FaceoffGameSceneEffectAudioName.ButtonAudioName.rawValue, waitForCompletion: false))
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