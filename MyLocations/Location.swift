//
//  Location.swift
//  MyLocations
//
//  Created by kemchenj on 6/29/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class Location: NSManagedObject, MKAnnotation {

// Insert code here to add functionality to your managed object subclass

}

extension Location {

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var title: String? {
        if locationDescription.isEmpty {
            return "(No Description)"
        } else {
            return locationDescription
        }
    }

    var subtitle: String? {
        return category
    }
}