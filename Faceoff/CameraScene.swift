//
//  GameScene.swift
//  BTtest
//
//  Created by Shao-Hsuan Liang on 10/18/15.
//  Copyright (c) 2015 Liang. All rights reserved.
//

import SpriteKit
import CoreMotion
import AVFoundation
import AudioToolbox

extension SKAction {
    class func shake(duration:CGFloat, amplitudeX:Int = 3, amplitudeY:Int = 3) -> SKAction {
        let numberOfShakes = duration / 0.015 / 2.0
        var actionsArray:[SKAction] = []
        for _ in 1...Int(numberOfShakes) {
            let dx = CGFloat(arc4random_uniform(UInt32(amplitudeX))) - CGFloat(amplitudeX / 2)
            let dy = CGFloat(arc4random_uniform(UInt32(amplitudeY))) - CGFloat(amplitudeY / 2)
            let forward = SKAction.moveByX(dx, y:dy, duration: 0.015)
            let reverse = forward.reversedAction()
            actionsArray.append(forward)
            actionsArray.append(reverse)
        }
        return SKAction.sequence(actionsArray)
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    // Game End
    var gameEnding: Bool = false
    
    // Contact
    var contactQueue = Array<SKPhysicsContact>()
    
    // Bitmask Categories
    let kInvaderCategory: UInt32 = 0x1 << 0
    let kShipFiredBulletCategory: UInt32 = 0x1 << 1
    let kShipCategory: UInt32 = 0x1 << 2
    let kSceneEdgeCategory: UInt32 = 0x1 << 3
    let kInvaderFiredBulletCategory: UInt32 = 0x1 << 4
    let bulletCategory:UInt32 = 0x1 << 5
    let kStarBonusCategory: UInt32 = 0x1 << 6
    var Img: UIImage! = nil
    
    // Bullet type
    enum BulletType: String {
        case ShipFired = "ShipFired"
        case InvaderFired = "InvaderFired"
        case BonusBullet = "BonusBullet"
        var description: String {
            return self.rawValue
        }
        case Bonus
        
    }
    
    
    
    // Invader movement direction
    enum InvaderMovementDirection {
        case Right
        case Left
        case DownThenRight
        case DownThenLeft
        case None
    }
    
    //1
    enum InvaderType {
        case A
        case B
        case C
    }
    
    //2
    let kInvaderSize = CGSize(width: 24, height: 16)
    let kInvaderGridSpacing = CGSize(width: 12, height: 12)
    let kInvaderRowCount = 6
    let kInvaderColCount = 6
    
    // 3
    let kInvaderName = "invader"
    
    // 4
    let kShipSize = CGSize(width: 30, height: 16)
    let kShipName = "ship"
    
    // 5
    let kScoreHudName = "scoreHud"
    let kHealthHudName = "healthHud"
    
    let kMinInvaderBottomHeight: Float = 32.0
    
    
    // Score and Health
    var score: Int = 0
    var shipHealth: Float = 1.0
    
    // Bullets utils
    let kShipFiredBulletName = "shipFiredBullet"
    let kInvaderFiredBulletName = "invaderFiredBullet"
    let kShipFiredUltimateName = "shipFiredUltimate"
    
    let kBulletSize = CGSize(width:4, height: 8)
    
    // Private GameScene Properties
    
    var contentCreated: Bool = false
    
    // Invaders Properties
    var invaderMovementDirection: InvaderMovementDirection = .Right
    var timeOfLastMove: CFTimeInterval = 0.0
    var timePerMove: CFTimeInterval = 1.0
    
    // Accelerometer
    let motionManager: CMMotionManager = CMMotionManager()
    
    // Queue
    var tapQueue: Array<Int> = []
    
    // Object Lifecycle Management
    
    var ship: SKSpriteNode! = nil
    var shipVelocity = 500.0
    
    // 集氣用---------------------
    var node: SKSpriteNode? = nil
    var sdfsd: Double = 1.0
    let laser_height = 1000.0
    var laser_width = 400.0
    let action = SKAction.shake(0.5, amplitudeX: 10, amplitudeY: 10)
    //var laser = SKShapeNode(rectOfSize: CGSize(width: 200, height: 400))
    //var laser : SKSpriteNode! = nil
    var mutex = false
    var bulletDidFire = false
    var startMoving = true;
    var lastTimeStamp = 0.0
    var energyBlastAnim = [SKTexture]()
    var animation = SKAction()
    var diff = 0.0
    var laser_final_width = 0.0
    var BGM : AVAudioPlayer! = nil
    var kameCharge : AVAudioPlayer! = nil
    var kameEmmit : AVAudioPlayer! = nil
    var WarningSiren : AVAudioPlayer! = nil
    
    //--------------------------
    
    
    var ultimateTimer : NSTimer! = nil
    var timer2 : NSTimer! = nil
    var mpTimer : NSTimer! = nil
    var oppoMpTimer : NSTimer! = nil
    
    var burnTimer : NSTimer! = nil
    var frozenTimer : NSTimer! = nil
    
    var frozenEffectImg = SKSpriteNode()
    var burnEffectImg = SKSpriteNode()
    
    var emitter :SKEmitterNode! = nil
    var profemitter :SKEmitterNode! = nil
    
    var attackedCount = 0;
    
    var healthBar = SKSpriteNode()
    var healthBarBack = SKSpriteNode()
    var latestMinusHealth : CGFloat = 0.0
    var latesHealth : CGFloat = 0.0
    
    var opponenthealthBar = SKSpriteNode()
    var opponenthealthBarBack = SKSpriteNode()
    var opponentlatestMinusHealth : CGFloat = 0.0
    var opponentlatesHealth : CGFloat = 0.0
    
    var MpBar = SKSpriteNode()
    var opponentMpBar = SKSpriteNode()
    var mpValue : CGFloat = 0.0
    var opponentMpValue : CGFloat = 0.0
    
    let kBar = "ship"
    var oppoPosHint : SKSpriteNode! = nil
    var ultimateHint : SKSpriteNode! = nil
    
    
    //////bonus bullet//////
    let starBonusName = "starbonusnode"
    let bulletName = "bulletnode"
    let playerName = "playernode"
    let starName = "starnode"
    var weaponType = BulletType.ShipFired
    
    
    func randomNumber(maximum: CGFloat) -> CGFloat {
        
        let maxInt = UInt32(maximum)
        
        let result = arc4random_uniform(maxInt)
        
        return CGFloat(result)
    }
    
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        
        
        burnTimerStart()
        
        frozenTimerStart()
        
        
        
        if (!self.contentCreated) {
            self.createContent()
            self.contentCreated = true
            
            // Accelerometer starts
            self.motionManager.startAccelerometerUpdates()
            
            // SKScene responds to touches
            self.userInteractionEnabled = true
            
            self.physicsWorld.contactDelegate = self
        }
        
        let laser = SKSpriteNode(imageNamed: "a01")
        laser.name = "laser"
        laser.size.width = 400
        self.initEnergyBlastScene()
        animation = SKAction.animateWithTextures(energyBlastAnim, timePerFrame: 0.1)
        
        oppoPosHint = SKSpriteNode(imageNamed: "prof")
        oppoPosHint.position = CGPoint(x: -100,y: -100)
        oppoPosHint.xScale = 0.3
        oppoPosHint.yScale = 0.3
        self.addChild(oppoPosHint)
        
        
        // Watch Bluetooth connection
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("beginFight"), name: "beginFight", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("ApponentFireShipBullets:"), name: "getLocation", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("ApponentFireShipUltimate:"), name: "getUltimateLocation", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("ultimateHint:"), name: "getUltimateHint", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("hitOpponent:"), name: "hitOpponent", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("bonusHitOpponent:"), name: "bonusHitOpponent", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("realTimePos:"), name: "realTimePos", object: nil)
        
        //opponentlatesHealth = (self.view?.bounds.size.height)!
        
