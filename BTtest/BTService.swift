//
//  BTService.swift
//  Arduino_Servo
//
//  Created by Owen L Brown on 10/11/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import Foundation
import CoreBluetooth

/* Services & Characteristics UUIDs */
let BLEServiceUUID = CBUUID(string: "035A7775-49AA-42BD-BBDB-E2AE77782966")
let PositionCharUUID = CBUUID(string: "F48A2C23-BC54-40FC-BED0-60EDDA139F47")
let BLEServiceChangedStatusNotification = "kBLEServiceChangedStatusNotification"

class BTService: NSObject, CBPeripheralDelegate {
  var peripheral: CBPeripheral?
  var positionCharacteristic: CBCharacteristic?
  
  init(initWithPeripheral peripheral: CBPeripheral) {
    super.init()
    
    
   // peer = MCPeerID(displayName: UIDevice.currentDevice().name)

    self.peripheral = peripheral
    self.peripheral?.delegate = self
  }
  
  deinit {
    self.reset()
  }
  
  func startDiscoveringServices() {
    self.peripheral?.discoverServices([BLEServiceUUID])
  }
  
  func reset() {
    if peripheral != nil {
      peripheral = nil
    }
    
    // Deallocating therefore send notification
    self.sendBTServiceNotificationWithIsBluetoothConnected(false)
  }
  
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        let uuidsForBTService: [CBUUID] = [PositionCharUUID]
        
        if (peripheral != self.peripheral) {
            // Wrong Peripheral
            return
        }
        
        if (error != nil) {
            return
        }
        
        if ((peripheral.services == nil) || (peripheral.services!.count == 0)) {
            // No Services
            return
        }
        
        for service in peripheral.services! {
            if service.UUID == BLEServiceUUID {
                peripheral.discoverCharacteristics(uuidsForBTService, forService: service )
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if (peripheral != self.peripheral) {
            // Wrong Peripheral
            return
        }
        
        if (error != nil) {
            return
        }
        
        if(service.UUID == BLEServiceUUID){
            for characteristic in service.characteristics! {
                if characteristic.UUID == PositionCharUUID {
                    self.positionCharacteristic = characteristic
                    
                    print(self.positionCharacteristic);
                    peripheral.setNotifyValue(true, forCharacteristic: self.positionCharacteristic!)
                    //peripheral.readValueForCharacteristic(self.positionCharacteristic);
                    
                    // Send notification that Bluetooth is connected and all required characteristics are discovered
                    self.sendBTServiceNotificationWithIsBluetoothConnected(true)
                }
            }
            
        }
        
        /*
        for characteristic in service.characteristics {
        if characteristic.UUID == PositionCharUUID {
        self.positionCharacteristic = (characteristic as! CBCharacteristic)
        peripheral.setNotifyValue(true, forCharacteristic: characteristic as! CBCharacteristic)
        
        peripheral.readValueForCharacteristic(characteristic as! CBCharacteristic);
        
        // Send notification that Bluetooth is connected and all required characteristics are discovered
        self.sendBTServiceNotificationWithIsBluetoothConnected(true)
        }
        }
        */
    }
    
    func peripheral(peripheral: CBPeripheral,
        didUpdateValueForCharacteristic characteristic: CBCharacteristic,
        error: NSError?)
    {
        //println(characteristic)
        
        if (error != nil) {
            print("Failed... error: \(error)")
            return
        }
        
        // var out: String = NSString(data:characteristic.value, encoding:NSUTF8StringEncoding)! as String
        // var string : NSString = NSString(data: characteristic.value, encoding: NSUTF8StringEncoding)!
        
        let out: String = NSString(data:characteristic.value!, encoding:NSUTF8StringEncoding)! as String
        
        print(out)
        
        var fullNameArr = out.characters.split {$0 == " "}.map { String($0) }
        
        let connectionDetails = ["point": out]

        if(fullNameArr[0] == "ultimate"){
            
            NSNotificationCenter.defaultCenter().postNotificationName("getUltimateLocation", object: self, userInfo: connectionDetails)
            
            
        }
        else if(fullNameArr[0] == "normal"){
            
            NSNotificationCenter.defaultCenter().postNotificationName("getLocation", object: self, userInfo: connectionDetails)
            
        }

        
        
  
        /*
        let properties = (CBCharacteristicProperties.Notify |
        CBCharacteristicProperties.Read |
        CBCharacteristicProperties.Write)
        let permissions = (CBAttributePermissions.Readable | CBAttributePermissions.Writeable)
        let characteristic2 = CBMutableCharacteristic(type: PositionCharUUID, properties: properties,
        value: nil, permissions: permissions)
        */
        
        
        /*
        var receivedPair = UnsafePointer<DoublePoint>(characteristic.value.bytes).memory
        println(CGFloat(receivedPair.x))
        println(CGFloat(receivedPair.y))
        */
        
        // println("Succeeded! service uuid: \(characteristic.service.UUID), characteristic uuid: \(characteristic.UUID), value: \(characteristic.value)")
    }
    
    func peripheral(peripheral: CBPeripheral,
        didWriteValueForCharacteristic characteristic: CBCharacteristic,
        error: NSError?)
    {
        if (error != nil) {
            print("Write失敗...error: \(error)")
            return
        }
        
        print("Write成功！")
    }

    

  // Mark: - Private
  
  func writePosition(position: UInt8) {
    // See if characteristic has been discovered before writing to it
    if self.positionCharacteristic == nil {
      return
    }
    
    // Need a mutable var to pass to writeValue function
    var positionValue = position
    let data = NSData(bytes: &positionValue, length: sizeof(UInt8))
    self.peripheral?.writeValue(data, forCharacteristic: self.positionCharacteristic!, type: CBCharacteristicWriteType.WithResponse)
  }
  
  func sendBTServiceNotificationWithIsBluetoothConnected(isBluetoothConnected: Bool) {
    let connectionDetails = ["isConnected": isBluetoothConnected]
    NSNotificationCenter.defaultCenter().postNotificationName(BLEServiceChangedStatusNotification, object: self, userInfo: connectionDetails)
  }
  
}