//
//  GroupManager.swift
//  TomsIRC
//
//  Created by tom hackbarth on 4/4/19.
//  Copyright © 2019 thackbarth.com. All rights reserved.
//

import Foundation
import CoreData

class GroupManager {
    
    private var todaysGroupID = 0
    private var groups  = [MessageGroup]()
    private var msgs: [NSManagedObject] = []

    
    func addMessage(Message: msg)  {
        
    }
    
    func getNumberOfGroups() -> Int {
        return groups.count
    }
    
    func getGroupByIndex(index:Int) -> MessageGroup! {
        if (index>groups.count)
        {
            return nil
        }
        
        return groups[index]
    }
    
    func buildOutTableDate(channelName:String)  {
        
        let predicate = NSPredicate(format: "channelName == '\(channelName)'" )
        let request: NSFetchRequest<IRCMessage> = IRCMessage.fetchRequest()
        request.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        request.sortDescriptors = [sortDescriptor]

        msgs = try! dbStore.shared.context.fetch(request)

        for i in 0..<msgs.count
        {
            let msg = msgs[i] as! IRCMessage
            let group = findGroupId(date: msg.timestamp! as Date)
            let m = Message(message: msg.message!, messageSender: .someoneElse, username: msg.from!, date: msg.timestamp as! Date)
            //            messages.append(m)
            group.messages.append(m)
        }
        
    }
    
    func findGroupId(date:Date) -> MessageGroup {
        
        let dStr = date.toDateString()
        //        print ( dStr )
        
        if (groups.isEmpty)
        {
            todaysGroupID = todaysGroupID + 1;
            let group = MessageGroup(date: date, id: todaysGroupID)
            group.msgCount = group.msgCount + 1
            groups.append(group)
            return group
        }
        
        for g in groups
        {
            let ds = g.date.toDateString()
            if (ds == dStr)
            {
                g.msgCount = g.msgCount + 1
                return g
            }
        }
        
        todaysGroupID = todaysGroupID + 1;
        let group = MessageGroup(date: date, id: todaysGroupID)
        group.msgCount = group.msgCount + 1
        groups.append(group)
        return group
    }
    
    func newMessageRecieved(msg:Message)  {
        
    }
    
    func findTodaysGroup() -> MessageGroup! {
        let count = groups.count
        for g in groups
        {
            print (g.name)
            if (g.date.isToday())
            {
                return g
            }
        }
        return nil
    }

}
