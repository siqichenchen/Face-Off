//
//  CameraViewController.swift
//  BTtest
//
//  Created by Huaying Tsai on 11/12/15.
//  Copyright © 2015 Liang. All rights reserved.
//


import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var photoPickButton = UIView()
    var backButton = UIView()
    var currentPicking = Constants.CharacterManager.maxOfCandidateNumber - 1
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        //let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        var frontCamera: AVCaptureDevice!
        for device in videoDevices {
            if let device = device as? AVCaptureDevice {
                if device.position == AVCaptureDevicePosition.Front {
                    frontCamera = device
                    break
                }
            }
        }
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: frontCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.frame = self.view.frame
                
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
                //previewLayer!.backgroundColor = UIColor.blackColor().CGColor
                self.view.layer.addSublayer(previewLayer!)
                self.view.addSubview(self.createCameraOverlay())
                self.view.addSubview(self.createPhotoPickButton())
                self.view.addSubview(self.createBackButton())

                captureSession!.startRunning()
   
            }
        }
        
        let photoPickGesture = UITapGestureRecognizer(target: self, action: "handlePhotoPickButtonTap:")
        self.photoPickButton.addGestureRecognizer(photoPickGesture)
        
        let backGesture = UITapGestureRecognizer(target: self, action: "handleBackButtonTap:")
        self.backButton.addGestureRecognizer(backGesture)
        
    }
    
    func handlePhotoPickButtonTap(sender:UITapGestureRecognizer){
        photoPick()
    }
    
    func handleBackButtonTap(sender:UITapGestureRecognizer){
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    func photoPick(){
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    
                    let image = UIImage(CGImage: cgImageRef!, scale: 5, orientation: UIImageOrientation.Up)
                  
                    let imageSmall = UIImage(CGImage: cgImageRef!, scale: 17, orientation: UIImageOrientation.Up)
                    
                    CharacterManager.saveCandidateCharacterToLocalStorage(image, index: self.currentPicking)
                    
                    CharacterManager.saveCandidateCharacterToLocalStorage(imageSmall, index: self.currentPicking, small: true)
                    
                    self.dismissViewControllerAnimated(true, completion: {
                        NSNotificationCenter.defaultCenter().postNotificationName("PhotoPickerFinishedNotification", object: self, userInfo: nil)
                        
                    })
                }
            })
        }

    }
    
        
    func createCameraOverlay() -> UIView
    {
        
        let overlayView = UIImageView(image: UIImage(named: Constants.CameraScene.Interface))
        //overlayView.alpha = 1
        overlayView.frame = self.view.frame
        overlayView.contentMode = .ScaleAspectFill
        
        //overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true
        
        return overlayView
    }
    
    func createPhotoPickButton() -> UIView{
        
        let buttonImage = UIImage(named: Constants.CameraScene.Button)

        let button = UIImageView(image: resize(buttonImage!,ratio: 0.7))

        photoPickButton.frame = button.frame
        photoPickButton.center = CGPointMake(self.view.frame.width * 0.9,self.view.frame.midY)
        
        photoPickButton.addSubview(button)
        
        return photoPickButton
    }
    
    func createBackButton() -> UIView {
        let buttonImage = UIImage(named: Constants.CameraScene.BackButton)
        
        let size = CGSizeMake(CGFloat(Constants.Scene.BackButtonSizeWidth) ,CGFloat(Constants.Scene.BackButtonSizeHeight))
        let button = UIImageView(image: resize(buttonImage!,size: size))
        
        backButton.frame = button.frame
        backButton.center = CGPointMake(button.frame.width/2,self.view.frame.height-button.frame.height/2)
        
        
        backButton.addSubview(button)
        
        return backButton

    }
    
    func resize(image: UIImage, ratio: CGFloat) -> UIImage?{
        
        let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(ratio, ratio))
        return resize(image,size: size)
    }
    
    func resize(image: UIImage, size :CGSize) -> UIImage?{
        
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }

}

