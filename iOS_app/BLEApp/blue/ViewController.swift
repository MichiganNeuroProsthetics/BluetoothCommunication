//
//  ViewController.swift
//  blue
//
//  Created by Earth Patel on 7/18/20.
//  Copyright © 2020 Earth Patel. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var myPeripheral: CBPeripheral!
    var On:Bool!
    
    @IBOutlet weak var State: UILabel!
    @IBAction func ButtonConnect(_ sender: Any) {
        On = true
    }
    
    @IBAction func ButtonDisconnect(_ sender: Any) {
        On = false
        centralManager.cancelPeripheralConnection(myPeripheral)
        State.text = "Disconnected from BLE"
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            print("BLE powered on")
            // Turned on
            central.scanForPeripherals(withServices: nil, options: nil)
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
        if On == true{
            if let pname = peripheral.name{
                // change this to the name of the BLE module
                if pname == "Earth’s MacBook Pro" {
                    self.centralManager.stopScan()
                    
                    self.myPeripheral = peripheral
                    self.myPeripheral.delegate = self
                
                    self.centralManager.connect(peripheral, options: nil)
                    State.text = "Connected to: " + pname
                }
                print(pname)
            }
        }
        else{
            State.text = "Not Connected to anything."
        }
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.myPeripheral.discoverServices(nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

}

