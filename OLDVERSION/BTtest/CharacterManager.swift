//
//  CharacterManager.swift
//  BTtest
//
//  Created by Huaying Tsai on 11/10/15.
//  Copyright © 2015 Liang. All rights reserved.
//
import UIKit
import Foundation

class CharacterManager {
    
    
    static func getCharacterFromLocalStorage() -> UIImage?{
        
        let fileManager = NSFileManager.defaultManager()
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        // Check file saved successfully
        let getImagePath = (paths as NSString).stringByAppendingPathComponent("User_Image.png")
        print(getImagePath)
        if (fileManager.fileExistsAtPath(getImagePath)){
            print("FILE AVAILABLE")
            
            //Pick Image and Use accordingly
            let image: UIImage = UIImage(contentsOfFile: getImagePath)!
            // let data: NSData = UIImagePNGRepresentation(imageis)
            return image
        }else{
            print("FILE NOT AVAILABLE")
            return nil
        }
    }
    
    static func saveCharacterToLocalStorage(image: UIImage){
        
        let fileManager = NSFileManager.defaultManager()
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        let filePathToWrite = "\(paths)/User_Image.png"
        
        let imageData: NSData = UIImagePNGRepresentation(image)!
        //let jpgImageData = UIImageJPEGRepresentation(image, 1.0)
        
        fileManager.createFileAtPath(filePathToWrite, contents: imageData, attributes: nil)
    }
    
    
}