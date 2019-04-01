//
//  Settings.swift
//  KISS_IRC
//
//  Created by tom hackbarth on 3/19/19.
//  Copyright © 2019 thackbarth.com. All rights reserved.
//

import Foundation
import CoreData

class Settings
{
    public var nickName = ""
    public var userName:String = ""
    public var password:String = ""
    public var realName = ""
    public var serverPassword = ""
    public var email = ""
    public var server = ""
    public var port:UInt32 = 0
    public var serverID = ""
    public var channels: [NSManagedObject] = []
    
    public var chatroom:ChatRoom
    
    static let shared = Settings()
    var joinedChannels = [String]()

    
    private init() {
        
        let defaults = UserDefaults.standard
        self.email = defaults.getStringFromDefaults(key: "email")
        self.userName = defaults.getStringFromDefaults(key: "userName")
        self.password = defaults.getStringFromDefaults(key: "password")
        self.realName = defaults.getStringFromDefaults(key: "realName")
        self.nickName = defaults.getStringFromDefaults(key: "nickName")
        self.server = defaults.getStringFromDefaults(key: "server")
        self.serverPassword = defaults.getStringFromDefaults(key: "serverPassword")
        
        self.port = 0 //defaults.object(forKey: "port") as! UInt32
        
        self.email = "tomhackbarth.dev@gmail.com"
        self.userName = "tomha"
        self.nickName = "userName"
        self.password = "ffhj3FFhjh"
        
        if (port == 0)
        {
            self . port = 6667
        }
        
        if (self.server == "")
        {
//            self.server = "us.undernet.org"
            self.server = "chat.freenode.net"
        }
        
        if (self.userName == "")
        {
            self.userName = "bubblesim"
        }
        
        chatroom = ChatRoom()
    }
    
    public func savePrefs() {
        let defaults = UserDefaults.standard
        print (self.userName)
        print (self.realName)
        print (self.nickName)
        print (self.server)
        
        defaults.set(self.email, forKey: "email")
        defaults.set(self.password, forKey: "password")
        defaults.set(self.userName, forKey: "userName")
        defaults.set(self.realName, forKey: "realName")
        defaults.set(self.nickName, forKey: "nickName")
        defaults.set(self.server, forKey: "server")
        defaults.set(self.serverPassword, forKey: "serverPassword")
    }
    
    func okToConnect() -> Bool {
        
        if (self.server.count == 0){
            return false
        }
        
        if (self.email.count == 0){
            return false
        }
        
        if (self.password.count == 0){
            return false
        }

        if (self.nickName.count == 0){
            return false
        }
        
        
        
        //if allready connected do not reconnect
        if (chatroom.inputStream != nil)
        {
            if (connected() )
            {
                return false
            }
        }
        
        return (server.count > 0) && (userName.count > 0)
    }
    
    func connected() -> Bool {
        if (chatroom.inputStream == nil)
        {
            return false
        }
        return chatroom.inputStream.streamStatus == .open
    }
    
    func LeaveChannel(channelName:String)
    {
        let i = joinedChannels.firstIndex(of: channelName)
        joinedChannels.remove(at: i!)
        chatroom.leaveChannel(channelName: channelName)
    }
    
}



