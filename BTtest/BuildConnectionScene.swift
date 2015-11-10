//
//  BuildConnectionScene.swift
//  BTtest
//
//  Created by Sunny Chiu on 10/27/15.
//  Copyright © 2015 Liang. All rights reserved.
//


import SpriteKit
import MultipeerConnectivity

class BuildConnectionScene: SKScene {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var scrollnode = ScrollNode()
    var peers: [MCPeerID]?
    var statusnode = SKLabelNode(fontNamed: "Chalkduster")
    var 返回按鈕: SKNode! = nil
    var 遊戲按鈕: SKNode! = nil
    let background: SKNode! = SKSpriteNode(imageNamed: "spaceship4.jpg")
    var Img: UIImage! = nil
     
    override func didMoveToView(view: SKView) {
        
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.scene?.size = frame.size
        background.setScale(0.5)
        background.zPosition = -100
        
        addChild(background)
     
        // Start the Bluetooth advertise process
        btAdvertiseSharedInstance
        
        // Start the Bluetooth discovery process
        btDiscoverySharedInstance
        
        
        
        
        
        
        返回按鈕 = SKSpriteNode(color: UIColor.redColor().colorWithAlphaComponent(0.3), size: CGSize(width: 50, height: 30))
        返回按鈕.position = CGPoint(x:CGRectGetMinX(self.frame)+40,y:CGRectGetMinY(self.frame)+CGFloat(30.0))
        addChild(返回按鈕)
        
        let 返回文字 = SKLabelNode(fontNamed:"Chalkduster")
        返回文字.text = "Back";
        返回文字.fontSize = 14;
        返回文字.position = CGPoint(x:CGFloat(0),y:CGFloat(-5))
        返回按鈕.addChild(返回文字)

        
        遊戲按鈕 = SKSpriteNode(color: UIColor.redColor().colorWithAlphaComponent(0.3), size: CGSize(width: 50, height: 30))
        遊戲按鈕.position = CGPoint(x:CGRectGetMaxX(self.frame)-40,y:CGRectGetMinY(self.frame)+CGFloat(30.0))
        addChild(遊戲按鈕)
        
        let 遊戲文字 = SKLabelNode(fontNamed:"Chalkduster")
        遊戲文字.text = "Go!";
        遊戲文字.fontSize = 14;
        遊戲文字.position = CGPoint(x:CGFloat(0),y:CGFloat(-5))
        遊戲按鈕.addChild(遊戲文字)

        
        
        
        
        addChild(scrollnode)

        
        statusnode.fontSize = 50
        statusnode.position = CGPointMake(frame.midX, frame.midY)
        statusnode.text = "Hi"
        addChild(statusnode)
        scrollnode.setScrollingView(view)
       
        updateScene()
        
    }
    
    func updateScene(){
       // peers = connector.getPeers()
        if peers != nil {
            for (i,peer) in peers!.enumerate() {
                let peerNode = SKLabelNode()
                peerNode.text = peer.displayName;
                peerNode.fontSize = 30;
                peerNode.position = CGPoint(x:CGRectGetMidX(self.frame),y:CGFloat(i*40)+50)
                scrollnode.addChild(peerNode)
            }
        }
    }
    
    func statusLabel(statusName: String) -> SKLabelNode{
        
        statusnode.text = statusName
        
        return statusnode
    }
    
    
    func foundPeer(notification: NSNotification){
        updateScene()
        
        //statusLabel("Found Peer")
        
        print("foundPeer",peers)
    }
    func losePeer(notification: NSNotification){
        updateScene()
        
        statusLabel("Lost Peer")
        
        print("losePeer",peers)
        
    }
    
    func invited(notification: NSNotification){
        updateScene()
        statusLabel("Invited!")
        
    }
    
    
    func connected(notification: NSNotification){
        print("connected")
        
        statusLabel("Connected")
        
        transitionForNextScene(GameScene(size: scene!.size))
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let location = touches.first?.locationInNode(scrollnode){
            let peerNodes = scrollnode.children
            for peerNode in peerNodes{
                if peerNode.containsPoint(location){
                    for peer in peers! {
                        if peer.displayName == (peerNode as! SKLabelNode).text {
                            //connector.invitePeer(peer)
                            
                            statusLabel("Invite!")
                        }
                    }
                }
            }
        }
        
        if let location = touches.first?.locationInNode(self){
            if 返回按鈕.containsPoint(location){
                返回按鈕.runAction(SKAction.playSoundFileNamed(FaceoffGameSceneEffectAudioName.ButtonAudioName.rawValue, waitForCompletion: false))
                let nextScene = MainScene(size: scene!.size)
                transitionForNextScene(nextScene)
            }
        }
        
        
        if let location = touches.first?.locationInNode(self){
            if 遊戲按鈕.containsPoint(location){
                遊戲按鈕.runAction(SKAction.playSoundFileNamed(FaceoffGameSceneEffectAudioName.ButtonAudioName.rawValue, waitForCompletion: false))
                let nextScene = SelectWeaponScene(size: scene!.size)
                nextScene.Img = Img
                transitionForNextScene(nextScene)
            }
        }
    }
    

    
    func transitionForNextScene(nextScene: SKScene){
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Up, duration: 0.5)
        removeAllChildren()
        nextScene.scaleMode = .AspectFill
        scene?.view?.presentScene(nextScene, transition: transition)
    }
    
    
    
    override func update(currentTime: NSTimeInterval) {
        
    }
}