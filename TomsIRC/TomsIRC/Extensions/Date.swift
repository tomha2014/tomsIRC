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
}
