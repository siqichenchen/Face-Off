//
//  BTDiscovery.swift
//  Arduino_Servo
//
//  Created by Owen L Brown on 9/24/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import Foundation
import SpriteKit
import CoreBluetooth
import UIKit

var btAdvertiseSharedInstance = BTAdvertise();

class BTAdvertise: NSObject, CBPeripheralManagerDelegate, CBPeripheralDelegate {
  
    private var peripheralManager: CBPeripheralManager!
    var data: NSData! = "hello".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion:true)
    var service = CBMutableService(type: BLEServiceUUID, primary: true)
    var characteristic: CBMutableCharacteristic!
  //private var peripheralBLE: CBPeripheral?
    var single: Bool = false
  
    override init() {
        super.init()
        print("bta")
        let peripheralQueue = dispatch_queue_create("com.raywenderlich", DISPATCH_QUEUE_SERIAL)
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: peripheralQueue)
    }
    
    
    func peripheralManagerDidUpdateState(peripheral:CBPeripheralManager) {
        
        switch peripheral.state {
            
        case .PoweredOff:
            print("Peripheral - CoreBluetooth BLE hardware is powered off")
            break
        case .PoweredOn:
            print("Peripheral - CoreBluetooth BLE hardware is powered on and ready")
            
            let properties = CBCharacteristicProperties.Notify.union(CBCharacteristicProperties.Read).union(CBCharacteristicProperties.Write)
            
            let permissions = CBAttributePermissions.Readable.union( CBAttributePermissions.Writeable)
            self.characteristic = CBMutableCharacteristic(type: PositionCharUUID, properties: properties,
                value: nil, permissions: permissions)
            
                     
            service.characteristics = [characteristic]
            self.peripheralManager.addService(service)
            
            break
        case .Resetting:
            print("Peripheral - CoreBluetooth BLE hardware is resetting")
            break
        case .Unauthorized:
            print("Peripheral - CoreBluetooth BLE state is unauthorized")
            break
        case .Unknown:
            print("Peripheral - CoreBluetooth BLE state is unknown")
            break
        case .Unsupported:
            print("Peripheral - CoreBluetooth BLE hardware is unsupported on this platform")
            break
        }

    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        
        if (error != nil) {
            print("Service追加失敗！ error: \(error)")
            return
        }
        
        print("Service追加成功！")
       
        self.peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[BLEServiceUUID],CBAdvertisementDataLocalNameKey:UIDevice.currentDevice().name])
    }

    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager,
        error: NSError?){
            
            if error == nil{
                print("Successfully started advertising our beacon data")
                
                let message = "Successfully set up your beacon. " +
                "The unique identifier of our service is: \(BLEServiceUUID)"
                
                print(message)
                
                print(data)
                self.characteristic.value = data;
                self.peripheralManager.updateValue(data, forCharacteristic: self.characteristic, onSubscribedCentrals: nil)
                
                //var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: ("update"), userInfo: nil, repeats: true)
               // timer.fire()
                
            } else {
                print("Failed to advertise our beacon. Error = \(error)")
            }
    }
    
    //Custom data sending handler
    func update(key: String, data: [String: String] = [String:String]()){
        
        if single { return }
        
        var needToBeSend = false
        var stringOfData = ""
        
        if key == "location" {
            stringOfData = key + " " + data["x"]! + " " + data["y"]!
        }
        else if key == "pause" {
            stringOfData = key
        }
            
        else if key == "resume" {
            stringOfData = key
        }
        
        else if key == "hp" {
            stringOfData = key + " " + data["hp"]!
            print("hp",data["hp"])
            if data["hp"] == "0" {
                needToBeSend = true
            }
        }
        
        else if key == "mp" {
            stringOfData = key + " " + data["mp"]!
        }
            
        else if key == "weapon" {
            needToBeSend = true
            stringOfData = key + " " + data["weapon"]!
        }
        
        else if key == "fire-bullet" {
            stringOfData = key + " " + data["x"]!
        }
        else if key == "fire-multibullet" {
            stringOfData = key + " " + data["x"]!
        }
        else if key == "fire-laser" {
            stringOfData = key + " " + data["x"]! + " " + data["laserWidth"]!
        }
        else if key == "character-image" {
            needToBeSend = true
            stringOfData = key + " " + data["chunkNum"]! + " " + data["chunkData"]!
        }
        else if key == "character-image-finish" {
            needToBeSend = true
            stringOfData = key
        }
            
        else if key == "character-image-ready"  {
            needToBeSend = true
            stringOfData = key
        }
        
        if stringOfData != "" {
            let _data = stringOfData.dataUsingEncoding(NSUTF8StringEncoding)
            if needToBeSend {
                while(!self.peripheralManager.updateValue(_data!, forCharacteristic: self.characteristic, onSubscribedCentrals: nil)){
                    //print(data["chunkNum"]!,"retry",++i)
                }
            } else {
                self.peripheralManager.updateValue(_data!, forCharacteristic: self.characteristic, onSubscribedCentrals: nil)
            }
        }
    }
    
    func update(x: CGFloat, y:CGFloat) {
        
        //var pointToSend = CGPointMake(x, y)
        let space = " "
        let string_x_y = "normal " + x.description + space + y.description
        let data = string_x_y.dataUsingEncoding(NSUTF8StringEncoding)

        //let data = NSData(bytes: &pointToSend, length: sizeof(CGPoint))
                
        self.characteristic.value = data;
        self.peripheralManager.updateValue(data!, forCharacteristic: self.characteristic, onSubscribedCentrals: nil)
    }
    
    func updateUltimate(x: CGFloat, y:CGFloat, w:CGFloat) {
        
        //var pointToSend = CGPointMake(x, y)
        let space = " "
        let string_x_y = "ultimate " + x.description + space + y.description + space + w.description
        let data = string_x_y.dataUsingEncoding(NSUTF8StringEncoding)
        
        //let data = NSData(bytes: &pointToSend, length: sizeof(CGPoint))
        
        self.characteristic.value = data;
        self.peripheralManager.updateValue(data!, forCharacteristic: self.characteristic, onSubscribedCentrals: nil)
        
    }
    
    func updateBonusBullet(x: CGFloat, y:CGFloat, type:String) {
        
        //var pointToSend = CGPointMake(x, y)
        let space = " "
        let string_x_y = "bonusHitOpponent " + type + space + y.description + space + x.description
        //print("type:" + string_x_y)
        let data = string_x_y.dataUsingEncoding(NSUTF8StringEncoding)
        
        //let data = NSData(bytes: &pointToSend, length: sizeof(CGPoint))
        
        self.characteristic.value = data;
        self.peripheralManager.updateValue(data!, forCharacteristic: self.characteristic, onSubscribedCentrals: nil)
        
    }
    
    func updateOpponentPos(x: CGFloat, y:CGFloat, w:CGFloat) {
        
        //var pointToSend = CGPointMake(x, y)
        let space = " "
        let string_x_y = "ultimate " + x.description + space + y.description + space + w.description
        let data = string_x_y.dataUsingEncoding(NSUTF8StringEncoding)
        
        //let data = NSData(bytes: &pointToSend, length: sizeof(CGPoint))
        
        self.characteristic.value = data;
        self.peripheralManager.updateValue(data!, forCharacteristic: self.characteristic, onSubscribedCentrals: nil)
        
    }
    
    func updateUltimateHintPos(x: CGFloat, y:CGFloat) {
        
        //var pointToSend = CGPointMake(x, y)
        let space = " "
        let string_x_y = "ultimateHint " + x.description + space + y.description
        let data = string_x_y.dataUsingEncoding(NSUTF8StringEncoding)
        
        //let data = NSData(bytes: &pointToSend, length: sizeof(CGPoint))
        
        self.characteristic.value = data;
        self.peripheralManager.updateValue(data!, forCharacteristic: self.characteristic, onSubscribedCentrals: nil)
        
    }
    
    func updateHitOpponent(health: CGFloat) {
        
        //var pointToSend = CGPointMake(x, y)
        let string_health = "hitOpponent " + health.description
        let data = string_health.dataUsingEncoding(NSUTF8StringEncoding)
        
        //let data = NSData(bytes: &pointToSend, length: sizeof(CGPoint))
        
        self.characteristic.value = data;
        self.peripheralManager.updateValue(data!, forCharacteristic: self.characteristic, onSubscribedCentrals: nil)
        
    }
    
    
    func updateOpponentRealTimePos(x: CGFloat, y:CGFloat) {
        
        //var pointToSend = CGPointMake(x, y)
        let space = " "
        let string_x_y = "realTimePos " + x.description + space + y.description
        let data = string_x_y.dataUsingEncoding(NSUTF8StringEncoding)
        
        //let data = NSData(bytes: &pointToSend, length: sizeof(CGPoint))
        
        self.characteristic.value = data;
        self.peripheralManager.updateValue(data!, forCharacteristic: self.characteristic, onSubscribedCentrals: nil)
        
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        
        //println("\(requests.count) ")
        print("Received from Central!!\n")
        self.sendBTServiceNotificationWithIsBluetoothConnected(true)
        
        for obj in requests {
            
            if let request:CBATTRequest = obj{
                
                let deviceName: String = NSString(data:request.value!, encoding:NSUTF8StringEncoding)! as String
                // print(deviceName)
                
                
                let peripheralConnectionDetails = ["peripheralName": deviceName]
                
                NSNotificationCenter.defaultCenter().postNotificationName("allSet", object: self, userInfo: peripheralConnectionDetails)
                
                
                print("~~Requested value:\(request.value) service uuid:\(request.characteristic.service.UUID) characteristic uuid:\(request.characteristic.UUID)\n")
                
                if request.characteristic.UUID.isEqual(self.characteristic.UUID) {
                    
                    // CBCharacteristicのvalueに、CBATTRequestのvalueをセット
                    self.characteristic.value = request.value;
                }
            }
        }
        
        self.peripheralManager.respondToRequest(requests[0] , withResult: CBATTError.Success)
    }
    

    
    func sendBTServiceNotificationWithIsBluetoothConnected(isBluetoothConnected: Bool) {
        let connectionDetails = ["isConnected": isBluetoothConnected]
        NSNotificationCenter.defaultCenter().postNotificationName(BLEServiceChangedStatusNotification, object: self, userInfo: connectionDetails)
    }
    /*
    
    
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        if (error == nil) {
            println("ERROR: \(error)")
        }
        
        var serviceUDID = CBUUID(string: "00000000-0008-A8BA-E311-F48C90364D99")
        
        var serviceList = peripheral.services.filter{($0 as! CBService).UUID == serviceUDID }
        
        if (serviceList.count > 0) {
            peripheral.discoverCharacteristics(nil, forService: serviceList[0] as! CBService)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!)
    {
        println("!@@@@@@!!@!@@");
        var writeUDID = CBUUID(string: "00000001-0008-A8BA-E311-F48C90364D99")
        var notifyUDID = CBUUID(string: "00000002-0008-A8BA-E311-F48C90364D99")
        
        var streamMessage = NSData(bytes: [1] as [UInt8], length: 1)
        
        peripheral.setNotifyValue(true, forCharacteristic: service.characteristics[2] as! CBCharacteristic)
        
        peripheral.writeValue(streamMessage, forCharacteristic: service.characteristics[1] as! CBCharacteristic, type: CBCharacteristicWriteType.WithoutResponse)
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!,
        error: NSError!) {
            
            
            println("\nCharacteristic \(characteristic.description) isNotifying: \(characteristic.isNotifying)\n")
            
            var ax:CShort = 0;
            var ay:CShort = 0;
            var az:CShort = 0;
            var gx:CShort = 0;
            var gy:CShort = 0;
            var gz:CShort = 0;
            var mx:CShort = 0;
            var my:CShort = 0;
            var mz:CShort = 0;
            
            assert( characteristic.value != nil );
            
            var dataLength = characteristic.value.length;
            
            assert( dataLength == 20 );
            
            var buffer = [UInt8](count: dataLength, repeatedValue: 0)
            
            characteristic.value.getBytes(&buffer, length: dataLength)
            
            ax = CShort(buffer[ 3]) << 8 + CShort(buffer[ 2])
            ay = CShort(buffer[ 5]) << 8 + CShort(buffer[ 4])
            az = CShort(buffer[ 7]) << 8 + CShort(buffer[ 6])
            
            gx = CShort(buffer[ 9]) << 8 + CShort(buffer[ 8])
            gy = CShort(buffer[11]) << 8 + CShort(buffer[10])
            gz = CShort(buffer[13]) << 8 + CShort(buffer[12])
            
            mx = CShort(buffer[15]) << 8 + CShort(buffer[14])
            my = CShort(buffer[17]) << 8 + CShort(buffer[16])
            mz = CShort(buffer[19]) << 8 + CShort(buffer[18])
            
            
            println("ax: \(ax), ay: \(ay),az: \(az), gx: \(gx), gy: \(gy), gz: \(gz), mx: \(mx), my: \(my), mz: \(mz)")
            
            var maxValue:Float = 5000;
            
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if( characteristic.isNotifying )
        {
            peripheral.readValueForCharacteristic(characteristic);
        }
    }
    */


}
