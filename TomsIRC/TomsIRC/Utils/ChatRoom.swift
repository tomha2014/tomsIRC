//
//  ChatRoom.swift
//  KISS_IRC
//
//  Created by tom hackbarth on 3/19/19.
//  Copyright © 2019 thackbarth.com. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol ChatRoomDelegate: class {
    func receivedMessage(message: Message)
    func sentMessage(message: String)
//    func readyToLogin()
//    func LoginComplete()
//    func channelListComplete()
//    func commandReceived(cmd: String)
}

class ChatRoom: NSObject {
    weak var delegate: ChatRoomDelegate?
    
    var loginMode = false
    var listMode = false
    var channelListString = ""
    
    var inputStream: InputStream!
    var outputStream: OutputStream!
    
    let maxReadLength = 1024*5
    
    //1) Set up the input and output streams for message sending
    func setupNetworkCommunication() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           Settings.shared.server as CFString,
                                           6667,
                                           &readStream,
                                           &writeStream)
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        outputStream.delegate = self
        
        inputStream.schedule(in: .main, forMode: RunLoop.Mode.common)
        outputStream.schedule(in: .main, forMode: RunLoop.Mode.common)
        
        inputStream.open()
        outputStream.open()
        
        
    }
    
    
 
    
    func stopChatSession() {
        if inputStream != nil
        {
            inputStream.close()
        }
        if outputStream != nil
        {
            outputStream.close()
        }
    }
}

