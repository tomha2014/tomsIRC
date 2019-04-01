//
//  IRCMessage+CoreDataProperties.swift
//  TomsIRC
//
//  Created by tom hackbarth on 4/1/19.
//  Copyright © 2019 thackbarth.com. All rights reserved.
//
//

import Foundation
import CoreData


extension IRCMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<IRCMessage> {
        return NSFetchRequest<IRCMessage>(entityName: "IRCMessage")
    }

    @NSManaged public var channelName: String?
    @NSManaged public var from: String?
    @NSManaged public var message: String?
    @NSManaged public var timestamp: NSDate?
    @NSManaged public var timestampMilli: Int64

}
