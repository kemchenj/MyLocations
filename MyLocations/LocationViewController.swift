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

//    var locations = [Location]()

    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Location")

        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: self.coreDataStack.managedObjectContext)
        fetchRequest.entity = entity

        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchRequest.fetchBatchSize = 20

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.coreDataStack.managedObjectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: "Locations")

        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()

    deinit {
        fetchedResultsController.delegate = nil
    }
}


// MARK: - View

extension LocationViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        performFetch()
    }

    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
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
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! LocationCell
        cell.configure(forLocation: location)

        return cell
    }
}


// MARK: - TableView Delegate

extension LocationViewController {

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

        coreDataStack.managedObjectContext.deleteObject(locations[indexPath.row])
        coreDataStack.saveAllContext()

        reloadData()
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}


// MARK: - Segue

extension LocationViewController {

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditLocation" {
            let navigationController = segue.destinationViewController as! UINavigationController

            let controller = navigationController.topViewController as? LocationDetailsViewController

            controller?.coreDataStack = coreDataStack

            if let indexPath = tableView.indexPathForCell(sender as! LocationCell) {
                let location = locations[indexPath.row]
                controller?.locationToEdit = location
            }
        }
    }
}


// MARK: - Fetched Result Controller Delegate

extension LocationViewController: NSFetchedResultsControllerDelegate {


}






