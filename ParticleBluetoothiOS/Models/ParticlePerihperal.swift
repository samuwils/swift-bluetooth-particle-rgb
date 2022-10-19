//
//  ParticlePerihperal.swift
//  ParticleBluetoothiOS
//
//  Created by Jared Wolff on 8/9/19.
//  Copyright © 2019 Jared Wolff. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol ParticleDelegate {
    
}

class ParticlePeripheral: NSObject {
    
    /// MARK: - Particle LED services and charcteristics Identifiers
    
    public static let particleLEDServiceUUID     = CBUUID.init(string: "de8a5aac-a99b-c315-0c80-60d4cbb51224")
    public static let redLEDCharacteristicUUID   = CBUUID.init(string: "5b026510-4088-c297-46d8-be6c736a087a")
    public static let batteryCharacteristicUUID  = CBUUID.init(string: "61a885a4-41c3-60d0-9a53-6d652a70d29c")

    

    
}
