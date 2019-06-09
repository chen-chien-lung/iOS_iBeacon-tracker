//
//  iBeaconRecordManageContext.swift
//  iBeacon Tracker
//
//  Created by Joe Chen on 2019/6/6.
//  Copyright © 2019 Joe Chen. All rights reserved.
//

import Foundation
import CoreData
import UIKit



class RecordContext {
    private static let sharedContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // Properties
    
    let string: String
    // Initialization
    private init(string: String) {
        self.string = string
    }
    // Accessors
    class func shared() -> NSManagedObjectContext {
        return sharedContext
    }
    
}
