//
//  ViewController.swift
//  ParticleBluetoothiOS
//
//  Created by Jared Wolff on 8/9/19.
//  Copyright © 2019 Jared Wolff. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate {

    // Outlet for sliders
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var batteryPercentLabel: UILabel!
    
    // Characteristics
    private var redChar: CBCharacteristic?
    private var greenChar: CBCharacteristic?
    private var blueChar: CBCharacteristic?
    private var battChar: CBCharacteristic?
    
    // Properties
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View loaded")
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // If we're powered on, start scanning
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state update")
        if central.state != .poweredOn {
            print("Central is not powered on")
        } else {
            print("Central scanning for", ParticlePeripheral.particleLEDServiceUUID);
//            centralManager.scanForPeripherals(withServices: [ParticlePeripheral.particleLEDServiceUUID],
//                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
//
            centralManager.scanForPeripherals(withServices: nil,
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }

    // Handles the result of the scan
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("Discovered \(peripheral )")
        print("Discovered \(peripheral.name ?? "")")
        
        print("Discovered \(advertisementData )")
        
        guard peripheral.name != nil else {return}
          
          if peripheral.name! == "Blinky Example" {
          
            print("Sensor Found!")
            //stopScan
              self.centralManager.stopScan()
            
            //connect
              self.centralManager.connect(peripheral, options: nil)
            self.peripheral = peripheral
              self.peripheral.delegate = self
           
           }
        //if peripheral.name
        // We've found it so stop scan
        //self.centralManager.stopScan()
        
        // Copy the peripheral instance
        //self.peripheral = peripheral
        //self.peripheral.delegate = self
        
        // Connect!
        //self.centralManager.connect(self.peripheral, options: nil)
        
    }
    
    // The handler if we do connect succesfully
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            print("Connected to your Particle Board")
            peripheral.discoverServices([ParticlePeripheral.particleLEDServiceUUID]);
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == self.peripheral {
            print("Disconnected")
            
            redSlider.isEnabled = false
            greenSlider.isEnabled = false
            blueSlider.isEnabled = false
            
            redSlider.value = 0
            greenSlider.value = 0
            blueSlider.value = 0
            
            self.peripheral = nil
            
            // Start scanning again
            print("Central scanning for", ParticlePeripheral.particleLEDServiceUUID);
            centralManager.scanForPeripherals(withServices: [ParticlePeripheral.particleLEDServiceUUID],
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    // Handles discovery event
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == ParticlePeripheral.particleLEDServiceUUID {
                    print("LED service found")
                    //Now kick off discovery of characteristics
                    peripheral.discoverCharacteristics([ParticlePeripheral.redLEDCharacteristicUUID,
                                                             ParticlePeripheral.batteryCharacteristicUUID], for: service)
                }

            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                     didUpdateNotificationStateFor characteristic: CBCharacteristic,
                     error: Error?) {
        print("Enabling notify ", characteristic.uuid)
        
        if error != nil {
            print("Enable notify error")
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                     didUpdateValueFor characteristic: CBCharacteristic,
                     error: Error?) {
        if( characteristic == battChar ) {
            print("Battery:", characteristic.value![0])
            
            batteryPercentLabel.text = "\(characteristic.value![0])%"
        }
    }
    
    // Handling discovery of characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == ParticlePeripheral.redLEDCharacteristicUUID {
                    print("Red LED characteristic found")
                    
                    // Set the characteristic
                    redChar = characteristic
                    
                    // Unmask red slider
                    redSlider.isEnabled = true
                } 
                else if characteristic.uuid == ParticlePeripheral.batteryCharacteristicUUID {
                                    print("Battery characteristic found");
                                    
                                    // Set the char
                                    battChar = characteristic
                                    
                                    // Subscribe to the char.
                                    peripheral.setNotifyValue(true, for: characteristic)
                                }
            }
        }
    }

    private func writeLEDValueToChar( withCharacteristic characteristic: CBCharacteristic, withValue value: Data) {
        
        // Check if it has the write property
        //if characteristic.properties.contains(.writeWithoutResponse) && peripheral != nil {
            print("value: ", value);
            peripheral.writeValue(value, for: characteristic, type: .withResponse)

        //}
        
    }

    @IBAction func redChanged(_ sender: Any) {
        print("red:",redSlider.value);
        var slider:UInt8 = UInt8(redSlider.value)
        if (slider > 125)
        {
            slider = 1
        }
        else
        {
            slider = 0
        }
        writeLEDValueToChar( withCharacteristic: redChar!, withValue: Data([slider]))
        
    }
    
    @IBAction func greenChanged(_ sender: Any) {
        print("green:",greenSlider.value);
        let slider:UInt8 = UInt8(greenSlider.value)
        writeLEDValueToChar( withCharacteristic: greenChar!, withValue: Data([slider]))
    }
    

    
    
    
}

