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
    @IBOutlet weak var sendAlarmPressed: UIButton!
    @IBOutlet weak var delAlarmPressed: UIButton!
    @IBOutlet weak var editAlarmPressed: UIButton!
    
    // Characteristics
    private var redChar: CBCharacteristic?
    private var greenChar: CBCharacteristic?
    private var blueChar: CBCharacteristic?
    private var battChar: CBCharacteristic?
    private var alarmChar: CBCharacteristic?
    
    private var testalarm: Alarm?
    private var testalarm1  = Alarm()
    
    private var alarms = [Alarm]()
    
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
            print("Central scanning for", ClockPeripheral.sunlightClockServiceUUID);
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
        print("Discovered name \(peripheral.name ?? "")")
        
        print("Discovered ad data \(advertisementData )")
        
        guard peripheral.name != nil else {return}
          
          if (peripheral.name! == "Sunlight Clock" ||  peripheral.name! == "Blinky Example"  ){
          
            print("Clock Found!")
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
            print("Connected to your Clock Board")
            peripheral.discoverServices([ClockPeripheral.sunlightClockServiceUUID]);
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == self.peripheral {
            print("Disconnected")
            
            redSlider.isEnabled = false
            greenSlider.isEnabled = false
            blueSlider.isEnabled = false
            
            sendAlarmPressed.isEnabled = false
            delAlarmPressed.isEnabled = false
            editAlarmPressed.isEnabled = false
            
            redSlider.value = 0
            greenSlider.value = 0
            blueSlider.value = 0
            
            self.peripheral = nil
            
            // Start scanning again
            print("Central scanning for", ClockPeripheral.sunlightClockServiceUUID);
            centralManager.scanForPeripherals(withServices: [ClockPeripheral.sunlightClockServiceUUID],
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    // Handles discovery event
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == ClockPeripheral.sunlightClockServiceUUID {
                    print("LED service found")
                    //Now kick off discovery of characteristics
                    peripheral.discoverCharacteristics([ClockPeripheral.alarmCharacteristicUUID], for: service)
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
                if characteristic.uuid == ClockPeripheral.alarmCharacteristicUUID {
                    print("Alarm characteristic found")
                    
                    // Set the characteristic
                    //redChar = characteristic
                    alarmChar = characteristic
                    // Unmask red slider
                    redSlider.isEnabled = true
                    
                    sendAlarmPressed.isEnabled = true
                    delAlarmPressed.isEnabled = true
                    editAlarmPressed.isEnabled = true
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
    
    private func writeAlarmValueToChar( withCharacteristic characteristic: CBCharacteristic, withValue value: Data) {
        
        // Check if it has the write property
        //if characteristic.properties.contains(.writeWithoutResponse) && peripheral != nil {
        

        
        if(value[0] == 1)
        {
            
            var newAlarm = Alarm()
            newAlarm.id = UInt16.random(in: 1000..<2000)
            newAlarm.date = NSDate()
            newAlarm.enabled = 1
            newAlarm.lightIntensity = 20
            newAlarm.noise = 3
            newAlarm.triggered = 0
            
            newAlarm.convertToData()
            print(value[0])
            newAlarm.setFunctionByte(functionbyte: value[0])
            
            if(alarms.count < 10)
            {
                alarms.append(newAlarm)
            }
            
            peripheral.writeValue(newAlarm.dataToSend, for: characteristic, type: .withResponse)
        }
        if(value[0] == 2)
        {
            //pick random alarm to delete
            if(alarms.count > 0)
            {
                let index = Int.random(in: 0..<alarms.count)
                alarms[index].setFunctionByte(functionbyte: value[0])
                alarms[index].noise = 10
                alarms[index].convertToData()
                peripheral.writeValue(alarms[index].dataToSend, for: characteristic, type: .withResponse)
                alarms.remove(at: index)
            }
        }
        if(value[0] == 3)
        {
            //pick random alarm to edit
            if(alarms.count > 0)
            {
                alarms[0].setFunctionByte(functionbyte: value[0])
                alarms[0].noise = 10
                alarms[0].convertToData()
                peripheral.writeValue(alarms[0].dataToSend, for: characteristic, type: .withResponse)
            }
            
        }
        printAllAlarms()
        
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
    

    @IBAction func sendAlarmPressed(_ sender: UIButton) {
        
        print("Send Alarm button pressed")
        writeAlarmValueToChar( withCharacteristic: alarmChar!, withValue: Data(_:[0x01]))
    }
    
    @IBAction func delAlarmPressed(_ sender: UIButton) {
        print("Delete Alarm button pressed")
        writeAlarmValueToChar( withCharacteristic: alarmChar!, withValue: Data(_:[0x02]))
        
    }
    
    @IBAction func editAlarmPressed(_ sender: UIButton) {
        print("Edit Alarm button pressed")
        writeAlarmValueToChar( withCharacteristic: alarmChar!, withValue: Data(_:[0x03]))
    }
    
    private func printAllAlarms() {
        
        for object in alarms{
            print(object.id)
        }

    }
    
}

