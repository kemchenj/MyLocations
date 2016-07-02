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

    var coreDataStack: CoreDataStack!

    let reuseIdentifier = "LocationCell"

    var locations = [Location]()
}

// MARK: - View

extension LocationViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let fetchRequest =  NSFetchRequest()
        print(coreDataStack)
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: coreDataStack.managedObjectContext)
        fetchRequest.entity = entity

        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        do {
            let foundObjects = try coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest)

            locations = foundObjects as! [Location]

        } catch {
            coreDataStack.fatalCoreDataError(error)
        }
    }

    override func viewWillAppear(animated: Bool) {
        reloadData()
    }
}

// MARK: - TableView DataSource

extension LocationViewController {

    func reloadData() {
        let fetchRequest = NSFetchRequest(entityName: "Location")

        do {
            if let results = try coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest) as? [Location]{
                self.locations = results
                tableView.reloadData()
            }
        } catch {
            fatalError("There was an error fetching the list of location")
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let location = locations[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! LocationCell
        cell.configure(forLocation: location)

        return cell
    }
}

// MARK: - TableView Delegate

extension LocationViewController {

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

//        let fetchRequest = NSFetchRequest(entityName: "Location")
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: )
//
//        do {
//            try coreDataStack.managedObjectContext.executeRequest(deleteRequest)
//        } catch {
//            fatalError("Failed to delete object: \(error)")
//        }

        coreDataStack.managedObjectContext.deleteObject(locations[indexPath.row])
        coreDataStack.saveAllContext()

        reloadData()
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}