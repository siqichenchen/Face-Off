//
//  GameViewController.swift
//  BTtest
//
//  Created by Shao-Hsuan Liang on 10/18/15.
//  Copyright (c) 2015 Liang. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            
            var sceneData: NSData?
            do {
                sceneData = try  NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
            } catch _ as NSError {
                
            }
            
            //var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData!)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


        
        let scene = MainScene(size: view.bounds.size)
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        skView.presentScene(scene)
        
        
        
        
        // Pause the view (and thus the game) when the app is interrupted or backgrounded
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleApplicationWillResignActive:", name: UIApplicationWillResignActiveNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleApplicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)

        // Watch Bluetooth connection
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("connectionChanged:"), name: BLEServiceChangedStatusNotification, object: nil)
//
//        // Start the Bluetooth advertise process
//        btAdvertiseSharedInstance
//        
//        // Start the Bluetooth discovery process
//        btDiscoverySharedInstance
//        
//        

    }
    
    func handleApplicationWillResignActive (note: NSNotification) {
        
        let skView = self.view as! SKView
        skView.paused = true
    }
    
    func handleApplicationDidBecomeActive (note: NSNotification) {
        
        let skView = self.view as! SKView
        skView.paused = false
    }

    
    func connectionChanged(notification: NSNotification) {
        // Connection status changed. Indicate on GUI.
        let userInfo = notification.userInfo as! [String: Bool]
        
        dispatch_async(dispatch_get_main_queue(), {
            // Set image based on connection status
            if let isConnected: Bool = userInfo["isConnected"] {
                if isConnected {
                    
                    
                    let tit = NSLocalizedString("Alert", comment: "")
                    let msg = NSLocalizedString("Received from Central!", comment: "")
                    let alert:UIAlertView = UIAlertView()
                    alert.title = tit
                    alert.message = msg
                    alert.delegate = self
                    alert.addButtonWithTitle("OK")
                    alert.addButtonWithTitle("Cancel")
                    alert.show()
                    
                    
                } else {
                    
                    let tit = NSLocalizedString("Alert", comment: "")
                    let msg = NSLocalizedString("Not Connected!", comment: "")
                    let alert:UIAlertView = UIAlertView()
                    alert.title = tit
                    alert.message = msg
                    alert.delegate = self
                    alert.addButtonWithTitle("OK")
                    alert.addButtonWithTitle("Cancel")
                    //alert.show()
                    
                    //self.imgBluetoothStatus.image = UIImage(named: "Bluetooth_Disconnected")
                }
            }
        });
    }
    

    

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        
        return UIInterfaceOrientationMask.LandscapeLeft
    }
    /*
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
