//
//  AppSettings.swift
//  Task
//
//  Created by Hiren Joshi on 07/23/22.
//

import Foundation

struct TimeFormatter {
    
    static func formateSecondsToMS(_ seconds: Float) -> String {
        let interval = TimeInterval(seconds)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "m:ss"
        
        return formatter.string(from: Date(timeIntervalSinceReferenceDate: interval))
    }
}