        /////////////////////////bonus bullet////////////////////////////
        let slideStarBonus = SKAction.sequence([SKAction.runBlock({
            
            let starBonusNode = self.makeBulletOfType(BulletType.Bonus)
            
            let direction = arc4random_uniform(3)
            
            var xPower: CGFloat?
            
            var yPower: CGFloat?
            
            // top
            if(direction == 0) {
                xPower = (self.randomNumber(20) - 10) / 10
                
                yPower = self.randomNumber(15) / 15 * -1
                
                starBonusNode.position = CGPointMake(starBonusNode.size.width / 2 + self.randomNumber(self.size.width - starBonusNode.size.width * 2), self.size.height - starBonusNode.size.height / 2)
            }
            // left
            if(direction == 1) {
                xPower = self.randomNumber(15) / 15
                
                yPower = (self.randomNumber(20) - 10) / 10
                
                starBonusNode.position = CGPointMake(starBonusNode.size.width / 2, starBonusNode.size.height / 2 + self.randomNumber(self.size.height - starBonusNode.size.height * 2))
            }
            
            // right
            if(direction == 2) {
                xPower = self.randomNumber(15) / 15 * -1
                
                yPower = (self.randomNumber(20) - 10) / 10
                
                starBonusNode.position = CGPointMake(self.size.width - starBonusNode.size.width / 2, starBonusNode.size.height / 2 + self.randomNumber(self.size.height - starBonusNode.size.height * 2))
            }
            
            self.addChild(starBonusNode)
            
            starBonusNode.physicsBody?.applyImpulse(CGVectorMake(xPower!, yPower!))
            
        }), SKAction.waitForDuration(15.0)])
        
