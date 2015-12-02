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
    
    var 製造角色按鈕: SKNode! = nil
    var 進入遊戲按鈕: SKNode! = nil
    var 角色們: SKNode! = nil
    
    var candidateCharacterNodes:[CharacterListNode?] = []
    var slots:[SKSpriteNode] = []
    var pickedCharacterNode: SKSpriteNode?
    var gestureRecognizer: UILongPressGestureRecognizer?
    

    override func didMoveToView(view: SKView) {
        
        
        loadBackground()
        loadStartButton()
        loadCharacterList()
        loadSlots()
        loadMainSlot()
        loadCharacterSelect()
        loadCharacter()
        loadPickedChracter()
        
        gestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongTap:")
        
        self.view!.addGestureRecognizer(gestureRecognizer!)
    
    
    NSNotificationCenter.defaultCenter().addObserverForName("PhotoPickerFinishedNotification", object:nil, queue:nil, usingBlock: { note in
        
            self.loadCharacter()
        })
    }
    
    func loadBackground(){
        let texture = SKTexture(image: UIImage(named: Constants.MainScene.Background)!)
        let background = SKSpriteNode(texture: texture, size: frame.size)
       
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        background.zPosition = -10
        addChild(background)
        
    }
    func loadCharacterList(){
        let texture = SKTexture(image: UIImage(named: Constants.MainScene.CharacterList)!)
        let wordCharacterList = SKSpriteNode(texture: texture, size: CGSizeMake(111.0,37.0))
        
        wordCharacterList.position = CGPoint(x: wordCharacterList.frame.width/2 + 15.0, y: self.frame.height-wordCharacterList.frame.height/2 - 33)
        addChild(wordCharacterList)
    }
    
    func loadCharacterSelect(){
        let texture = SKTexture(image: UIImage(named: Constants.MainScene.CharacterSelect)!)
        let characterSelect = SKSpriteNode(texture: texture, size: CGSizeMake(270.0,30.0))
        
        characterSelect.position = CGPoint(x: self.frame.midX , y: self.frame.height - 50)
        addChild(characterSelect)
    }
    
    
    func loadMainSlot(){
        let texture = SKTexture(image: UIImage(named: Constants.MainScene.MainSlot)!)
        let plusTexture = SKTexture(image: UIImage(named: Constants.MainScene.Plus)!)
        製造角色按鈕 = SKSpriteNode(texture: texture, size: CGSizeMake(250.0,250.0))
        let mainSlotPlus = SKSpriteNode(texture: plusTexture, size: CGSizeMake(50.0,50.0))
        
        製造角色按鈕.position = CGPoint(x: frame.midX,y: frame.midY - 18)
        製造角色按鈕.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(CGFloat(M_PI), duration:2)))
        mainSlotPlus.position = 製造角色按鈕.position
        mainSlotPlus.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.fadeInWithDuration(0.5),
            SKAction.waitForDuration(1),
            SKAction.fadeOutWithDuration(0.5)
            ]))
        )
        
        addChild(製造角色按鈕)
        addChild(mainSlotPlus)
        
    }
    
    func loadStartButton(){
        
        let texture = SKTexture(image: UIImage(named: Constants.MainScene.StartButton)!)
        進入遊戲按鈕 = SKSpriteNode(texture: texture, size: CGSizeMake(184.0,57.0))
        進入遊戲按鈕.position = CGPoint(x:frame.width - 進入遊戲按鈕.frame.width/2,y: 進入遊戲按鈕.frame.height/2)
        addChild(進入遊戲按鈕)
    }
    
    func loadSlots(){
        let texture = SKTexture(image: UIImage(named: Constants.MainScene.Slot)!)
        let plusTexture = SKTexture(image: UIImage(named: Constants.MainScene.Plus)!)
        
        let width:CGFloat = CGFloat(Constants.MainScene.SlotSize)
        let height:CGFloat = CGFloat(Constants.MainScene.SlotSize)
        for i in 0..<Constants.Character.MaxOfCandidateNumber {
            let slot = SKSpriteNode(texture: texture, size: CGSizeMake(width,height))
            
            let slotPlus = SKSpriteNode(texture: plusTexture, size: CGSizeMake(20.0,20.0))
            
           slotPlus.runAction(SKAction.repeatActionForever(SKAction.sequence([
                    SKAction.fadeInWithDuration(0.5),                  SKAction.waitForDuration(0.5),
                    SKAction.fadeOutWithDuration(0.5)
                ]))
            )
            
            slots.append(slot)
            slot.position = CGPoint(x: slot.frame.width/2 + 15 , y: CGFloat(75 + (i*90)))
            slot.addChild(slotPlus)
            addChild(slot)
        }
    }

    func loadCharacter(){
        
        let width:CGFloat = CGFloat(Constants.MainScene.SlotSize)
        let height:CGFloat = CGFloat(Constants.MainScene.SlotSize)
        
        if let candidateCharacters: [UIImage?] = CharacterManager.getCandidateCharactersFromLocalStorage(){
            if 角色們 != nil && 角色們.parent != nil {
                角色們.removeFromParent()
            }
            角色們 = SKNode()
            candidateCharacterNodes = []
            for (i,candidateCharacter) in candidateCharacters.enumerate() {
                
                if candidateCharacter != nil {
                    let candidateCharacterNode = CharacterListNode(texture: SKTexture(image: candidateCharacter!),size: CGSizeMake(width,height))
                    candidateCharacterNodes.append(candidateCharacterNode)
                    candidateCharacterNode.setInitialPosition(CGPoint(x: candidateCharacterNode.frame.width/2 + 15 , y: CGFloat(75 + (i*90))))
                    角色們.addChild(candidateCharacterNode)
                }else{
                    candidateCharacterNodes.append(nil)
                }
            }
            角色們.zPosition = 1
            addChild(角色們)
            
            pickCharacter(CharacterManager.getPickedCharacterNumber())
        }
        
    }
    
    func loadPickedChracter(){
        
        deletePickedCharacter()
        
        if let pickedCharacter = CharacterManager.getPickedCharacterFromLocalStorage() {
            
            pickedCharacterNode = SKSpriteNode(texture: SKTexture(image: pickedCharacter),size: CGSizeMake(100,100))
            pickedCharacterNode!.position = CGPoint(x:frame.midX,y:frame.midY - 18)
            pickedCharacterNode!.zPosition = 1
            addChild(pickedCharacterNode!)
        }
    }
    
    func deletePickedCharacter(){
        pickedCharacterNode?.removeFromParent()
        pickedCharacterNode = nil
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let location = touches.first?.locationInNode(self){
            //if 製造角色按鈕.containsPoint(location){
            if pickedCharacterNode == nil && hypotf(Float(製造角色按鈕.position.x - location.x), Float(製造角色按鈕.position.y - location.y)) < Float(製造角色按鈕.frame.width/2 - 30) {

                Tools.playSound(Constants.Audio.CameraButton, node: self)


                let  vc:UIViewController = self.view!.window!.rootViewController!       
                vc.presentViewController(CameraViewController(), animated: false, completion:nil)

            }
                
                
            else if 進入遊戲按鈕.containsPoint(location){

                Tools.playSound(Constants.Audio.TransButton, node: self)

                let transition = SKTransition.revealWithDirection(SKTransitionDirection.Up, duration: 0.5)
                
                removeAllChildren()
                self.view!.removeGestureRecognizer(gestureRecognizer!)
                let nextScene = PlayModeScene(size: scene!.size)
                nextScene.scaleMode = .AspectFill
                scene?.view?.presentScene(nextScene, transition: transition)
            }
            
            //Execute the block when characted list has been tapped
            if 角色們 != nil {
                for (i,candidateCharacterNode) in candidateCharacterNodes.enumerate() {
 
                    if let candidateCharacterNode = candidateCharacterNode {
                        //which character has been tapped
                        if candidateCharacterNode.containsPoint(location){
                            
                            let node = nodeAtPoint(location)
                            if node.name == "DeleteButton" {
                                deleteChracter(i)
                                break
                            }
                            pickCharacter(i)
                        Tools.playSound(Constants.Audio.Pause, node: self)
                        }
                        candidateCharacterNode.removeDeleteButton()
                    }
                }
            }
            
            if slots.count != 0 {
                for (i,slot) in slots.enumerate(){
                    if slot.containsPoint(location) && candidateCharacterNodes[i] == nil {
                        
                        let  vc:UIViewController = self.view!.window!.rootViewController!
                        let cameraViewController = CameraViewController()
                        cameraViewController.currentPicking = i
                        vc.presentViewController(cameraViewController, animated: false, completion:nil)
                    }
                }
            }
        }
    }
    func pickCharacter(index: Int){
        
        if index < Constants.CharacterManager.maxOfCandidateNumber {
            for candidateCharacterNode in candidateCharacterNodes {
                candidateCharacterNode?.removePickedBorder()
            }
            candidateCharacterNodes[index]?.loadPickedBorder()
            CharacterManager.setPickedCharacterNumber(index)
            loadPickedChracter()
        }
    }
    
    func deleteChracter(index: Int){
        CharacterManager.deleteCharacterFromLocalStorage(index)
        candidateCharacterNodes[index]?.removeFromParent()
        candidateCharacterNodes[index] = nil
        
        //need pick another existed chracter
        for i in (0..<Constants.CharacterManager.maxOfCandidateNumber).reverse() {
            if candidateCharacterNodes[i] != nil {
                pickCharacter(i)
                return
            }
        }
        deletePickedCharacter()
    }
    
    func handleLongTap(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.Began{
            if let view = self.view {
                let touchLocationInView: CGPoint = gestureRecognizer.locationInView(view)
                let touchLocationInScene:CGPoint = self.convertPointFromView(touchLocationInView)
                
                for candidateCharacterNode in candidateCharacterNodes {
                    if let candidateCharacterNode = candidateCharacterNode {
                        if candidateCharacterNode.containsPoint(touchLocationInScene){
                            candidateCharacterNode.loadDeleteButton()
                            
                        }
                    }
                }
            }
        }
    }
}