extension ChatRoom: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            print("new message received")
            readAvailableBytes(stream: aStream as! InputStream)
        case Stream.Event.endEncountered:
            stopChatSession()
        case Stream.Event.errorOccurred:
            print("error occurred")
        case Stream.Event.hasSpaceAvailable:
            print("has space available")
        default:
            print("some other event...")
            break
        }
    }
    
    func saveMessage(channel: String, from: String, message:String) {
        
        let msg = IRCMessage(context: dbStore.shared.context)
        msg.timestamp = Date() as NSDate
        msg.timestampMilli = Int64( Date().millisecondsSince1970 )
        msg.channelName = channel
        msg.from = from
        msg.message = message
        dbStore.shared.Save()
    }
    
    func save(name: String, count: Int, desc:String) {
        
        let channel = IRCChannel(context: dbStore.shared.context)
        channel.name = name
        channel.count = Int32(count)
        channel.desc = desc
        channel.serverID = Settings.shared.serverID
        channel.subscribed = false
        
//        dbStore.shared.Save()
        
    }
    
    private func readAvailableBytes(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        var cmd = "99999"
        
        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)
            
            if numberOfBytesRead < 0 {
                if let _ = inputStream.streamError {
                    break
                }
            }
            
            if var message = processedMessageString(buffer: buffer, length: numberOfBytesRead) {
//                print (message.message)
                
                //                if (Settings.shared.serverID == ""){
                if message.message.contains("001")
                {
                    if message.message.contains(":Welcome")
                    {
                        let s = message.message.split(separator: " ")
                        print (s.first!)
                        Settings.shared.serverID = String(s.first!)
                    }
                }
                //                }
                
                
                
                if (message.message.contains("/NAMES"))
                {
                    return
                }
                
                var words = message.message.components(separatedBy: " ")
                if (message.message.contains(":To connect, type"))
                {
                    sendCmd(message: "/QUOTE PONG \(words.last!)")
                    return
                }
                
                
                if (words.first == "PING")
                {
//                    let parts = message.message.split(separator: ":")
                    let msg = "PONG \(String(describing: words.last!))"
                    sendCmd(message: msg)
                    //                    delegate?.sentMessage(message: msg)
                    return
                }
                
                
                if (words.count > 2)
                {
                    let user = words.removeFirst()
                    let userNameParts = user.components(separatedBy: "!")
                    let userName = userNameParts.first
                    cmd = words.removeFirst()
                    let channel = words.removeFirst()
                    var d = ""
                    words.forEach{ p in
                        d = d + " " + p
                    }
                    if (cmd == "332")
                    {
                        return
                    }
                    

                    
                    if (cmd == "477")
                    {
//                        let msg = "privmsg nickserv register your_password your_email_address"
////                        let msg = "REGISTER uwhY8wgzWw22-zXs.M39p trash@mail.com"
//                        message.channelName = channel
//                        message.message = d.trimmingCharacters(in: .whitespacesAndNewlines)
//                        message.senderUsername = userName!
//                        delegate?.receivedMessage(message: message)
//                        
//                        sendCmd(message: msg)
                        
                        return
                    }
                    
                    if ( cmd == "PRIVMSG" )
                    {
                        if (channel == Settings.shared.userName)
                        {
                            message.channelName = channel
                            message.message = d.trimmingCharacters(in: .whitespacesAndNewlines)
                            message.senderUsername = userName!
                            
                            NotificationCenter.default.post(name: .NewPrivateMessageRecieved, object: message)

                        }
                        else
                        {
                            message.channelName = channel
                            message.message = d.trimmingCharacters(in: .whitespacesAndNewlines)
                            message.senderUsername = userName!
                            saveMessage(channel: channel, from: userName!, message: message.message)
                            NotificationCenter.default.post(name: .NewMessageRecieved, object: message)
                            return
                        }
                    }
                    if ( cmd == "JOIN" )
                    {
                        print ("-----> JOIN")
                        message.message = "\(userName!) has joined"
                        message.senderUsername = userName!
//                        delegate?.receivedMessage(message: message)
                        return
                    }
                    if ( cmd == "QUIT" )
                    {
                        print ("-----> QUIT")
                        message.message = d.trimmingCharacters(in: .whitespacesAndNewlines)
                        message.senderUsername = userName!
//                        delegate?.receivedMessage(message: message)
                        return
                    }
                    
                    if ( cmd == "PING" )
                    {
                        print ("-----> Ping")
                    }
                    
                }
                
                
                if (!listMode)
                {
                    if let index = message.message.index(of: ":") {
                        
                        if (index.encodedOffset == 0)
                        {
                            // Command
    //                        print ("=======  \(Settings.shared.serverID)")
                            let words = message.message.components(separatedBy: " ")
                            let id = words[0]
                            
                            let parts = message.message.components(separatedBy: id)
                            var msg = ""
                            var cmdCode = ""
                            for part in parts {
    //                            print("\(part)")
    //                            var p = part.components(separatedBy: ":")
                                
                                let p = part.components(separatedBy: Settings.shared.userName)
                                msg = msg + p.last!.components(separatedBy: ":").last!+"\n"
                                cmdCode = p.first!.trimmingCharacters(in: .whitespacesAndNewlines)
                                
                                NotificationCenter.default.post(name: .channelListComplete, object: cmdCode)
                                
    //                            print ("\(cmdCode)  \(p.last!.components(separatedBy: ":").last!)")
                            }
                            
//                            if (cmdCode == "465")
//                            {
//                                print("Banded")
//                            }
//                            
//                            if (cmdCode == "INVITE")
//                            {
//                                print ("you have an invation")
//                            }
                            
                            NotificationCenter.default.post(name: .commandRecieved, object: CmdMsg(cmd: cmdCode, msg: message.message))
                            
                            message.message = msg
    //                        message = Message(message: msg, messageSender: message.messageSender, username: message.senderUsername)
                            
    //                        print ("==========")
                        }
                    }
                }
                
                

                
                if (loginMode)
                {
                    if (message.message.contains("/MOTD"))
                    {
                        loginMode = false
//                        delegate?.LoginComplete()
                        NotificationCenter.default.post(name: .loginComplete, object: nil)
                    }
                }
                    if (listMode)
                    {
                        channelListString = channelListString + message.message
                        if (message.message.contains("/LIST"))
                        {
                            listMode = false
                            processChannelList(channelListString: channelListString)
//                            delegate?.channelListComplete()
                            NotificationCenter.default.post(name: .channelListComplete, object: nil)
                        }
                    }
                    else
                    {
                        
                        message.message = message.message.trimmingCharacters(in: .whitespacesAndNewlines)
                        if (message.message.contains("No Ident response"))
                        {
                            NotificationCenter.default.post(name: .readyToLogin, object: nil)
                        }
                }
            }
        }
    }
    
    func findServerName(txt:String, code:String) -> String {
        
        let parts = txt.split(separator: " ")
        
        var lastPart = ""
        for p in parts
        {
            if p == code
            {
                return lastPart
                
            }
            lastPart = String(p)
        }
        return ""
    }
    func processChannelList(channelListString: String)  {
        
        
        let request: NSFetchRequest<IRCChannel> = IRCChannel.fetchRequest()
        let channels: [NSManagedObject] = try! dbStore.shared.context.fetch(request)
        
        self.channelListString = channelListString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let c = findServerName(txt: channelListString, code: "321")
        Settings.shared.serverID = c
        
        let channelList = channelListString.components(separatedBy: "\(Settings.shared.serverID)")
        
        for word in channelList
        {
            let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
            if (trimmed.count>0)
            {
                let parts = trimmed.components(separatedBy: " ")
                if (parts.first!.trimmingCharacters(in: .whitespacesAndNewlines) == "322")
                {
                    var desc = ""
                    let p = trimmed.indexes(of: ":")
                    if (p.count == 0)
                    {
//                      print (trimmed)
                    }
                    else
                    {
                        desc = String(trimmed.suffix(trimmed.count - (p.first! + 1) ))
                    }
                    let front = trimmed.prefix(p.first!).trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    var a = front.components(separatedBy: " ")
                    if (a.count == 4)
                    {
                        let count = a.removeLast()
                        let name = a.removeLast()
    
                        if name != Settings.shared.userName
                        {
                            var found = false
                            for ch in channels as! [IRCChannel]{
                                if (ch.name == name){
                                    found = true
                                    ch.count = Int32(count)!
                                    
                                }
                            }
                            if (!found)
                            {
                                save(name: name, count: Int(count)!, desc: String(desc))
                            }
                        }
                    }
                }
            }
        }
        dbStore.shared.Save()
    }
    
    private func processedMessageString(buffer: UnsafeMutablePointer<UInt8>,
                                        length: Int) -> Message? {
        
        guard let message = String(bytesNoCopy: buffer,
                                   length: length,
                                   encoding: .ascii,
                                   freeWhenDone: false) else {return nil}
        
        if (Settings.shared.serverID.count > 0)
        {
            let cmds = message.components(separatedBy: Settings.shared.serverID)
            if (cmds.count>0)
            {
                for cmd in cmds{
                    print (cmd)
                }
//                print("done")
            }
        }
        
        return Message(message: message, messageSender: MessageSender.someoneElse, username: "server",date: Date() )
        
    }
    
    
    func sendMessage(message: String, channelName: String) {
        
        let data = "PRIVMSG \(channelName) :\(message)\n\r".data(using: .ascii)!
        _ = data.withUnsafeBytes { outputStream.write($0, maxLength: data.count) }
        
    }
    
    func sendCmd(message: String) {
        
        print ("Send Message \(message)")
        
        let data = "\(message)\n\r".data(using: .ascii)!
        _ = data.withUnsafeBytes { outputStream.write($0, maxLength: data.count) }
        
    }

