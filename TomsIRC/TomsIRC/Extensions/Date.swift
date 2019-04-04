//
//  Date.swift
//  Bubble_IRC
//
//  Created by tom hackbarth on 3/27/19.
//  Copyright © 2019 thackbarth.com. All rights reserved.
//

import Foundation

extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    func isEqualTo(_ date: Date) -> Bool {
        return self == date
    }
    
    func isGreaterThan(_ date: Date) -> Bool {
        return self > date
    }
    
    func isSmallerThan(_ date: Date) -> Bool {
        return self < date
    }

    
    func toDateString() -> String {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("MMM dd yyy")
        return df.string(from: self)
    }
    
    func toHeaderString() -> String {
        
        if (toDateString() == Date().toDateString())
        {
            return "Today"
        }
        
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("MMM dd")
        return df.string(from: self)
    }
    
}
