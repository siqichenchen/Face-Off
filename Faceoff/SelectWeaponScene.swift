//
//  SelectWeaponScene.swift
//  Select_Weapons
//
//  Created by Shao-Hsuan Liang on 9/26/15.
//  Copyright (c) 2015 Liang. All rights reserved.
//


//need constrant confirm button

import SpriteKit

class SelectWeaponScene: SKScene {
    
    var WEAPONS:[SKNode] = [SKNode]()
    var forward_btn: SKNode! = nil
    var back_btn: SKNode! = nil
    var centerBlock: SKSpriteNode! = nil
    
    var box1: SKNode! = nil
    var box2: SKNode! = nil
    var box3: SKNode! = nil
    
    var select_count: Int = 0;
    
    var Weapon1: SKSpriteNode! = nil
    var Weapon2: SKSpriteNode! = nil
    var Weapon3: SKSpriteNode! = nil
    var selectedWeapons: [SKSpriteNode?] = [nil,nil,nil]
    
    var weaponArray:[String?] = [nil,nil,nil]
    
    var count: Int = 0;
    var did_tap: Bool = false;

    var did_shrink: NSInteger = 0;
    var arrayOfStrings: [String] = Array(Constants.Weapon.Sets.keys)
    var arrayOfDescription: [String] = Array(Constants.Weapon.Sets.values)
    
    var descrioptionLable: SKLabelNode! = nil
    
    var 返回按鈕: SKNode! = nil
    var 進入遊戲按鈕: SKNode! = nil
    var touchRect: SKSpriteNode! = nil
    
    
    let Distance = CGFloat(105.0)
    
    override func didMoveToView(view: SKView) {
        
        
        loadBackground()
        loadCenterBlock()
        loadLeftButton()
        loadRightButton()
        loadBackButton()
        loadStartButton()
        loadSlots()
        loadWeaponSelect()
        loadDescriptionLabel()
        loadWeaponSlide()
        
    }
    
    func loadWeaponSlide(){
        for var i=0; i<arrayOfStrings.count; i++ {
            var weapon: SKNode! = nil
            let Te = SKTexture (imageNamed:arrayOfStrings[i])
            weapon = SKSpriteNode(texture:Te, size: CGSize(width: 80, height: 80))
            
            //just for initial scene
            if(i==0){
                weapon.xScale = 1
                weapon.yScale = 1
            }
            else{
                weapon.xScale = 0.5
                weapon.yScale = 0.5
            }
            
            weapon.position = CGPointMake((CGFloat(i)*Distance), 0);
            weapon.name = arrayOfStrings[i]
            
            WEAPONS.append(weapon)
            centerBlock.addChild(weapon)
        }
    }
    
    func loadBackground(){
        let texture = SKTexture(image: UIImage(named: Constants.SelectWeaponScene.Background)!)
        let background = SKSpriteNode(texture: texture, size: frame.size)
        
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        background.zPosition = -10
        addChild(background)
    }
    
    func loadCenterBlock(){
        let image = UIImage(named: Constants.SelectWeaponScene.CenterBlock)!
        let texture = SKTexture(image: image)
        let cropNode = SKCropNode()
        
        centerBlock = SKSpriteNode(texture: texture, size: CGSizeMake(image.size.width * 0.38,image.size.height * 0.33))
        //centerBlock.position = CGPointMake(frame.midX, frame.midY)
        //addChild(centerBlock)
        //centerBlock.zPosition = -5
            
        //Constants.SelectWeaponScene.centerBlockZ
        let crop = SKSpriteNode(color: UIColor.blackColor(), size: centerBlock.size)
        //crop.position = CGPointMake(frame.midX, frame.midY)
        
        cropNode.position = CGPointMake(frame.midX, frame.midY)
        cropNode.zPosition = -5
        cropNode.maskNode = crop
        cropNode.addChild(centerBlock)
        addChild(cropNode)
        


    }
    
