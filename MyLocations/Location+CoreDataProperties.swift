//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by kemchenj on 6/28/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

extension Location {

    @nonobjc class func fetchRequest() -> NSFetchRequest {
        return NSFetchRequest(entityName: "Location");
    }

    @NSManaged var longitude: Double
    @NSManaged var latitude: Double
    @NSManaged var category: String
    @NSManaged var locationDescription: String
    @NSManaged var date: NSDate
    @NSManaged var placemark: CLPlacemark?




}
