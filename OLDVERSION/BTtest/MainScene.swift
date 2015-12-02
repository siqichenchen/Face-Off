//
//  MainScene.swift
//  Faceoff
//
//  Created by Huaying Tsai on 9/26/15.
//  Copyright © 2015 huaying. All rights reserved.
//

import UIKit
import GLKit
import SpriteKit
import Foundation


class MainScene: SKScene,UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    var layerView: UIImageView!
    var finalImg : UIImage!
    var imgForPlayer : UIImage!
    
    var imagePicker: UIImagePickerController!
    
    let logo = UIImage(named: "headdd")!
    let mask = CALayer()
    
    
    var btn:UIButton = UIButton()
    
    var 製造角色按鈕: SKNode! = nil
    var 進入遊戲按鈕: SKNode! = nil
    var 角色: SKSpriteNode! = nil
    var testImage: SKNode! = nil
    let background: SKNode! = SKSpriteNode(imageNamed: "spaceship1.jpg")
    
    override func didMoveToView(view: SKView) {
        
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        background.xScale = 0.75
        background.yScale = 0.75
        background.zPosition = -100
        addChild(background)
        
        製造角色按鈕 = SKSpriteNode(color: UIColor.redColor().colorWithAlphaComponent(0.3), size: CGSize(width: 200, height: 40))
        製造角色按鈕.position = CGPoint(x:CGRectGetMidX(self.frame),y:CGRectGetMidY(self.frame)+CGFloat(50.0))
        addChild(製造角色按鈕)
        let 製造角色文字 = SKLabelNode(fontNamed:"Chalkduster")
        製造角色文字.text = "Create a character";
        製造角色文字.fontSize = 14;
        製造角色文字.position = CGPoint(x:CGFloat(0),y:CGFloat(-5))
        製造角色按鈕.addChild(製造角色文字)
        
        
        
        進入遊戲按鈕 = SKSpriteNode(color: UIColor.redColor().colorWithAlphaComponent(0.3), size: CGSize(width: 200, height: 40))
        進入遊戲按鈕.position = CGPoint(x:CGRectGetMidX(self.frame),y:CGRectGetMidY(self.frame)-CGFloat(0.0))
        addChild(進入遊戲按鈕)
        
        let 進入遊戲文字 = SKLabelNode(fontNamed:"Chalkduster")
        進入遊戲文字.text = "Play";
        進入遊戲文字.fontSize = 14;
        進入遊戲文字.position = CGPoint(x:CGFloat(0),y:CGFloat(-5))
        
        進入遊戲按鈕.addChild(進入遊戲文字)
        
        loadCharacter()
    }
    
    func loadCharacter(){
        if let character = CharacterManager.getCharacterFromLocalStorage() {
            if 角色 != nil && 角色.parent != nil {
                角色.removeFromParent()
            }
            角色 = SKSpriteNode(texture: SKTexture(image: character))
            角色.position = CGPoint(x:CGRectGetMidX(self.frame),y:CGRectGetMidY(self.frame)-CGFloat(50.0))
            角色.setScale(0.1)
            addChild(角色)
            finalImg = character
        }
        
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let location = touches.first?.locationInNode(self){
            if 製造角色按鈕.containsPoint(location){
                製造角色按鈕.runAction(SKAction.playSoundFileNamed(FaceoffGameSceneEffectAudioName.ButtonAudioName.rawValue, waitForCompletion: false))
                print("sdfd")
                self.takePictures()
                
            }
                
                
            else if 進入遊戲按鈕.containsPoint(location){
                進入遊戲按鈕.runAction(SKAction.playSoundFileNamed(FaceoffGameSceneEffectAudioName.ButtonAudioName.rawValue, waitForCompletion: false))
                
                let transition = SKTransition.revealWithDirection(SKTransitionDirection.Up, duration: 0.5)
                removeAllChildren()
                let nextScene = PlayModeScene(size: scene!.size)
                nextScene.scaleMode = .AspectFill
                nextScene.Img = finalImg
                scene?.view?.presentScene(nextScene, transition: transition)
            }
            
            
        }
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("tttttt")
        finalImg = info[UIImagePickerControllerEditedImage] as? UIImage
        print("rrrrrr")
        let photoView = UIImageView(image: finalImg)
        photoView.layer.borderWidth = 3
        photoView.layer.cornerRadius = photoView.frame.size.height/2;
        photoView.layer.masksToBounds = true
        print("wwwwww")
        
        var layer1: CALayer = CALayer()
        
        layer1 = photoView.layer
        UIGraphicsBeginImageContext(CGSize(width:photoView.frame.size.height,height:photoView.frame.size.height))
        layer1.renderInContext(UIGraphicsGetCurrentContext()!)
        finalImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        CharacterManager.saveCharacterToLocalStorage(finalImg)
        
        picker.dismissViewControllerAnimated(true, completion: imagePickingFinished)
    }
    
    func imagePickingFinished(){
        loadCharacter()
    }
    
    
    
    func takePictures(){
        
        let imagePicker =  UIImagePickerController()
        //imagePicker.modalPresentationStyle = .CurrentContext
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera //UIImagePickerControllerSourceTypeCamera
        imagePicker.allowsEditing = true
        imagePicker.showsCameraControls = true;
        
        layerView = UIImageView()
        layerView.frame.size.width = self.view!.frame.size.height
        layerView.frame.size.height = self.view!.frame.size.height
        layerView.layer.position.y = 203
        layerView.layer.borderWidth = 3
        layerView.layer.cornerRadius = (self.view!.frame.size.height/2)
        //layerView.backgroundColor = UIColor.grayColor()
        
        imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.Front
        imagePicker.cameraOverlayView = layerView //3.0以后可以直接设置cameraOverlayView为overlay
        let  vc:UIViewController = self.view!.window!.rootViewController!       //.window?.rootViewController
        print("qqqqqqqqq")
        vc.presentViewController(imagePicker, animated: true, completion:nil)
        
    }
    
    
}