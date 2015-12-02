//
//  Tools.swift
//  Faceoff
//
//  Created by Huaying Tsai on 11/21/15.
//  Copyright © 2015 Liang. All rights reserved.
//


import UIKit
import GLKit
import SpriteKit
import Foundation



class Tools {
    
    static func getLocalValue(key :String) -> AnyObject?{
        let defaults = NSUserDefaults.standardUserDefaults()
        if let value: AnyObject = defaults.objectForKey(key){
            return value
        }
        return nil
    }
    
    
    static func setLocalValue(key :String,value :AnyObject){
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(value, forKey: key)
        defaults.synchronize()
    }
    
    static func dictionaryToNSData(dictionary: NSDictionary) -> NSData {
        return NSKeyedArchiver.archivedDataWithRootObject(dictionary)
    }
    
    static func NSDataToDictionary(nsdata: NSData) -> NSDictionary?{
        return NSKeyedUnarchiver.unarchiveObjectWithData(nsdata) as? NSDictionary
    }

    static func playSound(audioName: String, node: SKNode){
        let sound = SKAction.playSoundFileNamed(audioName, waitForCompletion: true)
        node.runAction(sound,withKey: "soundPlay")
    }
    static func delay(delay:Double, closure:()->()) {
        
        dispatch_after(
            dispatch_time( DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
    }
    
    static func cropImageToCircle(image: UIImage) -> UIImage{
        let imageView = UIImageView(frame: CGRectMake(0,0,image.size.height,image.size.height))
        imageView.image = image
        imageView.contentMode = .Center
        imageView.layer.cornerRadius = image.size.height/2;
        imageView.layer.masksToBounds = true
        
        var layer1: CALayer = CALayer()
        
        layer1 = imageView.layer
        UIGraphicsBeginImageContext(CGSize(width:image.size.height,height:image.size.height))
        layer1.renderInContext(UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

}
