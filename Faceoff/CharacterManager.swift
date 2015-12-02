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
    
    enum localStorageKeys {
        static let keyOfPickedCharacterNumber = "keyOfPickedCharacterNumber"
    }
    
    static let maxOfCandidateNumber = Constants.CharacterManager.maxOfCandidateNumber
    
    static func getCandidateCharactersFromLocalStorage() -> [UIImage?] {
        var imagePool:[UIImage?] = []
        for i in 0..<maxOfCandidateNumber {
            if let image = getImageFromLocalStorage("Candidate\(i)") {
                imagePool.append(image)
            }else{
                imagePool.append(nil)
            }
        }
        return imagePool
    }
    
    static func getCharacterFromLocalStorage(index: Int = maxOfCandidateNumber - 1) -> UIImage? {
        return getImageFromLocalStorage("Candidate\(index)")
    }
    
    static func getPickedCharacterFromLocalStorage() -> UIImage?{
        let pickedId = getPickedCharacterNumber()
        return getImageFromLocalStorage("Candidate\(pickedId)")
    }
    
    static func getPickedCharacterSmallFromLocalStorage() -> UIImage?{
        let pickedId = getPickedCharacterNumber()
        return getImageFromLocalStorage("CandidateSmall\(pickedId)")
    }
    
    static func getEnemyCharacterFromLocalStorage() -> UIImage? {
        return getImageFromLocalStorage("Enemy")
    }
    
    static func deleteCharacterFromLocalStorage(index: Int) {
        let name = "Candidate\(index)"
        deleteCharacterFromLocalStorage(name)
    }
    
    static func deleteEnemyFromLocalStrorage(){
        deleteCharacterFromLocalStorage("Enemy")
    }
    
    static func deleteCharacterFromLocalStorage(name: String){
        let fileManager = NSFileManager.defaultManager()
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let getImagePath = (paths as NSString).stringByAppendingPathComponent("\(name).png")
        //let getImagePath = (paths as NSString).stringByAppendingPathComponent("Candidate\(index).jpg")
        
        do {
            try fileManager.removeItemAtPath(getImagePath)
            print("File \(getImagePath) is deleted")
            
        }catch{
            print("File \(getImagePath) cannot be deleted")
        }
    }
    
    static func getImageFromLocalStorage(imageName: String) -> UIImage? {
        let fileManager = NSFileManager.defaultManager()
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        // Check file saved successfully
        let getImagePath = (paths as NSString).stringByAppendingPathComponent("\(imageName).png")
        //let getImagePath = (paths as NSString).stringByAppendingPathComponent("\(imageName).jpg")
    
        if (fileManager.fileExistsAtPath(getImagePath)){
            print("File \(getImagePath) is available")
            let image: UIImage = UIImage(contentsOfFile: getImagePath)!
            return image
            //return CharacterManager.cropImageToCircle(image)
        }else{
            print("File \(getImagePath) is not available")
            return nil
        }
    }
    
    static func saveEnemyCharacterToLocalStorage(image: UIImage){
        self.saveImageToLocalStorage("Enemy", image: image)
    }
    
    static func saveCandidateCharacterToLocalStorage(image: UIImage, index: Int, small: Bool = false){
        var imagePrefixName = "Candidate"
        if small {
            imagePrefixName += "Small"
        }
        self.saveImageToLocalStorage("\(imagePrefixName)\(index)",image: image)
        setPickedCharacterNumber(index)
    }
    
    static func saveImageToLocalStorage(imageName: String, image: UIImage){
        let fileManager = NSFileManager.defaultManager()
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        let filePathToWrite = "\(paths)/"+imageName+".png"
        //let filePathToWrite = "\(paths)/"+imageName+".jpg"

    
        let imageData: NSData = UIImagePNGRepresentation(CharacterManager.cropImageToCircle(image))!
        //let imageData: NSData = UIImageJPEGRepresentation(CharacterManager.cropImageToCircle(image), 0.1)!
        
        fileManager.createFileAtPath(filePathToWrite, contents: imageData, attributes: nil)
        
        print("save file \(filePathToWrite) ")
    }
    
    static func setPickedCharacterNumber(number: Int){
        Tools.setLocalValue(localStorageKeys.keyOfPickedCharacterNumber, value: number)
    }
    
    
    
    static func getPickedCharacterNumber() -> Int {
        if let number = Tools.getLocalValue(localStorageKeys.keyOfPickedCharacterNumber) as? Int {
            return number
        }else{
            return maxOfCandidateNumber - 1
        }
    }
    
    static func cropImageToCircle(image: UIImage) -> UIImage{
        let photoView = UIImageView(frame: CGRectMake(0,0,image.size.height,image.size.height))
        photoView.image = image
        photoView.contentMode = .Center
        photoView.layer.borderWidth = 5
        photoView.layer.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.3).CGColor
        photoView.layer.cornerRadius = image.size.height/2;
        photoView.layer.masksToBounds = true
        
        var layer1: CALayer = CALayer()
        
        layer1 = photoView.layer
        UIGraphicsBeginImageContext(CGSize(width:image.size.height,height:image.size.height))
        layer1.renderInContext(UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

}