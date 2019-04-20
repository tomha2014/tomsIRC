//
//  Notifications.swift
//  TomsIRC
//
//  Created by tom hackbarth on 4/1/19.
//  Copyright © 2019 thackbarth.com. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let loginComplete = Notification.Name("loginComplete")
    static let channelListComplete = Notification.Name("channelListComplete")
    static let readyToLogin = Notification.Name("readyToLogin")
    static let commandRecieved = Notification.Name("commandRecieved")
    static let updateMasterChannelList = Notification.Name("updateMasterChannelList")
    static let NewMessageRecieved = Notification.Name("NewMessageRecieved")
    static let NewPrivateMessageRecieved = Notification.Name("NewPrivateMessageRecieved")
}