class CharacterListNode: SKSpriteNode{
    var originPosition: CGPoint?
    
    func loadPickedBorder(){
        
        let borderWidth:CGFloat = 5.0
        let border = SKShapeNode(circleOfRadius: (frame.size.width/2 - borderWidth + 3))
        
        border.name = "Border"
        border.lineWidth = borderWidth
        border.strokeColor = UIColor.whiteColor()
        border.zPosition = 1
        addChild(border)
    }
    
    func removePickedBorder(){
        childNodeWithName("Border")?.removeFromParent()
    }
    
    func loadDeleteButton(){
        let texture = SKTexture(image: UIImage(named: Constants.MainScene.DeleteButton)!)
        let deleteButton = SKSpriteNode(texture: texture,size: CGSizeMake(45,45))
        deleteButton.name = "DeleteButton"
        deleteButton.position = CGPoint(x: frame.width,y: 0)
        
        addChild(deleteButton)
        shake()
    }
    
    func removeDeleteButton(){
        childNodeWithName("DeleteButton")?.removeFromParent()
        stopShaking()
    }
    
    func shake(){
        runAction(SKAction.repeatActionForever(SKAction.shake(5, amplitudeX: 8, amplitudeY: 8, frequency: 0.05)), withKey:"characterDoShake")
    }
    
    func stopShaking(){
        removeActionForKey("characterDoShake")
        goBackToOriginalPosition()
        
    }
    
    func setInitialPosition(position :CGPoint){
        self.position = position
        originPosition = position
    }
    
    func goBackToOriginalPosition(){
        if originPosition != nil {
            position = originPosition!
        }
    }
}