//
//  WeaponManager.swift
//  Faceoff
//
//  Created by Huaying Tsai on 11/19/15.
//  Copyright © 2015 Liang. All rights reserved.
//

import Foundation
import SpriteKit

class WeaponManager: NSObject{
    
    var sceneNode: SKScene!
    var weapon: Weapon?
    var basicWeapon: Weapon?
    var poweredWeapon: Weapon?
    var enemyWeapon: Weapon?
    var enemyPoweredWeapon: Weapon?
    
    var candidateWeapons: [Weapon] = []
    
    //Set this variable from SelectWeaponScene
    var candidateWeaponTypes: [String?]?
    
    var firePreparingBeginTime:NSTimeInterval?
    var firePreparingEndTime:NSTimeInterval?
    var firePreparingTime:NSTimeInterval? {
        get {
            if firePreparingEndTime != nil && firePreparingBeginTime != nil {
            return firePreparingEndTime! - firePreparingBeginTime!
            }
            return nil
        }
    }
    
    func cleanWeapons(){
        cleanFirePreparingTime()
        weapon?.removeEffect()
        poweredWeapon?.removeEffect()
        enemyWeapon?.removeEffect()
        enemyPoweredWeapon?.removeEffect()
    }
    
    func loadWeapons(sceneNode :SKScene){
        self.sceneNode = sceneNode
        
        setCharacterWeapon(Constants.Weapon.WeaponType.Bullet)
        setCharacterWeapon(Constants.Weapon.WeaponType.Laser,powered: true)
        setEnemyWeapon(Constants.Weapon.WeaponType.Bullet)
        setEnemyWeapon(Constants.Weapon.WeaponType.Laser,powered: true)
    }
    
    func setCharacterWeapon(weaponType: String, powered: Bool = false){
        if !powered {
            weapon = makeWeapon(weaponType)
            weapon!.positveEffect()
        }else{
            poweredWeapon = makeWeapon(weaponType)
            poweredWeapon!.positveEffect()
        }
    }
    func setEnemyWeapon(weaponType: String,powered: Bool = false){
        if !powered {
            enemyWeapon = makeWeapon(weaponType)
            enemyWeapon!.negativeEffect()
        }else{
            enemyPoweredWeapon = makeWeapon(weaponType)
            enemyPoweredWeapon!.negativeEffect()
        }
    }
    
    func makeWeapon(weaponType: String) -> Weapon {
        
        var weapon: Weapon!
        
        if weaponType == Constants.Weapon.WeaponType.Bullet{
            weapon = Bullet(sceneNode: sceneNode)
        }
        else if weaponType == Constants.Weapon.WeaponType.BonusBullet{
            weapon = BounsBullet(sceneNode: sceneNode)
        }
        else if weaponType == Constants.Weapon.WeaponType.IceBullet{
            weapon = IceBullet(sceneNode: sceneNode)
        }
        else if weaponType == Constants.Weapon.WeaponType.FireBullet{
            weapon = FireBullet(sceneNode: sceneNode)
        }
        else if weaponType == Constants.Weapon.WeaponType.MultiBullet{
            weapon = MultiBullet(sceneNode: sceneNode)
        }
        else if weaponType == Constants.Weapon.WeaponType.Laser{
            weapon = Laser(sceneNode: sceneNode)
        }
        else if weaponType == Constants.Weapon.WeaponType.Armor {
            weapon = Armor(sceneNode: sceneNode)
        }
        else if weaponType == Constants.Weapon.WeaponType.Heal {
            weapon = Heal(sceneNode: sceneNode)
        }
        else if weaponType == Constants.Weapon.WeaponType.Invisibility {
            weapon = Invisible(sceneNode: sceneNode)
        }
        else if weaponType == Constants.Weapon.WeaponType.AddMp {
            weapon = AddMp(sceneNode: sceneNode)
        }
        else if weaponType == Constants.Weapon.WeaponType.ExpandEnemy {
            weapon = EnlargeEnemy(sceneNode: sceneNode)
        }
        else {
            weapon = Bullet(sceneNode: sceneNode)
        }

        
        return weapon
    }

    func fireBullet(){
        weapon?.fire()
    }
    
    func fireBullet(preparingTime :NSTimeInterval?){
        poweredWeapon?.fire(preparingTime)
    }
    
    func firePreparingBegin(touch: UITouch){
        firePreparingBeginTime = touch.timestamp
        poweredWeapon?.firePreparingAction()
    }
    
    func firePreparingEnd(touch: UITouch) -> Bool{
        firePreparingEndTime = touch.timestamp
        return firePreparingEnd_(firePreparingEndTime!)
    }
    
    func firePreparingEnd_(firePreparingEndTime: NSTimeInterval) -> Bool{
        self.firePreparingEndTime = firePreparingEndTime
        if firePreparingTime > 0.3 {
            poweredWeapon?.fire(firePreparingTime)
            cleanFirePreparingTime()
            return true
        }else{
            poweredWeapon?.stopFirePreparingAction()
            cleanFirePreparingTime()
            return false
        }
    }
    
    func cleanFirePreparingTime(){
        firePreparingBeginTime = nil
        firePreparingEndTime = nil
    }
    
    //set effect when hit
    func effect(character: CharacterNode) {
//        let fireBullet = IceBullet(sceneNode: sceneNode)
//        fireBullet.effect(character)
        enemyWeapon?.effect(character)
    }
    
    func fireFromEnemy(fireInfo :[String]){
        enemyWeapon?.fireFromEnemy(fireInfo)
    }
    
    func poweredFireFromEnemy(fireInfo :[String]){
        enemyPoweredWeapon?.fireFromEnemy(fireInfo)
    }
    
    func fireDamage() -> Double {
        return enemyWeapon!.getDamage() * weapon!.getReduce()
    }
    
    func poweredFireDamage() -> Double {
        return enemyPoweredWeapon!.getDamage() * weapon!.getReduce()
    }
    
    //set initial positive effect to self
    func setPositiveEffect(){
        weapon?.positveEffect()
    }
    
    //set initial negative effect to others
    func setNegativeEffect(){
        enemyWeapon?.negativeEffect()
    }
    
    func effectToMonster(monster: MonsterNode) {
        //        let fireBullet = IceBullet(sceneNode: sceneNode)
        //        fireBullet.effect(character)
        weapon?.effectToMonster(monster)
    }

}