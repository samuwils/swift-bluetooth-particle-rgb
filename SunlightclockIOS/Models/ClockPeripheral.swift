//
//  ParticlePerihperal.swift
//  ParticleBluetoothiOS
//
//  Created by Jared Wolff on 8/9/19.
//  Copyright © 2019 Jared Wolff. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol ClockDelegate {
    
}

class ClockPeripheral: NSObject {
    
    /// MARK: - Particle LED services and charcteristics Identifiers
    
    public static let sunlightClockServiceUUID     = CBUUID.init(string: "e557382d-becd-42aa-ac23-44ff13942103")
    public static let alarmCharacteristicUUID   =    CBUUID.init(string: "1dae9408-c1c6-4c73-b0db-5f0b2cd62c3f")



    
}