    func loadWeaponSelect(){
        let texture = SKTexture(image: UIImage(named: Constants.SelectWeaponScene.WeaponSelect)!)
        let weaponSelect = SKSpriteNode(texture: texture, size: CGSizeMake(270.0,25.0))
        
        weaponSelect.position = CGPoint(x: self.frame.midX, y: self.frame.midY + centerBlock.frame.height/2 + 50)
        addChild(weaponSelect)
        
    }
    
    func loadLeftButton(){
        back_btn = SKSpriteNode(imageNamed:Constants.SelectWeaponScene.LeftButton)
        back_btn.position = CGPointMake(frame.midX - centerBlock!.frame.width/2 - 40, frame.midY)
        back_btn.name = "back_btn"
        back_btn.xScale = 0.4
        back_btn.yScale = 0.4
        back_btn.zPosition = 1.0
        addChild(back_btn)
    }
    
    func loadRightButton(){
        forward_btn = SKSpriteNode(imageNamed:Constants.SelectWeaponScene.RightButton)
        forward_btn.position = CGPointMake(frame.midX + centerBlock!.frame.width/2 + 40, frame.midY)
        forward_btn.name = "forward_btn"
        forward_btn.xScale = 0.4
        forward_btn.yScale = 0.4
        forward_btn.zPosition = 1.0
        addChild(forward_btn)
    }
    
    func loadBackButton(){
        
        let texture = SKTexture(image: UIImage(named: Constants.BuildConnectionScene.BackButton)!)
        返回按鈕 = SKSpriteNode(texture: texture, size: CGSizeMake(CGFloat(Constants.Scene.BackButtonSizeWidth) ,CGFloat(Constants.Scene.BackButtonSizeHeight)))
        返回按鈕.position = CGPoint(x:返回按鈕.frame.width/2,y: 返回按鈕.frame.height/2)
        addChild(返回按鈕)
    }
    
    func loadStartButton(){
        
        let texture = SKTexture(image: UIImage(named: Constants.MainScene.StartButton)!)
        進入遊戲按鈕 = SKSpriteNode(texture: texture, size: CGSizeMake(182.0,54.0))
        進入遊戲按鈕.position = CGPoint(x:frame.width - 進入遊戲按鈕.frame.width/2 + 20,y: 進入遊戲按鈕.frame.height/2 + 8)
        addChild(進入遊戲按鈕)
    }

    func loadDescriptionLabel(){
        descrioptionLable = SKLabelNode (fontNamed: Constants.Font)
        descrioptionLable.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMaxY(self.frame)*0.25)
        descrioptionLable.fontSize = 20
        addChild(descrioptionLable)
        
