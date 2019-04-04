//
//  MessageGroup.swift
//  TomsIRC
//
//  Created by tom hackbarth on 4/3/19.
//  Copyright © 2019 thackbarth.com. All rights reserved.
//

import Foundation

class MessageGroup
{
    let name:String
    let id:Int
    let date:Date
    var msgCount:Int = 0
    var messages = [Message]()
    
    init(date:Date, id:Int) {
        
        self.date = date
        self.id = id
        
        if Calendar.current.isDateInToday(date)
        {
            self.name = "Today"
            return
        }
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MMMM dd"
        self.name = dateFormatterGet.string(from: date)
    }
}
