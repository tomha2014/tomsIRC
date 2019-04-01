//
//  IRCChannel+CoreDataProperties.swift
//  TomsIRC
//
//  Created by tom hackbarth on 4/1/19.
//  Copyright © 2019 thackbarth.com. All rights reserved.
//
//

import Foundation
import CoreData


extension IRCChannel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<IRCChannel> {
        return NSFetchRequest<IRCChannel>(entityName: "IRCChannel")
    }

    @NSManaged public var count: Int32
    @NSManaged public var desc: String?
    @NSManaged public var name: String?
    @NSManaged public var serverID: String?
    @NSManaged public var subscribed: Bool

}
