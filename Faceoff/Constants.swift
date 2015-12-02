//
//  Constants.swift
//  BTtest
//
//  Created by Huaying Tsai on 11/14/15.
//  Copyright © 2015 Liang. All rights reserved.
//

import Foundation
import CoreGraphics

struct Constants {
    
    static let Font = "Copperplate"
    
    struct Audio {
        static let TransButton = "TransButton.wav"
        static let CameraButton = "cameraButton.wav"
        static let SelectWeaponButton = "selectWeapon.wav"
        static let WeaponSwift = "swiftWeapon.wav"
        static let WeaponEnlarge = "weaponEnlarge.wav"
        static let SelectOpponent = "SelectOpponent.wav"
        static let Preparebackground = "button.wav"
        static let GameBackground = "button.wav"
        static let Pause = "pause.wav"
        static let Lose = "lose.wav"
        
        static let SelecWeaponInGame = "button.wav"
        static let Help = "button.wav"
        
        static let BulletFire = "ShipBullet.wav"
        static let IceBulletFire = "IceBulletFire"
        static let FireBulletFire = "FireBulletFire.wav"
        static let MultiBulletFire = "ShipBullet.wav"
        static let BonusBulletFire = "button.wav"
        static let LaserPrepareFire = "kameCharge"
        static let LaserFire = "kameEmmit.wav"
        static let InvisibilityFire = "InvisibilityFire.wav"
        static let HealFire = "HealFire.wav"
        static let DetectFire = "button.wav"
        static let ArmorFire = "button.wav"
        static let AddMp = "addmp.wav"
        static let EnlargeFire = "enlargeFire.wav"
    }
    
    struct Character {
        static let MaxOfCandidateNumber = 3
    }
    
    struct Scene {
        static let BackButtonSizeWidth = 184.0
        static let BackButtonSizeHeight = 57.0
    }
    
    struct MainScene {
        static let Background = "mainscene_backgound.jpg"
        static let Slot = "mainscene_slot.png"
        static let MainSlot = "mainscene_mainslotwithoutplus.png"
        static let StartButton = "mainscene_start_button.png"
        static let CharacterList = "mainscene_character_list.png"
        static let CharacterSelect = "mainscene_character_select.png"
        static let Plus = "mainscene_plus.png"
        static let DeleteButton = "mainscene_delete.png"
        static let SlotSize = 80.0
    }
    
    struct CameraScene {
        static let Interface = "camerascene_interface_test.png"
        static let Button = "camerascene_button.png"
        static let BackButton = "camerascene_back_button.png"
    }
    
    struct PlayModeScene {
        static let Background = "playermodescene_background" //Atlas
        static let BackButton = "playermodescene_back_button.png"
        static let StoryButton = "playermodescene_story_button.png"
        static let VersusButton = "playermodescene_versus_button.png"
    }
    struct BuildConnectionScene {
        static let Background = "buildconnectionscene_background.jpg"
        static let PlayerList = "buildconnectionscene_player_list.png"
        static let BackButton = "buildconnectionscene_back_button.png"
    }
    
    struct SelectWeaponScene {
        static let Background = "selectweaponscene_background.jpg"
        static let WeaponSelect = "selectweaponscene_weapon_select.png"
        static let LeftButton = "selectweaponscene_left_button.png"
        static let RightButton = "selectweaponscene_right_button.png"
        static let CenterBlock = "selectweaponscene_center_block.png"
        static let Slot = "selectweaponscene_slot.png"
        static let centerBlockZ = -5
    }
    
    struct CharacterManager {
        static let maxOfCandidateNumber = 3
    }
    
    struct GameScene {
        
        static let Background = "gamescene_background.jpg"
        static let StatusBar = "gamescene_status.png"
        static let Hp = "gamescene_hp.png"
        static let Mp = "gamescene_mp.png"
        static let HpBar = "gamescene_hp_bar.png"
        static let MpBar = "gamescene_mp_bar.png"
        static let MpLast = "gamescene_mp_last.png"
        static let WeaponSlot = "gamescene_weapon_slot.png"
        static let EnemySlot = "gamescene_enemy_slot.png"
        static let EnemyMark = "gamescene_enemy_mark.png"
        static let ReumeButton = "Play.png"
        static let RestartButton = "Restart.png"
        static let ExitButton = "Exit.png"
        static let MonsterHead = "fireMonsterHead"
        
        static let Velocity = 500.0
        static let SelfStatusPanel = "SelfStatusPanel"
        static let EnemyStatusPanel = "EnemyStatusPanel"
        
        //about contact detection
        static let Character = "character"
        static let Monster = "monster"
        static let Fire = "fire"
        static let PoweredFire = "poweredfire"
        static let EnemyFire = "enemyfire"
        static let Enemy = "enemy"
        static let EnemyPoweredFire = "enemypoweredfire"
        
        struct Bitmask {
            static let SceneEdge: UInt32 = 0x1 << 0
            static let Character: UInt32 = 0x1 << 1
            static let Enemy: UInt32 = 0x1 << 2
            static let Fire: UInt32 = 0x1 << 3
            static let EnemyFire: UInt32 = 0x1 << 4
            static let Monster: UInt32 = 0x1 << 5
        }
    }
    
    struct Weapon {
        
        
        //For Select
        struct WeaponType {
            static let Bullet = "Missel"
            static let IceBullet = "IceBullet.png"
            static let FireBullet = "FireBullet.png"
            static let MultiBullet = "MultiBullet.png"
            static let BonusBullet = "DoubleBonus"
            static let Laser = "Ultimate"
            static let Invisibility = "Invisibility.png"
            static let Heal = "Heal.png"
            static let Armor = "Armors.png"
            static let LightBullet = "lightbullet"
            static let AddMp = "AddMp.png"
            static let ExpandEnemy = "ExpandEnemy.png"
        }
        
        //For Shooting
        struct WeaponImage {
            static let Bullet = "Missel"
            static let IceBullet = "ice_bullet.png"
            static let FireBullet = "fire_bullet.png"
            static let MultiBullet = "light_bullet.png"
            static let BonusBullet = "DoubleBonus"
            static let Laser = "Ultimate"
            static let Invisibility = "Invisibility_Cloak"
            static let Heal = "Heal"
            static let Detect = "Detect"
            static let Armor = "Armors.png"
            static let LightBullet = "light_bullet.png"
        }
        
        static let Sets = [
            
            WeaponType.FireBullet:"Keeps opponent flame and deducts him 2 hp/sec",
            WeaponType.IceBullet:"Freezes opponent for 3 sec",
            WeaponType.MultiBullet:"Shot 3 bullets every shot",
            WeaponType.Invisibility:"Let yourself invisible for 8 sec",
            WeaponType.Heal:"Add 50 hp to yourself",
            WeaponType.Armor:"Give yourself an armor and Deducts 70% damage",
            WeaponType.AddMp:"Add 30 mp to yourself",
            WeaponType.ExpandEnemy:"Expand the size of your enemy by 5 times"
        ]
        
        struct Effect {
            static let Fire = "fire_effect.png"
            static let Ice = "freeze"
        }
    }
    
}