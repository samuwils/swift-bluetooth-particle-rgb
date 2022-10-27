//
//  Alarm.swift
//  SunlightClock
//
//  Created by Samuel Wilson on 10/22/22.
//  Copyright © 2022 Sam Wilson. All rights reserved.
//

import Foundation

class Alarm: NSObject {
    
    var id: UInt16 = 0
    var date = NSDate()
    var enabled: UInt8 = 0
    var lightIntensity: UInt8 = 0
    var noise: UInt8 = 0
    var triggered: UInt8 = 0
    var dataToSend: Data = Data(_: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    
//    init(id:UInt16, date:NSDate, enabled:UInt8, lightIntensity: UInt8, noise: UInt8, triggered:UInt8) {
//        self.id = id
//        self.date = date
//        self.enabled = enabled
//        self.lightIntensity = lightIntensity
//        self.noise = noise
//        self.triggered = triggered
//    }
    
    public func convertToData()
    {
        var data = withUnsafeBytes(of: self.id) {Data($0)}
        dataToSend.replaceSubrange(0...1, with: data)
        
        var secondsFromGMT: Int {return TimeZone.current.secondsFromGMT()}
        let unixTime = UInt32((Int)(self.date.timeIntervalSince1970.rounded()) + secondsFromGMT)
        data = withUnsafeBytes(of: unixTime) {Data($0)}
        dataToSend.replaceSubrange(2...5, with: data)
        
        dataToSend[6] = self.enabled
        dataToSend[7] = self.lightIntensity
        dataToSend[8] = self.noise
        dataToSend[9] = self.triggered
        //dataToSend[10] = 0
        
        
        
    }
    
    public func setFunctionByte(functionbyte: UInt8)
    {
        dataToSend[10] = functionbyte
    }
    
}