        self.runAction(SKAction.repeatAction(slideStarBonus, count: 500))
        
        
    }
    
    func initEnergyBlastScene() {
        let ebAtlas = SKTextureAtlas(named: "animation")
        energyBlastAnim = []
        
        for index in 1...ebAtlas.textureNames.count {
            let imgName = String(format: "a%02d", index)
            energyBlastAnim += [ebAtlas.textureNamed(imgName)]
        }
    }
    
    
    func createContent() {
        
        
        physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        physicsBody!.categoryBitMask = kSceneEdgeCategory
        
        
        setupShip()
        
        setupHealthBar()
        
        setupOpponentHealthBar()
        
        setupMpBar()
        
        setupOpponentMpBar()
        
        loadBackground()
        
        burnTimerStart()
        
        frozenTimerStart()
        
        //qq()
        
        //setupHud()
        
        // 2 black space color
        self.backgroundColor = SKColor.blackColor()
    }
    
    func loadBackground() {
        guard let _ = childNodeWithName("background") as! SKSpriteNode? else {
            let texture = SKTexture(image: UIImage(named: "background4.jpg")!)
            let node = SKSpriteNode(texture: texture)
            node.xScale = 0.5
            node.yScale = 0.5
            node.position = CGPoint(x: frame.midX, y: frame.midY)
            node.zPosition = -100
            //    self.physicsWorld.gravity = CGVectorMake(0, gravity)
            
            addChild(node)
            return
        }
    }
    
    
    
    
    func setupHealthBar() {
        
        /*
        healthBarBack = self.makeHealthBarBack()
        healthBarBack.position = CGPoint(x: ship.position.x, y: ship.position.y + 50)
        healthBar = self.makeHealthBar()
        healthBar.position = CGPoint(x: ship.position.x, y: ship.position.y + 50)
        */
        
        
        healthBarBack = self.makeHealthBarBack()
        healthBarBack.position = CGPoint(x: (self.view?.bounds.size.width)!-2.5, y: (self.view?.bounds.size.height)!/2)
        healthBar = self.makeHealthBar()
        healthBar.position = CGPoint(x: (self.view?.bounds.size.width)!-2.5, y: (self.view?.bounds.size.height)!/2)
        
        self.addChild(healthBarBack)
        self.addChild(healthBar)
    }
    
    func setupOpponentHealthBar() {
        
        /*
        healthBarBack = self.makeHealthBarBack()
        healthBarBack.position = CGPoint(x: ship.position.x, y: ship.position.y + 50)
        healthBar = self.makeHealthBar()
        healthBar.position = CGPoint(x: ship.position.x, y: ship.position.y + 50)
        */
        
        
        opponenthealthBarBack = self.makeHealthBarBack()
        opponenthealthBarBack.position = CGPoint(x: 2.5, y: (self.view?.bounds.size.height)!/2)
        opponenthealthBar = self.makeHealthBar()
        opponenthealthBar.position = CGPoint(x: 2.5, y: (self.view?.bounds.size.height)!/2)
        
        self.addChild(opponenthealthBarBack)
        self.addChild(opponenthealthBar)
    }
    
    func setupMpBar() {
        
        mpValue = (self.view?.bounds.size.height)!
        
        MpBar = self.makeMpBar()
        MpBar.position = CGPoint(x: (self.view?.bounds.size.width)!-10, y: (self.view?.bounds.size.height)!/2)
        
        self.addChild(MpBar)
        
        /*
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: ship.size.width / 2.0, y: ship.size.height / 2.0), radius: (ship.size.width + 10)/2, startAngle: 0.0, endAngle: CGFloat(M_PI * 2.0), clockwise: true)
        
        // Setup the CAShapeLayer with the path, colors, and line width
        MpBar = CAShapeLayer()
        MpBar.path = circlePath.CGPath
        MpBar.fillColor = UIColor.clearColor().CGColor
        MpBar.strokeColor = UIColor.redColor().CGColor
        MpBar.lineWidth = 5.0
        
        // Don't draw the circle initially
        MpBar.strokeEnd = 1.0
        
        // Add the circleLayer to the view's layer's sublayers
        self.view!.layer.addSublayer(MpBar)
        
        //self.addChild(MpBar)
        */
    }
    
    func setupOpponentMpBar() {
        
        opponentMpValue = (self.view?.bounds.size.height)!
        
        opponentMpBar = self.makeMpBar()
        opponentMpBar.position = CGPoint(x: 10, y: (self.view?.bounds.size.height)!/2)
        
        self.addChild(opponentMpBar)
    }
    
    func setupShip() {
        
        // 1
        ship = self.makeShip()
        // 2
        ship.position = CGPointMake(self.size.width / 2, kShipSize.height / 2)
        
        self.addChild(ship)
    }
    
    
    /*func qq() {
    
    // 1
    var qqq = self.makeShip()
    // 2
    qqq.position = CGPointMake(40, 40)
    qqq.xScale = 0.4;
    qqq.yScale = 0.4;
    
    self.addChild(qqq)
    
    qqq = self.makeShip()
    
    qqq.position = CGPointMake(40, 90)
    qqq.xScale = 0.4;
    qqq.yScale = 0.4;
    
    self.addChild(qqq)
    
    qqq = self.makeShip()
    
    qqq.position = CGPointMake(40, 140)
    qqq.xScale = 0.4;
    qqq.yScale = 0.4;
    
    self.addChild(qqq)
    }*/
    
    
    func makeShip() -> SKSpriteNode {
        
        let texture = SKTexture(image: CharacterManager.getCharacterFromLocalStorage()!)
        let ship = SKSpriteNode(texture: texture)
        ship.color = UIColor.greenColor()
        ship.name = kShipName
        //ship.xScale = 0.15
        //ship.yScale = 0.15
        
        // Physic
        // 1
        ship.physicsBody = SKPhysicsBody(rectangleOfSize: ship.frame.size)
        // 2
        ship.physicsBody!.dynamic = true
        // 3
        ship.physicsBody!.affectedByGravity = false
        // 4
        ship.physicsBody!.mass = 0.02
        ship.physicsBody!.friction = 0.0
        
        
        // ship's bitmask setup
        // 1
        ship.physicsBody!.categoryBitMask = kShipCategory
        // 2
        ship.physicsBody!.contactTestBitMask = 0x0
        // 3
        ship.physicsBody!.collisionBitMask = kSceneEdgeCategory
        ship.zPosition = 1000
        
        return ship
    }
    
    func makeHealthBar() -> SKSpriteNode {
        
        let kBarSize = CGSize(width:5, height: (self.view?.bounds.height)!)
        
        let bar = SKSpriteNode(color: SKColor.redColor(), size: kBarSize)
        bar.name = kBar
        
        
        return bar
    }
    
    func makeHealthBarBack() -> SKSpriteNode {
        
        let kBarSize = CGSize(width:5, height: (self.view?.bounds.height)!)
        
        let bar = SKSpriteNode(color: SKColor.grayColor(), size: kBarSize)
        bar.name = kBar
        
        return bar
    }
    
    func makeMpBar() -> SKSpriteNode {
        
        let kBarSize = CGSize(width:5, height: (self.view?.bounds.height)!)
        
        let bar = SKSpriteNode(color: SKColor.blueColor(), size: kBarSize)
        bar.name = kBar
        
        
        return bar
    }
    
    
    
    
    func makeBulletOfType(bulletType: BulletType) -> SKSpriteNode! {
        
        var bullet: SKSpriteNode!
        
        switch bulletType {
        case .ShipFired:
            //bullet = SKSpriteNode(color: SKColor.greenColor(), size: kBulletSize)
            bullet = SKSpriteNode(imageNamed: "Missel")
            bullet.xScale = 0.5
            bullet.yScale = 0.5
            bullet.name = kShipFiredBulletName
            
            bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.frame.size)
            bullet.physicsBody!.dynamic = true
            bullet.physicsBody!.affectedByGravity = false
            bullet.physicsBody!.categoryBitMask = kShipFiredBulletCategory
            bullet.physicsBody!.contactTestBitMask = kInvaderCategory | kShipCategory
            bullet.physicsBody!.collisionBitMask = 0x0
            
        case .InvaderFired:
            bullet = SKSpriteNode(color: SKColor.magentaColor(), size: kBulletSize)
            bullet.name = kInvaderFiredBulletName
            
            bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.frame.size)
            bullet.physicsBody!.dynamic = true
            bullet.physicsBody!.affectedByGravity = false
            bullet.physicsBody!.categoryBitMask = kInvaderFiredBulletCategory
            bullet.physicsBody!.contactTestBitMask = kShipCategory
            bullet.physicsBody!.collisionBitMask = 0x0
            
        case .Bonus:
            bullet = SKSpriteNode(imageNamed: "StarBonus")
            
            bullet.name = starName
            bullet.xScale = 0.12
            bullet.yScale = 0.12
            
            /*
            bullet.position = CGPointMake(0 + bullet.size.width / 2, randomNumber(self.size.height / 2) + self.size.height / 4)
            */
            
            /*
            bullet.position = CGPointMake(0 + bullet.size.width / 2, randomNumber(self.size.height / 16) + self.size.height * 15 / 16 - bullet.size.width / 2)
            */
            
            //bullet.position = CGPointMake(bullet.size.width / 2 + randomNumber(self.size.width - bullet.size.width * 2), bullet.size.height / 2 + randomNumber(self.size.height - bullet.size.height * 2))
            bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.height / 5)
            bullet.physicsBody?.usesPreciseCollisionDetection = true
            bullet.physicsBody?.affectedByGravity = false
            bullet.physicsBody?.categoryBitMask = kStarBonusCategory
            bullet.physicsBody?.contactTestBitMask = kShipCategory
            bullet.physicsBody?.collisionBitMask = 0x0
            
        case .BonusBullet:
            bullet = SKSpriteNode(imageNamed: "DoubleBonus")
            
            bullet.name = starBonusName
            bullet.xScale = 0.20
            bullet.yScale = 0.20
            bullet.position = CGPointMake(0 + bullet.size.width / 2, randomNumber(self.size.height / 2) + self.size.height / 4)
            bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.height / 5)
            bullet.physicsBody?.usesPreciseCollisionDetection = true
            bullet.physicsBody?.affectedByGravity = false
            bullet.physicsBody?.categoryBitMask = bulletCategory
            bullet.physicsBody?.contactTestBitMask = kShipCategory
            bullet.physicsBody?.collisionBitMask = 0x0
            
        default:
            bullet = nil
        }
        
        return bullet
    }
    
    
    // Scene Update
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if self.isGameOver() {
            
            self.endGame()
        }
        
        self.processContactsForUpdate(currentTime)
        
        self.processUserTapsForUpdate(currentTime)
        
        if(startMoving){
            self.processUserMotionForUpdate(currentTime)
        }
        
        self.MpIncrease(currentTime)
        
        btAdvertiseSharedInstance.updateOpponentRealTimePos((self.view?.bounds.size.width)!-ship.position.x, y: ship.position.y)
        
        
        
        //self.moveInvadersForUpdate(currentTime)
        
        //self.fireInvaderBulletsForUpdate(currentTime)
    }
    
    
    // Scene Update Helpers
    
    func moveInvadersForUpdate(currentTime: CFTimeInterval) {
        
        // 1
        if (currentTime - self.timeOfLastMove < self.timePerMove) {
            return
        }
        
        // logic to change movement direction
        self.determineInvaderMovementDirection()
        
        // 2
        enumerateChildNodesWithName(kInvaderName) {
            node, stop in
            
            switch self.invaderMovementDirection {
            case .Right:
                node.position = CGPointMake(node.position.x + 10, node.position.y)
            case .Left:
                node.position = CGPointMake(node.position.x - 10, node.position.y)
            case .DownThenLeft, .DownThenRight:
                node.position = CGPointMake(node.position.x, node.position.y - 10)
            case .None:
                break
            default:
                break
            }
            
            // 3
            self.timeOfLastMove = currentTime
            
        }
    }
    
    func secureChildNodeWithName(name: String) -> SKSpriteNode! {
        
        
        /*
        var shipNode: SKSpriteNode!
        
        // enumerate to find the ship node
        self.enumerateChildNodesWithName(kShipName) {
        node, stop in
        
        if let aNode : SKNode = node {
        
        shipNode = aNode as! SKSpriteNode
        }
        }
        */
        
        //shipNode = self.childNodeWithName(kShipName) as! SKSpriteNode
        
        // if found return it
        if ship != nil {
            return ship
        } else {
            return nil
        }
    }
    
    func processUserMotionForUpdate(currentTime: CFTimeInterval) {
        
        // 1
        //if let ship = self.secureChildNodeWithName(kShipName) as SKSpriteNode! {
        // 2
        if let data = self.motionManager.accelerometerData {
            
            let multiplier = shipVelocity
            let x = data.acceleration.x
            let y = data.acceleration.y
            ship.physicsBody!.velocity = CGVector(dx: y * multiplier, dy: -x * multiplier )
            
            
            burnEffectImg.physicsBody!.velocity = CGVector(dx: y * multiplier, dy: -x * multiplier )
            frozenEffectImg.physicsBody!.velocity = CGVector(dx: y * multiplier, dy: -x * multiplier )
            
            
            
            // 3
            //if fabs(data.acceleration.y) > 0.05 {
            
            // 4 How do you move the ship?
            //ship.physicsBody!.applyForce(CGVectorMake(40.0 * CGFloat(data.acceleration.y), 0))
            
            
            //}
            //if fabs(data.acceleration.y) > 0.05 {
            
            // 4 How do you move the ship?
            //ship.physicsBody!.applyForce(CGVectorMake(0, -40.0 * CGFloat(data.acceleration.x)))
            
            
            //}
            
            //healthBar.position = CGPoint(x: ship.position.x - (latestMinusHealth/2), y: ship.position.y + 65)
            //healthBarBack.position = CGPoint(x: ship.position.x, y: ship.position.y + 65)
            
            if(profemitter != nil){
                profemitter.position = ship.position
            }
            
            frozenEffectImg.position = ship.position
            burnEffectImg.position = ship.position
            
        }
        //}
    }
    
    func processUserTapsForUpdate(currentTime: CFTimeInterval) {
        
        // self.fireShipBullets()
        
        // 1
        for tapCount in self.tapQueue {
            
            if tapCount == 1 {
                
                // 2
                self.fireShipBullets()
                
                
            }
            else if tapCount > 1 {
                
                self.fireShipBullets()
                
                self.fireShipBullets()
                
            }
            
            // 3
            self.tapQueue.removeAtIndex(0)
        }
    }
    
    
    func fireInvaderBulletsForUpdate(currentTime: CFTimeInterval) {
        
        let existingBullet = self.childNodeWithName(kInvaderFiredBulletName)
        
        // 1
        if existingBullet == nil {
            
            var allInvaders = Array<SKNode>()
            
            // 2
            self.enumerateChildNodesWithName(kInvaderName) {
                node, stop in
                
                allInvaders.append(node)
            }
            
            if allInvaders.count > 0 {
                
                // 3
                let allInvadersIndex = Int(arc4random_uniform(UInt32(allInvaders.count)))
                
                let invader = allInvaders[allInvadersIndex]
                
                // 4
                let bullet = self.makeBulletOfType(.InvaderFired)
                bullet.position = CGPoint(x: invader.position.x, y: invader.position.y - invader.frame.size.height / 2 + bullet.frame.size.height / 2)
                
                // 5
                let bulletDestination = CGPoint(x: invader.position.x, y: -(bullet.frame.size.height / 2))
                
                // 6
                self.fireBullet(bullet, toDestination: bulletDestination, withDuration: 2.0, andSoundFileName: "InvaderBullet.wav", fromWhom:1)
            }
        }
    }
    
    
    func processContactsForUpdate(currentTime: CFTimeInterval) {
        
        for contact in self.contactQueue {
            self.handleContact(contact)
            
            if let index = (self.contactQueue as NSArray).indexOfObject(contact) as Int? {
                self.contactQueue.removeAtIndex(index)
            }
        }
    }
    
    // Invader Movement Helpers
    
    func adjustInvaderMovementToTimePerMove(newTimerPerMove: CFTimeInterval) {
        
        // 1
        if newTimerPerMove <= 0 {
            return
        }
        
        // 2
        let ratio: CGFloat = CGFloat(self.timePerMove / newTimerPerMove)
        self.timePerMove = newTimerPerMove
        
        enumerateChildNodesWithName(kInvaderName) {
            node, stop in
            // 3
            node.speed = node.speed * ratio
        }
    }
    
    func determineInvaderMovementDirection() {
        
        // 1
        var proposedMovementDirection: InvaderMovementDirection = self.invaderMovementDirection
        
        // 2
        enumerateChildNodesWithName(kInvaderName) {
            node, stop in
            
            switch self.invaderMovementDirection {
                
            case .Right:
                //3
                if (CGRectGetMaxX(node.frame) >= node.scene!.size.width - 1.0) {
                    proposedMovementDirection = .DownThenLeft
                    
                    stop.memory = true
                }
            case .Left:
                //4
                if (CGRectGetMinX(node.frame) <= 1.0) {
                    proposedMovementDirection = .DownThenRight
                    
                    stop.memory = true
                }
                
            case .DownThenLeft:
                proposedMovementDirection = .Left
                
                // Add the following line
                self.adjustInvaderMovementToTimePerMove(self.timePerMove * 0.8)
                
                stop.memory = true
                
            case .DownThenRight:
                proposedMovementDirection = .Right
                
                // Add the following line
                self.adjustInvaderMovementToTimePerMove(self.timePerMove * 0.8)
                
                stop.memory = true
                
            default:
                break
                
            }
            
        }
        
        //7
        if (proposedMovementDirection != self.invaderMovementDirection) {
            self.invaderMovementDirection = proposedMovementDirection
        }
    }
    
    
    // Bullet Helpers
    
    func fireBullet(bullet: SKSpriteNode, toDestination destination:CGPoint, withDuration duration:CFTimeInterval, andSoundFileName soundName: String, fromWhom: Int) {
        
        // 1
        //let bulletAction = SKAction.sequence([SKAction.moveTo(destination, duration: duration), SKAction.waitForDuration(3.0/60.0), SKAction.removeFromParent()])
        let bulletAction: SKAction
        
        if(fromWhom == 0){
            bulletAction = SKAction.sequence([SKAction.moveBy(CGVectorMake(destination.x, (self.view?.bounds.size.height)!), duration: duration), SKAction.waitForDuration(3.0/60.0), SKAction.removeFromParent()])
        }
        else{
            bulletAction = SKAction.sequence([SKAction.moveBy(CGVectorMake(destination.x, -(self.view?.bounds.size.height)!), duration: duration), SKAction.waitForDuration(3.0/60.0), SKAction.removeFromParent()])
        }
        
        // 2
        let soundAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        // 3
        bullet.runAction(SKAction.group([bulletAction, soundAction]))
        
        
        // 4
        self.addChild(bullet)
        
    }
    
    func fireUltimate(ultimate: SKSpriteNode, withDuration duration:CFTimeInterval, andSoundFileName soundName: String) {
        
        
        // 1
        //let bulletAction = SKAction.sequence([SKAction.moveTo(destination, duration: duration), SKAction.waitForDuration(3.0/60.0), SKAction.removeFromParent()])
        let bulletAction: SKAction
        
        bulletAction = SKAction.sequence([SKAction.moveBy(CGVectorMake(0, (self.view?.bounds.size.height)!), duration: duration), SKAction.waitForDuration(3.0/60.0), SKAction.removeFromParent()])
        
        // 2
        let soundAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        // 3
        ultimate.runAction(SKAction.group([bulletAction, soundAction]))
        
        
        // 4
        self.addChild(ultimate)
        
    }
    
    func fireShipBullets(){
        
        // triple bullets or not
        let tripleBullet = 1
        
        // not triple bullets
        if(tripleBullet == 0) {
            
            var bullet: SKSpriteNode?
            if weaponType == BulletType.ShipFired {
                bullet = self.makeBulletOfType(.ShipFired)
            }
                
            else if weaponType == BulletType.BonusBullet {
                bullet = self.makeBulletOfType(.BonusBullet)
            }
            
            // 2
            bullet!.position = CGPoint(x: ship.position.x, y: ship.position.y + ship.frame.size.height + bullet!.frame.size.height / 4)
            
            // 3
            let bulletDestination = CGPoint(x: 0, y: 0)
            
            // 4
            self.fireBullet(bullet!, toDestination: bulletDestination, withDuration: 1.0, andSoundFileName: "ShipBullet.wav", fromWhom: 0)
            
            // send data
            // Formal Variable 'y': 0 indicates not triple bullets and 1 indicates triple bullets
            if weaponType == BulletType.ShipFired {
                btAdvertiseSharedInstance.update((self.view?.bounds.size.width)! - ship.position.x, y: 0)
            }
                
            else if weaponType == BulletType.BonusBullet {
                btAdvertiseSharedInstance.updateBonusBullet((self.view?.bounds.size.width)! - ship.position.x, y: 0, type: BulletType.BonusBullet.description)
            }
            
        }
        
        // triple bullets
        if(tripleBullet == 1) {
            
            var bulletLeft: SKSpriteNode?
            var bulletMiddle: SKSpriteNode?
            var bulletRight: SKSpriteNode?
            
            // use Formal Variable of fireBullet() to control the angle
            var bulletLeftDestination: CGPoint?
            var bulletMiddleDestination: CGPoint?
            var bulletRightDestination: CGPoint?
            
            if weaponType == BulletType.ShipFired {
                
                bulletLeft = self.makeBulletOfType(.ShipFired)
                bulletMiddle = self.makeBulletOfType(.ShipFired)
                bulletRight = self.makeBulletOfType(.ShipFired)
                
                bulletLeft!.position = CGPointMake(ship.position.x - ship.size.width * 0.15, ship.position.y + ship.size.height)
                bulletMiddle!.position = CGPointMake(ship.position.x, ship.position.y + ship.size.height)
                bulletRight!.position = CGPointMake(ship.position.x + ship.size.width * 0.15, ship.position.y + ship.size.height)
                
                bulletLeftDestination = CGPoint(x: bulletLeft!.size.width * -5, y: 0)
                bulletMiddleDestination = CGPoint(x: 0, y: 0)
                bulletRightDestination = CGPoint(x: bulletRight!.size.width * 5, y: 0)
                
            }
                
            else if weaponType == BulletType.BonusBullet {
                
                bulletLeft = self.makeBulletOfType(.BonusBullet)
                bulletMiddle = self.makeBulletOfType(.BonusBullet)
                bulletRight = self.makeBulletOfType(.BonusBullet)
                
                bulletLeft!.position = CGPointMake(ship.position.x - ship.size.width * 0.25, ship.position.y + ship.size.height)
                bulletMiddle!.position = CGPointMake(ship.position.x, ship.position.y + ship.size.height)
                bulletRight!.position = CGPointMake(ship.position.x + ship.size.width * 0.25, ship.position.y + ship.size.height)
                
                bulletLeftDestination = CGPoint(x: bulletLeft!.size.width * -0.5, y: 0)
                bulletMiddleDestination = CGPoint(x: 0, y: 0)
                bulletRightDestination = CGPoint(x: bulletRight!.size.width * 0.5, y: 0)
                
            }
            
            self.fireBullet(bulletLeft!, toDestination: bulletLeftDestination!, withDuration: 1.0, andSoundFileName: "ShipBullet.wav", fromWhom: 0)
            self.fireBullet(bulletMiddle!, toDestination: bulletMiddleDestination!, withDuration: 1.0, andSoundFileName: "ShipBullet.wav", fromWhom: 0)
            self.fireBullet(bulletRight!, toDestination: bulletRightDestination!, withDuration: 1.0, andSoundFileName: "ShipBullet.wav", fromWhom: 0)
            
            // send data
            // Formal Variable 'y': 0 indicates not triple bullets and 1 indicates triple bullets
            if weaponType == BulletType.ShipFired {
                
                btAdvertiseSharedInstance.update((self.view?.bounds.size.width)! - ship.position.x, y: 1)
                
            }
                
            else if weaponType == BulletType.BonusBullet {
                
                btAdvertiseSharedInstance.updateBonusBullet((self.view?.bounds.size.width)! - ship.position.x, y: 1, type: BulletType.BonusBullet.description)
                
            }
            
        }
        
    }
    
    
    
    
    
    func ApponentFireShipBullets(notification: NSNotification) {
        
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject>
        let string_point: String = userInfo["point"] as! String
        
        var fullNameArr = string_point.characters.split {$0 == " "}.map { String($0) }
        let x: String = fullNameArr[1]
        let y: String = fullNameArr[2]
        
        let f_x = CGFloat((x as NSString).floatValue)
        let f_y = CGFloat((y as NSString).floatValue)
        
        // not triple bullets
        if(f_y == 0) {
            
            let bullet = self.makeBulletOfType(.ShipFired)
            
            bullet.texture = SKTexture(imageNamed: "Missel_hit")
            
            bullet.position = CGPoint(x: f_x, y: self.frame.size.height + bullet.frame.size.height / 2)
            
            let bulletDestination = CGPoint(x: 0, y: 0)
            
            self.fireBullet(bullet, toDestination: bulletDestination, withDuration: 1.0, andSoundFileName: "ShipBullet.wav", fromWhom: 1)
            
        }
            
            // triple bullets
        else if(f_y == 1) {
            
            let bulletLeft = self.makeBulletOfType(.ShipFired)
            let bulletMiddle = self.makeBulletOfType(.ShipFired)
            let bulletRight = self.makeBulletOfType(.ShipFired)
            
            bulletLeft.texture = SKTexture(imageNamed: "Missel_hit")
            bulletMiddle.texture = SKTexture(imageNamed: "Missel_hit")
            bulletRight.texture = SKTexture(imageNamed: "Missel_hit")
            
            // 0.15
            bulletLeft.position = CGPointMake(f_x - ship.size.width * 1, self.frame.size.height + bulletLeft.frame.size.height / 2)
            bulletMiddle.position = CGPointMake(f_x, self.frame.size.height + bulletMiddle.frame.size.height / 2)
            bulletRight.position = CGPointMake(f_x + ship.size.width * 1, self.frame.size.height + bulletRight.frame.size.height / 2)
            
            let bulletLeftDestination = CGPoint(x: bulletLeft!.size.width * -5, y: 0)
            let bulletMiddleDestination = CGPoint(x: 0, y: 0)
            let bulletRightDestination = CGPoint(x: bulletRight!.size.width * 5, y: 0)
            
            self.fireBullet(bulletLeft!, toDestination: bulletLeftDestination, withDuration: 1.0, andSoundFileName: "ShipBullet.wav", fromWhom: 1)
            self.fireBullet(bulletMiddle!, toDestination: bulletMiddleDestination, withDuration: 1.0, andSoundFileName: "ShipBullet.wav", fromWhom: 1)
            self.fireBullet(bulletRight!, toDestination: bulletRightDestination, withDuration: 1.0, andSoundFileName: "ShipBullet.wav", fromWhom: 1)
            
            // ray version
            /*
            if let bullet = self.makeBulletOfType(.ShipFired) {
            
            bullet.texture = SKTexture(imageNamed: "Missel_hit")
            
            // 2
            bullet.position = CGPoint(x: f_x, y: self.frame.size.height + bullet.frame.size.height / 2)
            
            // 3
            let bulletDestination = CGPoint(x: f_y, y: f_y + ship.frame.size.height - bullet.frame.size.height / 2)
            
            
            // 4
            self.fireBullet(bullet, toDestination: bulletDestination, withDuration: 1.0, andSoundFileName: "ShipBullet.wav", fromWhom: 1)
            }
            */
            
        }
        
    }
    
    func fireShipUltimate() {
        
        /*
        
        if laser != nil{
        laser.removeFromParent()
        }
        */
        let laser = SKSpriteNode(imageNamed: "a01")
        laser.name = "laser"
        laser.size.width = 400
        
        laser.size.width = CGFloat(laser_final_width)
        laser.size.height = CGFloat(laser_height)
        //laser.size.height = (self.view?.bounds.height)!
        laser.position = CGPoint(x: ship.position.x, y: CGFloat(laser_height / 2.0) + ship.position.y + ship.size.height/2)
        
        self.addChild(laser)
        
        if emitter != nil{
            self.emitter.removeFromParent()
        }
        
        laser.runAction(animation, completion:
            {
                laser.removeFromParent()
        })
        
        
        
    }
    
    
    func ApponentFireShipUltimate(notification: NSNotification) {
        
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject>
        let string_point: String = userInfo["point"] as! String
        
        var fullNameArr = string_point.characters.split {$0 == " "}.map { String($0) }
        let x: String = fullNameArr[1]
        //let y: String = fullNameArr[2]
        let w: String = fullNameArr[3]
        
        
        let f_x = CGFloat((x as NSString).floatValue);
        //let f_y = CGFloat((y as NSString).floatValue);
        laser_final_width = (w as NSString).doubleValue;
        
        //print(laser_final_width)
        
        /*
        if laser != nil{
        laser.removeFromParent()
        }
        */
        
        let laser = SKSpriteNode(imageNamed: "a01")
        laser.name = "laser"
        laser.size.width = 400
        
        laser.size.width = CGFloat(laser_final_width)
        laser.size.height = CGFloat(laser_height)
        laser.position = CGPoint(x: f_x, y: 0)
        
        laser.name = kShipFiredUltimateName
        let pb = CGSizeMake(laser.frame.size.width-35, laser.frame.size.height)
        laser.physicsBody = SKPhysicsBody(rectangleOfSize: pb)
        laser.physicsBody!.dynamic = true
        laser.physicsBody!.affectedByGravity = false
        laser.physicsBody!.categoryBitMask = kShipFiredBulletCategory
        laser.physicsBody!.contactTestBitMask = kShipCategory
        laser.physicsBody!.collisionBitMask = 0x0
        
        self.addChild(laser)
        
        if emitter != nil{
            self.emitter.removeFromParent()
        }
        
        laser.runAction(animation, completion:
            {
                laser.removeFromParent()
        })
        
        if ultimateHint != nil{
            ultimateHint.removeFromParent()
            self.WarningSiren.pause()
            
            do {
                try self.kameCharge = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("kameEmmit", ofType: "wav")!))
                
                self.kameCharge.play()
            } catch {
                print(error)
            }
            
        }
        
        if(oppoMpTimer != nil){
            oppoMpTimer.invalidate()
            oppoMpTimer = nil
            
        }
    }
    
    func ultimateHint(notification: NSNotification){
        
        
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject>
        let string_point: String = userInfo["point"] as! String
        
        var fullNameArr = string_point.characters.split {$0 == " "}.map { String($0) }
        let x: String = fullNameArr[1]
        //let y: String = fullNameArr[2]
        
        let f_x = CGFloat((x as NSString).floatValue);
        //let f_y = CGFloat((y as NSString).floatValue);
        
        
        ultimateHint = SKSpriteNode(imageNamed: "warning")
        ultimateHint.position = CGPoint(x: f_x, y: ((self.view?.bounds.height)! - 20))
        self.addChild(ultimateHint)
        let fadeIn = SKAction.fadeInWithDuration(0.1)
        let fadeOut = SKAction.fadeOutWithDuration(0.1)
        
        ultimateHint.runAction(SKAction.repeatActionForever(SKAction.sequence([fadeOut,fadeIn])))
        do {
            try self.WarningSiren = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Warning", ofType: "wav")!))
            
            self.WarningSiren.play()
        } catch {
            print(error)
        }
        
        //ultimateHint.runAction(SKAction.playSoundFileNamed("Warning.wav", waitForCompletion: false))
        
        
        
        if(oppoMpTimer != nil){
            oppoMpTimer.invalidate()
            oppoMpTimer = nil
            
        }
        
        oppoMpTimer = NSTimer(timeInterval: 0.01, target: self, selector: Selector("MpDecrease:"), userInfo: 1, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(oppoMpTimer, forMode: NSDefaultRunLoopMode)
        
        //oppoMpTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "MpDecrease:", userInfo: 1, repeats: true)
        
        //print(f_x)
        
        
    }
    
    
    func hitOpponent(notification: NSNotification){
        
        
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject>
        let string_point: String = userInfo["point"] as! String
        
        var fullNameArr = string_point.characters.split {$0 == " "}.map { String($0) }
        let health: String = fullNameArr[1]
        //let y: String = fullNameArr[2]
        
        let minust_health = CGFloat((health as NSString).floatValue);
        //let f_y = CGFloat((y as NSString).floatValue);
        
        
        //print(minust_health)
        
        if(minust_health <= 0){
            
            self.userInteractionEnabled = false
            
            if(ultimateTimer != nil){
                ultimateTimer.invalidate()
                ultimateTimer = nil
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if self.emitter != nil {
                    self.emitter.removeFromParent()
                }
                
                if self.ultimateHint != nil{
                    self.ultimateHint.removeFromParent()
                    self.WarningSiren.pause()
                    
                    do {
                        try self.kameCharge = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("kameEmmit", ofType: "wav")!))
                        
                        self.kameCharge.play()
                    } catch {
                        print(error)
                    }
                    
                }
                
                let alert = UIAlertView(title: "",
                    message: "YOU WIN!",
                    delegate: self,
                    cancelButtonTitle: "OK")
                
                alert.show()
                
                
            })
        }
        
        
        //print((self.view?.bounds.height)! - minust_health)
        
        
        opponentlatesHealth = (self.view?.bounds.height)! - minust_health
        
        if(opponentlatesHealth <= 0){
            
            opponentlatesHealth = (self.view?.bounds.height)!
            
            opponenthealthBar.position = CGPoint(x: 2.5, y: (self.view?.bounds.size.height)!/2)
            opponenthealthBarBack.position = CGPoint(x: 2.5, y: (self.view?.bounds.size.height)!/2)
            
        }
        opponenthealthBar.size = CGSize(width: 5 ,height: opponentlatesHealth)
        opponenthealthBar.position = CGPoint(x: 2.5, y: (self.view?.bounds.size.height)!/2 + minust_health/2)
        
        //print("++++++++++++++++")
        
    }
    
    func bonusHitOpponent(notification: NSNotification){
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject>
        let string_point: String = userInfo["point"] as! String
        //print("bonus bullet")
        
        var fullNameArr = string_point.characters.split {$0 == " "}.map { String($0) }
        let x: String = fullNameArr[3]
        let y: String = fullNameArr[2]
        let type: String = fullNameArr[1]
        
        if type == BulletType.BonusBullet.description {
            
            let f_x = CGFloat((x as NSString).floatValue)
            let f_y = CGFloat((y as NSString).floatValue)
            
            // not triple bullets
            if(f_y == 0) {
                
                let bullet = self.makeBulletOfType(BulletType.BonusBullet)
                
                bullet.position = CGPoint(x: f_x, y: self.frame.size.height + bullet.size.height / 2)
                
                let bulletDestination = CGPoint(x: 0, y: 0)
                
                self.fireBullet(bullet!, toDestination: bulletDestination, withDuration: 1.0, andSoundFileName: "ShipBullet.wav", fromWhom: 1)
                
            }
                
                // triple bullets
            else if(f_y == 1) {
                
                let bulletLeft = self.makeBulletOfType(.BonusBullet)
                let bulletMiddle = self.makeBulletOfType(.BonusBullet)
                let bulletRight = self.makeBulletOfType(.BonusBullet)
                
                // 0.25
                bulletLeft.position = CGPointMake(f_x - ship.size.width * 1.5, self.frame.size.height + bulletLeft.frame.size.height / 2)
                bulletMiddle.position = CGPointMake(f_x, self.frame.size.height + bulletMiddle.frame.size.height / 2)
                bulletRight.position = CGPointMake(f_x + ship.size.width * 1.5, self.frame.size.height + bulletRight.frame.size.height / 2)
                
                let bulletLeftDestination = CGPoint(x: bulletLeft!.size.width * -0.5, y: 0)
                let bulletMiddleDestination = CGPoint(x: 0, y: 0)
                let bulletRightDestination = CGPoint(x: bulletRight!.size.width * 0.5, y: 0)
                
                self.fireBullet(bulletLeft!, toDestination: bulletLeftDestination, withDuration: 1.0, andSoundFileName: "ShipBullet.wav", fromWhom:1)
                self.fireBullet(bulletMiddle!, toDestination: bulletMiddleDestination, withDuration: 1.0, andSoundFileName: "ShipBullet.wav", fromWhom:1)
                self.fireBullet(bulletRight!, toDestination: bulletRightDestination, withDuration: 1.0, andSoundFileName: "ShipBullet.wav", fromWhom:1)
                
            }
            
        }
        
    }
    
    
    func realTimePos(notification: NSNotification){
        
        
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject>
        let string_point: String = userInfo["point"] as! String
        
        var fullNameArr = string_point.characters.split {$0 == " "}.map { String($0) }
        let x: String = fullNameArr[1]
        //let y: String = fullNameArr[2]
        
        let f_x = CGFloat((x as NSString).floatValue);
        let point = CGPoint(x: f_x, y: (self.view?.bounds.size.height)! - oppoPosHint.size.height)
        oppoPosHint.runAction(SKAction.moveTo(point, duration: 0.1))
        //oppoPosHint.position = CGPoint(x: f_x, y: self.frame.size.height - 30);
        
        
        
        //print(f_x);
        //let f_y = CGFloat((y as NSString).floatValue);
        
    }
    
    
    func profEmitterActionAtPosition(position: CGPoint) -> SKAction {
        let sksPath = NSBundle.mainBundle().pathForResource("profExplosion", ofType: "sks")
        profemitter = NSKeyedUnarchiver.unarchiveObjectWithFile(sksPath!) as! SKEmitterNode
        //profemitter = SKEmitterNode(fileNamed: "profExplosion")
        profemitter?.position = CGPoint(x:position.x, y:position.y - ship.size.height/2 + 30)
        profemitter?.zPosition = 0;
        profemitter?.alpha = 0.6
        profemitter?.setScale(0.5)
        profemitter.zPosition = -1
        addChild((profemitter)!)
        
        let wait = SKAction.waitForDuration(0.15)
        
        return SKAction.runBlock({ () -> Void in
            self.profemitter?.runAction(wait)
        })
    }
    
    func starEmitterActionAtPosition(position: CGPoint) -> SKAction {
        let sksPath = NSBundle.mainBundle().pathForResource("MyParticle", ofType: "sks")
        emitter = NSKeyedUnarchiver.unarchiveObjectWithFile(sksPath!) as! SKEmitterNode
        //emitter = SKEmitterNode(fileNamed: "MyParticle")
        emitter?.position = CGPoint(x:position.x, y:position.y - ship.size.height/2 + 30)
        emitter?.zPosition = 0;
        emitter?.alpha = 0.6
        emitter?.setScale(0.5)
        addChild((emitter)!)
        
        let wait = SKAction.waitForDuration(0.15)
        
        return SKAction.runBlock({ () -> Void in
            self.emitter?.runAction(wait)
        })
    }
    
    
    func beginFight(){
        
        self.userInteractionEnabled = false
        
        let Ready = SKSpriteNode(imageNamed:"Ready")
        Ready.xScale = 0.5
        Ready.yScale = 0.5
        Ready.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        addChild(Ready)
        
        let ready_action_array:Array<SKAction> = [SKAction.fadeInWithDuration(1.0),
            SKAction.scaleTo(2.0, duration: 2.0),SKAction.fadeOutWithDuration(2.0)]
        let ready_action_combine = SKAction.group(ready_action_array)
        
        
        Ready.runAction(ready_action_combine) { () -> Void in
            
            let fight_action_array:Array<SKAction> = [SKAction.fadeInWithDuration(1.0),
                SKAction.scaleTo(10.0, duration: 2.0),
                SKAction.fadeOutWithDuration(1.0)]
            let action_combine = SKAction.group(fight_action_array)
            
            let Fight = SKSpriteNode(imageNamed:"Fight")
            Fight.xScale = 0.5
            Fight.yScale = 0.5
            Fight.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
            Fight.runAction(SKAction.playSoundFileNamed("fight.wav", waitForCompletion: false))
            self.addChild(Fight)
            
            self.userInteractionEnabled = true
            
            do {
                try self.BGM = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("BGM", ofType: "wav")!))
                
                self.BGM.play()
            } catch {
                print(error)
            }
            
            Fight.runAction(action_combine) { () -> Void in
                
                //weapon.position = self.weapon1_ori_pos
            }
            
        }
    }
    
    // User Tap Helpers
    
    func delay(delay:Double, closure:()->()) {
        
        dispatch_after(
            dispatch_time( DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
    }
    
    func MpIncrease(currentTime: CFTimeInterval){
        
        if(mpValue < self.view?.bounds.size.height){
            
            mpValue += 1
            MpBar.size = CGSize(width: 5 ,height: mpValue)
            
            let minus = (self.view?.bounds.size.height)! - mpValue
            
            MpBar.position = CGPoint(x: (self.view?.bounds.size.width)!-10 , y: (self.view?.bounds.size.height)!/2 - minus/2)
        }
        
        if(opponentMpValue < self.view?.bounds.size.height){
            
            opponentMpValue += 1
            opponentMpBar.size = CGSize(width: 5 ,height: opponentMpValue)
            
            let minus = (self.view?.bounds.size.height)! - opponentMpValue
            
            opponentMpBar.position = CGPoint(x: 10 , y: (self.view?.bounds.size.height)!/2 + minus/2)
        }
        
    }
    
    func MpDecrease(timer:NSTimer) {
        
        let userOrOpponent = timer.userInfo as! Int
        
        
        if(userOrOpponent == 0){
            
            if(mpValue >= 3){
                
                mpValue -= 3
                MpBar.size = CGSize(width: 5 ,height: mpValue)
                
                let minus = (self.view?.bounds.size.height)! - mpValue
                
                MpBar.position = CGPoint(x: (self.view?.bounds.size.width)!-10 , y: (self.view?.bounds.size.height)!/2 - minus/2)
                
                /*
                if(mpValue <= 0){
                
                
                let timestamp = NSDate().timeIntervalSince1970
                
                diff = timestamp - lastTimeStamp
                
                if(diff > 3.0) {
                laser_final_width = laser_width
                } else {
                laser_final_width = laser_width * (diff / 3.0)
                }
                
                self.kameCharge.pause()
                do {
                try self.kameEmmit = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("kameEmmit", ofType: "wav")!))
                
                self.kameEmmit.play()
                } catch {
                print(error)
                }
                
                self.fireShipUltimate()
                
                btAdvertiseSharedInstance.updateUltimate((self.view?.bounds.size.width)!-ship.position.x, y: ship.position.y, w: CGFloat(laser_final_width))
                
                self.userInteractionEnabled = true
                self.bulletDidFire = true
                
                mutex = false
                startMoving = true;
                
                }
                */
            }
            
            /*
            else{
            
            if(ultimateTimer != nil){
            ultimateTimer.invalidate()
            ultimateTimer = nil
            
            emitter.removeFromParent()
            }
            }
            */
        }
        else if(userOrOpponent == 1){
            
            if(opponentMpValue >= 3){
                
                
                opponentMpValue -= 3
                opponentMpBar.size = CGSize(width: 5 ,height: opponentMpValue)
                
                let minus = (self.view?.bounds.size.height)! - opponentMpValue
                
                opponentMpBar.position = CGPoint(x: 10 , y: (self.view?.bounds.size.height)!/2 + minus/2)
            }
        }
        
        
        
        
    }
    
    func update() {
        
        
        self.bulletDidFire = false
        
        if(self.userInteractionEnabled == false && self.bulletDidFire == false) {
            
            self.ship.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            
            
            self.frozenEffectImg.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            self.burnEffectImg.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            
            self.mutex = true
            
            
            if self.emitter != nil{
                self.emitter.removeFromParent()
            }
            self.starEmitterActionAtPosition(self.ship.position)
            self.emitter.particleBirthRate = 500
            
            //let soundAction = SKAction.playSoundFileNamed("kame.wav", waitForCompletion:false)
            //self.runAction(soundAction, withKey: "kame")
            if self.kameEmmit != nil{
                self.kameEmmit.pause()
            }
            do {
                try self.kameCharge = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("kameCharge", ofType: "wav")!))
                
                self.kameCharge.play()
            } catch {
                print(error)
            }
            
            mpTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "MpDecrease:", userInfo: 0, repeats: true)
            
            
            
            btAdvertiseSharedInstance.updateUltimateHintPos((self.view?.bounds.size.width)!-ship.position.x, y: ship.position.y)
            
        }
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in touches {
            lastTimeStamp = touch.timestamp
        }
        
        startMoving = false;
        self.userInteractionEnabled = false
        
        
        if(ultimateTimer != nil){
            ultimateTimer.invalidate()
            ultimateTimer = nil
        }
        ultimateTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "update", userInfo: nil, repeats: false)
        
        
        
        
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)  {
        // Intentional no-op
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        // Intentional no-op
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)  {
        
        if mutex {
            
            for touch in touches {
                diff = touch.timestamp - lastTimeStamp
            }
            if(diff > 3.0) {
                laser_final_width = laser_width
            } else {
                laser_final_width = laser_width * (diff / 3.0)
            }
            
            self.kameCharge.pause()
            do {
                try self.kameEmmit = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("kameEmmit", ofType: "wav")!))
                
                self.kameEmmit.play()
            } catch {
                print(error)
            }
            
            self.fireShipUltimate()
            
            btAdvertiseSharedInstance.updateUltimate((self.view?.bounds.size.width)!-ship.position.x, y: ship.position.y, w: CGFloat(laser_final_width))
            /*
            if(mpValue>3){
            print("幹幹")
            print(mpValue)
            btAdvertiseSharedInstance.updateUltimate((self.view?.bounds.size.width)!-ship.position.x, y: ship.position.y, w: CGFloat(laser_final_width))
            }
            */
            
        }
        
        self.userInteractionEnabled = true
        self.bulletDidFire = true
        
        mutex = false
        startMoving = true;
        
        if(mpTimer != nil){
            mpTimer.invalidate()
            mpTimer = nil
        }
        
        
        /*
        if let touch: UITouch? = touches.first {
        
        if (touch!.tapCount == 1) {
        
        self.tapQueue.append(1)
        }
        }
        */
    }
    
    // HUD Helpers
    
    func adjustScoreBy(points: Int) {
        
        self.score += points
        
        let score = self.childNodeWithName(kScoreHudName) as! SKLabelNode
        
        score.text = String(format: "Score: %04u", self.score)
    }
    
    func adjustShipHealthBy(healthAdjustment: Float) {
        
        // 1
        self.shipHealth = max(self.shipHealth + healthAdjustment, 0)
        
        let health = self.childNodeWithName(kHealthHudName) as! SKLabelNode
        
        health.text = String(format: "Health: %.1f%%", self.shipHealth * 100)
        
    }
    
    
    func frozenTimerStart(){
        
        shipVelocity = 0;
        ship.alpha = 0.3;
        
        frozenEffectImg = SKSpriteNode(imageNamed: "freeze")
        frozenEffectImg.name = kShipName
        frozenEffectImg.xScale = 0.6
        frozenEffectImg.yScale = 0.6
        frozenEffectImg.position = ship.position
        frozenEffectImg.physicsBody = SKPhysicsBody(rectangleOfSize: frozenEffectImg.frame.size)
        frozenEffectImg.physicsBody!.dynamic = true
        frozenEffectImg.physicsBody!.affectedByGravity = false
        frozenEffectImg.physicsBody!.mass = 0.02
        frozenEffectImg.physicsBody!.friction = 0.0
        frozenEffectImg.physicsBody!.categoryBitMask = kShipCategory
        frozenEffectImg.physicsBody!.contactTestBitMask = 0x0
        frozenEffectImg.physicsBody!.collisionBitMask = kSceneEdgeCategory
        self.addChild(frozenEffectImg)
        
        frozenTimer = NSTimer(timeInterval: 0.5, target: self, selector: Selector("frozenEffect"), userInfo: 1, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(frozenTimer, forMode: NSDefaultRunLoopMode)
        
    }
    
    
    func burnTimerStart(){
        
        burnEffectImg = SKSpriteNode(imageNamed: "burn")
        burnEffectImg.name = kShipName
        burnEffectImg.position = ship.position
        burnEffectImg.zPosition = 1000
        burnEffectImg.alpha = 0.0
        burnEffectImg.physicsBody = SKPhysicsBody(rectangleOfSize: burnEffectImg.frame.size)
        burnEffectImg.physicsBody!.dynamic = true
        burnEffectImg.physicsBody!.affectedByGravity = false
        burnEffectImg.physicsBody!.mass = 0.02
        burnEffectImg.physicsBody!.friction = 0.0
        burnEffectImg.physicsBody!.categoryBitMask = kShipCategory
        burnEffectImg.physicsBody!.contactTestBitMask = 0x0
        burnEffectImg.physicsBody!.collisionBitMask = kSceneEdgeCategory
        self.addChild(burnEffectImg)
        
        
        burnTimer = NSTimer(timeInterval: 2.0, target: self, selector: Selector("burnEffect"), userInfo: 1, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(burnTimer, forMode: NSDefaultRunLoopMode)
        
    }
    
    func frozenEffect(){
        
        velocityDecrease(25.0)
        
        
        ship.runAction(SKAction.fadeAlphaBy((0.7 / (500 / 25.0)), duration: 1))
        frozenEffectImg.runAction(SKAction.fadeAlphaBy(-(1.0 / (500 / 25.0)), duration: 1))
        frozenEffectImg.runAction(SKAction.scaleBy(1.0 - (0.5 / (500 / 25.0)), duration: 1))
    }
    
    func burnEffect(){
        
        decreaseHealth(5.0);
        
        let minusLable = SKLabelNode()
        minusLable.text = "-25"
        minusLable.position.x = ship.position.x
        minusLable.position.y = ship.position.y + 50
        self.addChild(minusLable)
        
        minusLable.runAction(SKAction.moveToY(ship.position.y+150, duration: 1.0))
        minusLable.runAction(SKAction.fadeAlphaTo(0.0, duration: 1.0), completion:{
            minusLable.removeFromParent()
        })
        
        burnEffectImg.runAction(SKAction.fadeAlphaTo(1.0, duration: 0.5), completion:
            {
                self.burnEffectImg.runAction(SKAction.fadeAlphaTo(0.0, duration: 0.5))
        })
        
        
    }
    
    func velocityDecrease( minus : Double){
        
        shipVelocity += minus;
        
        if(shipVelocity >= 500.0){
            shipVelocity = 500.0;
            
            let alert = UIAlertView(title: "",
                message: "DEFROZED!!!",
                delegate: self,
                cancelButtonTitle: "OK")
            
            alert.show()
            
            if(frozenTimer != nil){
                frozenTimer.invalidate()
                frozenTimer = nil
            }
        }
    }
    
    
    
    // Physics Contact Helpers
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if contact as SKPhysicsContact? != nil {
            self.contactQueue.append(contact)
            
            if contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil {
                return
            }
            
            let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]
            
            if (nodeNames as NSArray).containsObject(kShipName) && (nodeNames as NSArray).containsObject(starName) {
                contact.bodyB.node?.removeFromParent()
                weaponType = .BonusBullet
                return
            }
            
            let action = SKAction.shake(0.5, amplitudeX: 10, amplitudeY: 10)
            ship?.runAction(action)
            
        }
    }
    
    func handleContact(contact: SKPhysicsContact) {
        
        // Ensure you haven't already handled this contact and removed its nodes
        if (contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil) {
            return
        }
        
        let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]
        
        if (nodeNames as NSArray).containsObject(kShipName) && (nodeNames as NSArray).containsObject(kInvaderFiredBulletName) {
            
            // Invader bullet hit a ship
            self.runAction(SKAction.playSoundFileNamed("ShipHit.wav", waitForCompletion: false))
            
            // 1
            self.adjustShipHealthBy(-0.334)
            
            if self.shipHealth <= 0.0 {
                
                // 2
                contact.bodyA.node!.removeFromParent()
                contact.bodyB.node!.removeFromParent()
                
            } else {
                
                // 3
                //let ship = self.childNodeWithName(kShipName)
                
                ship!.alpha = CGFloat(self.shipHealth)
                
                if contact.bodyA.node == ship {
                    
                    contact.bodyB.node!.removeFromParent()
                    
                } else {
                    
                    contact.bodyA.node!.removeFromParent()
                }
                
            }
            
        } else if (nodeNames as NSArray).containsObject(kInvaderName) && (nodeNames as NSArray).containsObject(kShipFiredBulletName) {
            
            // Ship bullet hit an invader
            self.runAction(SKAction.playSoundFileNamed("InvaderHit.wav", waitForCompletion: false))
            contact.bodyA.node!.removeFromParent()
            contact.bodyB.node!.removeFromParent()
            
            // 4
            //self.adjustScoreBy(100)
        }
        else if (nodeNames as NSArray).containsObject(kShipName) && (nodeNames as NSArray).containsObject(kShipFiredBulletName) {
            
            // Ship bullet hit an invader
            self.runAction(SKAction.playSoundFileNamed("InvaderHit.wav", waitForCompletion: false))
            //contact.bodyA.node!.removeFromParent()
            contact.bodyB.node!.removeFromParent()
            
            decreaseHealth(2.5)
            
            //print(latesHealth)
            
        }
        else if (nodeNames as NSArray).containsObject(kShipName) && (nodeNames as NSArray).containsObject(kShipFiredUltimateName) {
            
            weaponType = BulletType.ShipFired
            // Ship bullet hit an invader
            self.runAction(SKAction.playSoundFileNamed("InvaderHit.wav", waitForCompletion: false))
            
            //contact.bodyA.node!.removeFromParent()
            //contact.bodyB.node!.removeFromParent()
            // 4
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            
            decreaseHealth(CGFloat(laser_final_width)/5.0)
            
            //print(latesHealth)
            
        }
            
        else if (nodeNames as NSArray).containsObject(kShipName) && (nodeNames as NSArray).containsObject(starBonusName) {
            
            // Ship bullet hit an invader
            self.runAction(SKAction.playSoundFileNamed("InvaderHit.wav", waitForCompletion: false))
            //contact.bodyA.node!.removeFromParent()
            contact.bodyB.node!.removeFromParent()
            
            decreaseHealth(10.0)
            
            //print(latesHealth)
        }
    }
    
    
    func decreaseHealth( minus : CGFloat){
        
        latestMinusHealth += minus
        latesHealth = (self.view?.bounds.height)! - latestMinusHealth
        
        if(latesHealth <= 50 && latesHealth > 0){
            if(profemitter == nil){
                self.profEmitterActionAtPosition(self.ship.position)
            }
        }
        else if(latesHealth <= 0){
            
            latestMinusHealth = 0
            latesHealth = (self.view?.bounds.height)!
            
            if(profemitter != nil){
                self.profemitter.removeFromParent()
            }
            
            
            healthBar.position = CGPoint(x: (self.view?.bounds.size.width)!-2.5, y: (self.view?.bounds.size.height)!/2)
            healthBarBack.position = CGPoint(x: (self.view?.bounds.size.width)!-2.5, y: (self.view?.bounds.size.height)!/2)
            
            //healthBar.position = CGPoint(x: ship.position.x, y: ship.position.y)
            //healthBarBack.position = CGPoint(x: ship.position.x, y: ship.position.y)
            
            
            if self.ultimateHint != nil{
                self.ultimateHint.removeFromParent()
                self.WarningSiren.pause()
                
                do {
                    try self.kameCharge = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("kameEmmit", ofType: "wav")!))
                    
                    self.kameCharge.play()
                } catch {
                    print(error)
                }
                
            }
            
            if(burnTimer != nil){
                burnTimer.invalidate()
                burnTimer = nil
            }
            
            self.userInteractionEnabled = false
            
            let alert = UIAlertView(title: "",
                message: "YOU LOSE!",
                delegate: self,
                cancelButtonTitle: "OK")
            
            alert.show()
            
        }
        
        
        healthBar.size = CGSize(width: 5 ,height: latesHealth)
        healthBar.position = CGPoint(x: (self.view?.bounds.size.width)!-2.5, y: (self.view?.bounds.size.height)!/2 - latestMinusHealth/2)
        
        btAdvertiseSharedInstance.updateHitOpponent(latestMinusHealth)
        
        
    }
    
    
    
    
    
    
    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        
        self.userInteractionEnabled = true
        
        setupHealthBar()
        setupOpponentHealthBar()
        //setupMpBar()
        //setupOpponentMpBar()
        
        latestMinusHealth = 0
        opponentlatestMinusHealth = 0
        latesHealth = (self.view?.bounds.height)!
        opponentlatesHealth = (self.view?.bounds.height)!
        mpValue = (self.view?.bounds.height)!
        opponentMpValue = (self.view?.bounds.height)!
        
        //let minus = (self.view?.bounds.size.height)! - mpValue
        
        MpBar.position = CGPoint(x: (self.view?.bounds.size.width)!-10 , y: (self.view?.bounds.size.height)!/2)
        MpBar.size = CGSize(width: 5 ,height: mpValue)
        
        opponentMpBar.position = CGPoint(x: 10 , y: (self.view?.bounds.size.height)!/2)
        opponentMpBar.size = CGSize(width: 5 ,height: opponentMpValue)
        
        /*
        switch buttonIndex{
        
        case 0:
        NSLog("Dismiss");
        break;
        default:
        self.userInteractionEnabled = true
        NSLog("Default");
        break;
        
        }
        */
        
        
    }
    
    // Game End Helpers
    
    func isGameOver() -> Bool {
        
        return false
    }
    
    func endGame() {
        // 1
        if !self.gameEnding {
            
            self.gameEnding = true
            
            // 2
            self.motionManager.stopAccelerometerUpdates()
            
            // 3
            let gameOverScene: GameOverScene = GameOverScene(size: self.size)
            
            view!.presentScene(gameOverScene, transition: SKTransition.doorsOpenHorizontalWithDuration(1.0))
            
            NSNotificationCenter.defaultCenter().removeObserver(self)
            
        }
    }
    
    
}
