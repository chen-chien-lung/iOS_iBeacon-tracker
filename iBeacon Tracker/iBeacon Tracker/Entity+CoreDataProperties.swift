//
//  Entity+CoreDataProperties.swift
//  iBeacon Tracker
//
//  Created by Joe Chen on 2019/6/6.
//  Copyright © 2019 Joe Chen. All rights reserved.
//
//

import Foundation
import CoreData


extension Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Entity")
    }

    @NSManaged public var uuid: String?

}
