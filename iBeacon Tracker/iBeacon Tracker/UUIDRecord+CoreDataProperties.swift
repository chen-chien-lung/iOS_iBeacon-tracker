//
//  UUIDRecord+CoreDataProperties.swift
//  iBeacon Tracker
//
//  Created by Joe Chen on 2019/6/6.
//  Copyright © 2019 Joe Chen. All rights reserved.
//
//

import Foundation
import CoreData


extension UUIDRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UUIDRecord> {
        return NSFetchRequest<UUIDRecord>(entityName: "UUIDRecord")
    }

    @NSManaged public var uuid: String?
    @NSManaged public var name: String?
    @NSManaged public var index: Int16

}
