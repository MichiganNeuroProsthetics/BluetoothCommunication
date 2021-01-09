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

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!

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
    
    func peripheral(_ peripheral: CBPeripheral,
           didUpdateValueFor characteristic: CBCharacteristic,
           error: Error?){}
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

}

