//
//  NewToothManager.swift
//  ChatDemo
//
//  NewTooth is a very simplified Bluetooth Peripheral Manager
//  It is designed to connect to any SWABadge BLE devices, and
//    1: Receive any "tap" messages (user has tapped the badge)
//    2: Send any "buzz" messages (badge vibrates)

import CoreBluetooth

class NewToothManager: NSObject {
    static let shared = NewToothManager()
    
    let peripheralDeviceName = "SWA Heart Comms"
    
    var cbCentralManager: CBCentralManager?
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?
    
    override init() {
        super.init()
        cbCentralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @objc func sendBuzz(msg: String) {
        if let peripheral = peripheral,
           let characteristic = characteristic,
           let data = msg.data(using: .utf8) {
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        }
    }
}

extension NewToothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
            print("Scanning...")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
      guard peripheral.name != nil else {return}
      
      if peripheral.name! == peripheralDeviceName {
      
        print("Sensor Found!")
        //stopScan
        cbCentralManager?.stopScan()
        
        //connect
        cbCentralManager?.connect(peripheral, options: nil)
        self.peripheral = peripheral
       
       }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
      //discover all service
      
      peripheral.discoverServices(nil)
      peripheral.delegate = self

    }
    
    /**
    When the peripheral disconnects, attempt to recconnect
    
    - parameter peripheral: The peripheral which provide this action
    */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // try to regain connection
        self.peripheral = nil
        self.characteristic = nil
        cbCentralManager?.scanForPeripherals(withServices: nil, options: nil)
    }

}

//MARK:- CBPeripheralDelegate
extension NewToothManager: CBPeripheralDelegate {
      
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let services = peripheral.services {
            
            //discover characteristics of services
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
      
       if let characteristics = service.characteristics,
          let characteristic = characteristics.first {
        
           // assumption is any message would be a "tap" from the user
           self.characteristic = characteristic
           // here let's try to set the connected peripheral to send notifications
           service.peripheral?.setNotifyValue(true, for: characteristic)
    
      }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor: CBCharacteristic, error: Error?) {
        
        let str = String(decoding: self.characteristic?.value ?? Data(), as: UTF8.self)
        NotificationCenter.default.post(name: Notification.Name.swaBadgeTapped, object: str)
    }
    
}

extension Notification.Name {
    static let swaBadgeTapped = Notification.Name("swaBadgeReceivedTap")
    static let swaBadgeBuzz = Notification.Name("swaBadgeSendBuzz")
}
