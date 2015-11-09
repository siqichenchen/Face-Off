//
//  BTDiscovery.swift
//  Arduino_Servo
//
//  Created by Owen L Brown on 9/24/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import Foundation
import CoreBluetooth

let btDiscoverySharedInstance = BTDiscovery();

class BTDiscovery: NSObject, CBCentralManagerDelegate {
  
  private var centralManager: CBCentralManager?
  private var peripheralBLE: CBPeripheral?
  
  override init() {
	super.init()
	
	let centralQueue = dispatch_queue_create("com.Faceoff", DISPATCH_QUEUE_SERIAL)
	centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    
  }
  
  func startScanning() {
    if let central = centralManager {
      central.scanForPeripheralsWithServices([BLEServiceUUID], options: nil)
    }
  }
    

  var bleService: BTService? {
    didSet {
        print("!!!!?!?!?!?!?")
      if let service = self.bleService {
        service.startDiscoveringServices()
      }
    }
  }
  

    func disconnect(){
        self.centralManager?.cancelPeripheralConnection(self.peripheralBLE!)
    }
    
    func sendToPeripheral(){
        
        
        let valuemoto2 = 13
        let value: UInt8 = UInt8(valuemoto2 & 0xFF)
        let data = NSData(bytes: [value] as [UInt8], length: 1)
        
        
        self.bleService!.peripheral! .writeValue(data, forCharacteristic: (self.bleService?.positionCharacteristic)!, type: CBCharacteristicWriteType.WithResponse)
    }
    
    
  // MARK: - CBCentralManagerDelegate
  
  func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
    // Be sure to retain the peripheral or it will fail during connection.
    
    print("Find device!")

    
    self.peripheralBLE = peripheral
    // Connect to peripheral
    centralManager!.connectPeripheral(peripheral, options: nil)
    
    // Validate peripheral information
    if ((self.peripheralBLE == nil) || (self.peripheralBLE!.name == nil) || (self.peripheralBLE!.name == "")) {
      return
    }

    
    // If not already connected to a peripheral, then connect to this one
    if ((self.peripheralBLE == nil) || (self.peripheralBLE?.state == CBPeripheralState.Disconnected)) {
      // Retain the peripheral before trying to connect
      self.peripheralBLE = peripheral
      
      // Reset service
      self.bleService = nil
      
      // Connect to peripheral
      central.connectPeripheral(peripheral, options: nil)
    }
  }
  
  func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
    
    print("Device Connected!")

    self.peripheralBLE = peripheral

    if (self.peripheralBLE == nil) {
      return;
    }

    // Create new service class
    if (peripheral == self.peripheralBLE) {
      self.bleService = BTService(initWithPeripheral: peripheral)
    }
    
    // Stop scanning for new devices
    central.stopScan()
  }
  
  func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
    
    self.peripheralBLE = peripheral
    if (self.peripheralBLE == nil) {
      return;
    }
    
    // See if it was our peripheral that disconnected
    if (peripheral == self.peripheralBLE) {
      self.bleService = nil;
      self.peripheralBLE = nil;
    }
    
    // Start scanning for new devices
    self.startScanning()
  }
  
  // MARK: - Private
  
  func clearDevices() {
    self.bleService = nil
    self.peripheralBLE = nil
  }
  
  func centralManagerDidUpdateState(central: CBCentralManager) {

    switch (central.state) {
        
    case CBCentralManagerState.PoweredOff:
        print("Hello new Print with new line1");

        self.clearDevices()
        break
      
    case CBCentralManagerState.Unauthorized:
        print("Hello new Print with new Unauthorized");

      // Indicate to user that the iOS device does not support BLE.
      break
      
    case CBCentralManagerState.Unknown:
        print("Hello new Print with new Unknown");

      // Wait for another event
        break
      
    case CBCentralManagerState.PoweredOn:
        print("Hello new Print with new PoweredOn");

        self.startScanning()
        break
      
    case CBCentralManagerState.Resetting:
        print("Hello new Print with new Resetting");

        self.clearDevices()
        break
      
    case CBCentralManagerState.Unsupported:
        print("Hello new Print with new Unsupported");

        break
    }
  }

}
