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

    @nonobjc class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location");
    }

    @NSManaged var longitude: Double
    @NSManaged var latitude: Double
    @NSManaged var date: Date?
    @NSManaged var locationDescription: String?
    @NSManaged var category: String?
    @NSManaged var placemark: CLPlacemark?

}
