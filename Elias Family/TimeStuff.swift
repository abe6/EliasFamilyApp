//
//  TimeStuff.swift
//  Elias Family
//
//  Created by Abraham  Elias on 19/1/19.
//  Copyright © 2019 Abraham  Elias. All rights reserved.
//

import Foundation

public class TimeStuff {
    
    static func unixStampToTime(stamp: Double) -> String {
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        
        let date = Date(timeIntervalSince1970: stamp)
        // get the date time String from the date object
        let time = formatter.string(from: date)
        
        return time
    }
}

extension TimeInterval {
    func format(using units: NSCalendar.Unit) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = units
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        
        return formatter.string(from: self)
    }
}