func sendQuitCommand()
    {
        let msg = "Goodbye for now!"
        print ( "=======>>  QUIT \(msg)")
        sendCmd(message: "QUIT \(msg)")
    }
    
    func joinChannel(channelName: String) {
        
        print ( "=======>>  JOIN \(channelName)")
        sendCmd(message: "JOIN \(channelName)")
    }
    
    func leaveChannel(channelName: String) {
        sendCmd(message: "PART \(channelName)")
    }
    
    func namesChannel(channelName: String) {
        sendCmd(message: "NAMES \(channelName)")
    }
    
    func register(nickname: String, email: String, password: String)
    {
        let cmd = "PRIVMSG nickserv :REGISTER \(password) \(email)"
        sendCmd(message: cmd)
    }
    
    func nick(nickname: String) {
        let cmd = "NICK \(nickname)"
        sendCmd(message: cmd)
    }
    
    func verify(nickname: String, verify: String)
    {
        let cmd = "PRIVMSG NickServ :VERIFY REGISTER \(nickname) \(verify)"
        
//        print (cmd)
        sendCmd(message: cmd)
    }
    
    func login(nickName: String, pw:String) {
        // connect chat.freenode.net 6667 mquin:uwhY8wgzWw22-zXs.
        let cmd = "PRIVMSG nickserv :identify \(nickName)  \(pw)"
        //        print (cmd)
        sendCmd(message: cmd)

    }
    func listChannels()  {
        listMode = true
        channelListString = ""
        sendCmd(message: "LIST")
    }
    
    func updateChannelInfo(channelName: String)  {
        listMode = true
        channelListString = ""
        sendCmd(message: "LIST \(channelName)")
    }
}
