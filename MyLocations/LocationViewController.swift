//
//  LocationViewController.swift
//  MyLocations
//
//  Created by kemchenj on 7/2/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationViewController: UITableViewController {

//    var managedObjectContext: NSManagedObjectContext!
    var coreDataStack: CoreDataStack!

    let reuseIdentifier = "LocationCell"

    var locations = [Location]()
}

// MARK: - View

extension LocationViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        let fetchRequest = 
    }
}

// MARK: - TableView DataSource

extension LocationViewController {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)

        let descriptionLabel = cell.viewWithTag(100) as! UILabel
        descriptionLabel.text = "If you can see this"

        let addressLebel = cell.viewWithTag(101) as! UILabel
        addressLebel.text = "Then it works"

        return cell
    }
}