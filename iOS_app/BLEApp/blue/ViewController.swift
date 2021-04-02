//
//  ViewController.swift
//  blue
//
//  Created by Earth Patel on 7/18/20.
//  Copyright © 2020 Earth Patel. All rights reserved.
//

import UIKit
import CoreBluetooth

var successful = false
var myPeripheral: CBPeripheral!

struct CBUUIDs{
    static let kBLEService_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"

    static let kBLE_Characteristic_uuid_Tx = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"

    static let kBLE_Characteristic_uuid_Rx = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"



    static let BLEService_UUID = CBUUID(string: kBLEService_UUID)

    static let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)

    static let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)

    static let BLE_char = CBUUID(string: "FFE1")


}

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    
    private var txCharacteristic: CBCharacteristic!
    private var rxCharacteristic: CBCharacteristic!

    @IBOutlet weak var sendHelloWorld: UIButton!
    
    @IBAction func sendHelloWorld(_ sender: Any) {
        writeOutgoingValue(data: "Hello World")
    }
    
    
    @IBOutlet weak var Switch: UISwitch!
    @IBAction func Switch(_ sender: UISwitch){
        if sender.isOn == false{
            if successful == true{
                centralManager.cancelPeripheralConnection(myPeripheral)
                myPeripheral = nil
                successful = false
            }
            else{
                let alert = UIAlertController(title: "Bluetooth error", message: "Bluetooth doesn't seem to be connecting. Please make sure your arm is on and bluetooth is turned on in settings. Please try again in some time.", preferredStyle: .alert)
                let okay = UIAlertAction(title: "Okay", style: .default){
                    (action) in print(action)
                }
                alert.addAction(okay);
                present(alert, animated: true, completion: nil)
            }
        }
        else{
            if successful == false{
                centralManager.scanForPeripherals(withServices: nil, options: nil)
            }
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            print("BLE powered on")
            // Turned on
            if successful == false{
                central.scanForPeripherals(withServices: nil, options: nil)
            }
        }
        else {
            print("Something wrong with BLE ")
            // Not on, but can have different issues
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        /* allows us to see what available BLE devices that we can connect to are.
         if we want our app to automatically connect to one device we need to find the BLE module's name and make
         pname equal to that name in the if statement.
        */
        if successful == false{
            if let pname = peripheral.name{
                // change this to the name of the BLE module
                if pname == "BT05" {
                    self.centralManager.stopScan()
                    
                    myPeripheral = peripheral
                    myPeripheral.delegate = self
                
                    self.centralManager.connect(peripheral, options: nil)
                    print("Connected to: " + pname)
                    successful = true
                }
                print(pname)
            }
        }
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        myPeripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("*******************************************************")
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }

        guard let services = peripheral.services else {
            return
        }

        //We need to discover the all characteristic

        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
        print("Discovered Services: \(services)")

    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
     
          var characteristicASCIIValue = NSString()
     
          guard characteristic == rxCharacteristic,
     
          let characteristicValue = characteristic.value,
          let ASCIIstring = NSString(data: characteristicValue, encoding: String.Encoding.utf8.rawValue) else { return }
     
          characteristicASCIIValue = ASCIIstring
     
          print("Value Recieved: \((characteristicASCIIValue as String))")
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
                return
        }
        
        print("Found \(characteristics.count) characteristics.")

        for characteristic in characteristics {
            print(characteristic.uuid)
            if characteristic.uuid.isEqual(CBUUIDs.BLE_char)  {
                rxCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: rxCharacteristic!)
                peripheral.readValue(for: characteristic)
                print("RX Characteristic: \(rxCharacteristic.uuid)")
            }
            if characteristic.uuid.isEqual(CBUUIDs.BLE_char){
                txCharacteristic = characteristic
                print("TX Characteristic: \(txCharacteristic.uuid)")
            }

        }
    }
    
    
    func writeOutgoingValue(data: String){
          
        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
        
        if let peripheral = myPeripheral {
              
          if let txCharacteristic = txCharacteristic {
                  
            peripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
              }
          }
      }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

}

