//
//  EnemyCharacterLoader.swift
//  Faceoff
//
//  Created by Huaying Tsai on 11/24/15.
//  Copyright © 2015 Liang. All rights reserved.
//

import Foundation
import SpriteKit

class EnemyCharacterLoader: NSObject {
    
    var enemyImageBase64String = ""
    var isEnemyGetReady: Bool = false
    
    func preload(){
        CharacterManager.deleteEnemyFromLocalStrorage()
        setupBlueToothDataHandler()
        sendNotificationOfReadyToReceive()
    }
    
    func sendNotificationOfReadyToReceive(){

        btAdvertiseSharedInstance.update("character-image-ready")
    }
    
    func setupBlueToothDataHandler(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateByInfoOfEnemy:"), name: "getInfoOfEnemy", object: nil)
        sleep(1)
    }
    
    func updateByInfoOfEnemy(notification: NSNotification) {
        
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject>
        
        //Receiving chunk data
        if let info: [String] = userInfo["character-image"] as? [String] {
            if let chunkNum = Int(info[0]) {
                let chunk = info[1]
                print("receive",chunkNum,chunk)
                enemyImageBase64String += chunk
            }
        }
            
        //Receiving Finish Signal
        else if let _: [String] = userInfo["character-image-finish"] as? [String] {
            let decodedImage = decodeBase64DataToImage()
            CharacterManager.saveEnemyCharacterToLocalStorage(decodedImage)
            //self.addChild(SKSpriteNode(texture: SKTexture(image: decodedImage!)))
            
        }
            
        //Receiving the Signal that Enemy get ready to reiceive chunk data
        else if let _: [String] = userInfo["character-image-ready"] as? [String] {
            
            let a = NSDate().timeIntervalSinceReferenceDate
            sendCharacterImageDataToEnemy()
            print(NSDate().timeIntervalSinceReferenceDate - a)
        }
        
    }
    
    func decodeBase64DataToImage() -> UIImage {
        let decodedData = NSData(base64EncodedString: enemyImageBase64String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        let decodedImage = UIImage(data: decodedData!)
        return decodedImage!
    }
    
    func sendCharacterImageDataToEnemy(){
        let image: UIImage = CharacterManager.getPickedCharacterSmallFromLocalStorage()!
        
        let imageData = UIImagePNGRepresentation(image)
        
        let base64String = imageData!.base64EncodedStringWithOptions(.EncodingEndLineWithLineFeed)
        
        
        var chunks = [[Character]]()
        let chunkSize = 100
        
        for (i, character) in base64String.characters.enumerate() {
            if i % chunkSize == 0 {
                chunks.append([Character]())
            }
            chunks[i/chunkSize].append(character)
        }
        
        //Send Chunks of Data
        for (i,chunk) in chunks.enumerate() {
            btAdvertiseSharedInstance.update("character-image",data: ["chunkNum":String(i),"chunkData":String(chunk)])
            print(i,String(chunk))
        }
        
        //Send Finish Signal
        btAdvertiseSharedInstance.update("character-image-finish")
    }

    static func isLoaded() -> Bool {
        if let _ = CharacterManager.getEnemyCharacterFromLocalStorage() {
            return true
        }
        return false
        
    }
}