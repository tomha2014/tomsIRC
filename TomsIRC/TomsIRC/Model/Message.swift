//
//  Message.swift
//  KISS_IRC
//
//  Created by tom hackbarth on 3/19/19.
//  Copyright © 2019 thackbarth.com. All rights reserved.
//

import Foundation

enum MessageSender {
    case ourself
    case someoneElse
}


struct Message {
    var message: String
    var senderUsername: String
    var channelName: String
    let messageSender: MessageSender
    var timeStamp:Date
    let groupID:Int
    
    init(message: String, messageSender: MessageSender, username: String, groupID:Int) {
        self.message = message.withoutWhitespace()
        self.messageSender = messageSender
        self.senderUsername = username
        self.channelName = ""
        self.timeStamp = Date()
        self.groupID = groupID
    }
    
    init(message: String, messageSender: MessageSender, username: String, date:Date, groupID:Int) {
        self.message = message.withoutWhitespace()
        self.messageSender = messageSender
        self.senderUsername = username
        self.channelName = ""
        self.timeStamp = date
        self.groupID = groupID
    }
}
