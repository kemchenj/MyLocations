//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by kemchenj on 6/29/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData
import CoreLocation

extension Location {

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var placemark: CLPlacemark?
    @NSManaged var locationDescription: String
    @NSManaged var date: NSDate
    @NSManaged var category: String
    @NSManaged var photoID: NSNumber?

}