        descrioptionLable.text = arrayOfDescription[0]
        
    }
    
    func loadSlots(){
        
        var slots :[SKSpriteNode?] = [nil,nil,nil]
        for (i,_) in slots.enumerate() {
            slots[i] = SKSpriteNode(imageNamed: Constants.SelectWeaponScene.Slot)
            
            slots[i]!.xScale = 0.4
            slots[i]!.yScale = 0.4
            slots[i]!.position = CGPointMake( 70,frame.midY*0.75 + CGFloat(i*75))
            slots[i]?.zPosition = 1
            addChild(slots[i]!)
            
            selectedWeapons[i] = SKSpriteNode(imageNamed: "weapon_blank")
            selectedWeapons[i]!.xScale = 0.8
            selectedWeapons[i]!.yScale = 0.7
            selectedWeapons[i]!.zPosition = 2
            
            slots[i]!.addChild(selectedWeapons[i]!)
        }
    }
    
    func transitionForNextScene(nextScene: SKScene){
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Up, duration: 0.5)
        removeAllChildren()
        nextScene.scaleMode = .AspectFill
        scene?.view?.presentScene(nextScene, transition: transition)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if let location = touches.first?.locationInNode(self){
            if 返回按鈕.containsPoint(location){
                Tools.playSound(Constants.Audio.TransButton, node: self)
                let nextScene = BuildConnectionScene(size: scene!.size)
                transitionForNextScene(nextScene)
            }
            else if forward_btn.containsPoint(location) {
                if(!did_tap){
                    count++;
                    for eachChild in WEAPONS {
                        if(count < arrayOfStrings.count){
                            if(eachChild.name==arrayOfStrings[count]){
                                enlarge_animation(eachChild, RorL:0, distance: Distance, duration:0.5)
                            }else{
                                shrink_animation(eachChild, RorL:0, distance: Distance, duration:0.5)
                            }
                        }
                        else{
                            scrollToFirst(eachChild, RorL:0, distance: CGFloat(count-1)*Distance, duration:0.5)
                            if(eachChild.name == arrayOfStrings.first!){
                                let enlarge = SKAction.scaleTo(1, duration:0.5)
                                eachChild.runAction(enlarge)
                            }
                            else if(eachChild.name == arrayOfStrings.last!){
                                let shrink = SKAction.scaleTo(0.5, duration:0.5)
                                eachChild.runAction(shrink)
                            }
                        }
                    }
                    if(count >= arrayOfStrings.count) {
                        count = 0;
                    }
                    descrioptionLable.text = arrayOfDescription[count]
                }
                did_tap = true;
            }
            else if back_btn.containsPoint(location) {
                if(!did_tap){
                    count--;
                    for eachChild in WEAPONS {
                        if(count >= 0){
                            if(eachChild.name==arrayOfStrings[count]){
                                enlarge_animation(eachChild, RorL:1, distance: Distance, duration:0.5)
                            }
                            else {
                                shrink_animation(eachChild, RorL:1, distance: Distance, duration:0.5)
                            }
                        }
                        else{
                            scrollToFirst(eachChild, RorL:1, distance: CGFloat(arrayOfStrings.count-1)*Distance, duration:0.5)
                            if(eachChild.name == arrayOfStrings.last!){
                                let enlarge = SKAction.scaleTo(1, duration:0.5)
                                eachChild.runAction(enlarge)
                            }
                            if(eachChild.name == arrayOfStrings.first!){
                                let shrink = SKAction.scaleTo(0.5, duration:0.5)
                                eachChild.runAction(shrink)
                            }
                        }
                    }
                    if(count < 0) {
                        count = arrayOfStrings.count-1;
                    }
                    descrioptionLable.text = arrayOfDescription[count]
                }
                did_tap = true;
            }
                
            else if 進入遊戲按鈕.containsPoint(location) {
                
                Tools.playSound(Constants.Audio.TransButton, node: self)
                
                let transition = SKTransition.revealWithDirection(SKTransitionDirection.Up, duration: 0.5)
                
                for weapon in weaponArray {
                    if weapon == nil {
                        return
                    }
                }
                if !btAdvertiseSharedInstance.single{
                    
                    while !EnemyCharacterLoader.isLoaded() {
                        sleep(1)
                    }
                    
                    let nextScene = GameScene2(size: scene!.size)
                    nextScene.scaleMode = SKSceneScaleMode.ResizeFill
                    nextScene.weaponManager.candidateWeaponTypes = weaponArray
                    
                    scene?.view?.presentScene(nextScene, transition: transition)
                    
                }
                else{
                    
                    let nextScene = GameScene3(size: scene!.size)
                    nextScene.scaleMode = SKSceneScaleMode.ResizeFill
                    nextScene.weaponManager.candidateWeaponTypes = weaponArray
                    
                    scene?.view?.presentScene(nextScene, transition: transition)
                }
                

            }
            
            else if(self.nodeAtPoint(location).name != nil && WEAPONS.contains(self.nodeAtPoint(location))){
                
                //check if it is in touchRect
                touchRect = SKSpriteNode(texture: nil, size:  centerBlock.size)
                touchRect.position = CGPointMake(frame.midX, frame.midY)
                addChild(touchRect)
                
                if touchRect!.containsPoint(location){
                    touchRect?.removeFromParent()
                    let name:String = self.nodeAtPoint(location).name!
                    let nameOfIndex = arrayOfStrings.indexOf(name)!
                    for eachChild in WEAPONS {
                        if(eachChild.name == name){
                            
                            let move_dis:CGFloat = CGFloat(abs(nameOfIndex-count))*Distance
                            if(nameOfIndex==count){}
                            else if(nameOfIndex>count){
                                enlarge_animation(eachChild, RorL:0, distance: move_dis, duration:0.5)
                            }
                            else{
                                enlarge_animation(eachChild, RorL:1, distance: move_dis, duration:0.5)
                            }
                            
                            selectedWeapons[select_count]!.texture = SKTexture(imageNamed: name)
                            Tools.playSound(Constants.Audio.SelectWeaponButton, node: self)
                            descrioptionLable.text = arrayOfDescription[nameOfIndex]
                            weaponArray[select_count] = eachChild.name!
                            select_count = (++select_count) % 3
                            
                            
                        }else{
                            
                            let move_dis2:CGFloat = CGFloat(abs(nameOfIndex-count))*Distance
                            
                            if(nameOfIndex==count){}
                            else if(nameOfIndex>count){
                                shrink_animation(eachChild, RorL:0, distance: move_dis2, duration:0.5)
                            }
                            else{
                                shrink_animation(eachChild, RorL:1, distance: move_dis2, duration:0.5)
                            }
                        }
                    }
                    
                    let add_count:Int = abs(nameOfIndex-count)
                    
                    if(nameOfIndex==count){
                    }
                    else if(nameOfIndex>count){
                        count += add_count
                    }
                    else{
                        count -= add_count
                    }

                }
                touchRect?.removeFromParent()
            }
        }
    }
    
    func enlarge_animation(weapon: SKNode, RorL: Int, distance: CGFloat, duration: Double){
        
        let moveToRight = SKAction.moveTo(CGPointMake(weapon.position.x+distance,weapon.position.y), duration:duration)
        let moveToLeft = SKAction.moveTo(CGPointMake(weapon.position.x-distance,weapon.position.y), duration:duration)
        
        let enlarge = SKAction.scaleTo(1, duration:duration)
        
        weapon.runAction(enlarge);
        Tools.playSound(Constants.Audio.WeaponEnlarge, node: weapon)
        
        if(RorL==1){
            weapon.runAction(moveToRight, completion: {
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.did_tap = false;
                }
            })
        }
        else{
            weapon.runAction(moveToLeft, completion: {
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.did_tap = false;
                }
            })
        }
        
    }
    func shrink_animation(weapon: SKNode,  RorL: CGFloat, distance: CGFloat, duration: Double){
        
        let moveToRight = SKAction.moveTo(CGPointMake(weapon.position.x+distance,weapon.position.y), duration:duration)
        let moveToLeft = SKAction.moveTo(CGPointMake(weapon.position.x-distance,weapon.position.y), duration:duration)
        
        let shrink = SKAction.scaleTo(0.5, duration:duration)
        
        weapon.runAction(shrink);
        
        if(RorL==1){
            weapon.runAction(moveToRight, completion: {
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.did_tap = false;
                    
                }
            })
            
        }
        else{
            weapon.runAction(moveToLeft, completion: {
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.did_tap = false;
                    
                }
            })
            
        }
        
        
    }
    
    func scrollToFirst(weapon: SKNode, RorL: CGFloat, distance: CGFloat, duration: Double){
        
        
        Tools.playSound(Constants.Audio.WeaponEnlarge, node: self)
        
        let moveToLeft = SKAction.moveTo(CGPointMake(weapon.position.x-distance,weapon.position.y), duration:duration)
        let moveToRight = SKAction.moveTo(CGPointMake(weapon.position.x+distance,weapon.position.y), duration:duration)
        
        if(RorL == 1){
            weapon.runAction(moveToLeft, completion: {
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.did_tap = false;
                    
                }
            })
            
        }
        else{
            weapon.runAction(moveToRight, completion: {
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.did_tap = false;
                    
                }
                
            })
            
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
