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

        let sortDesctiptor1 = NSSortDescriptor(key: "category", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDesctiptor1, sortDescriptor2]

        fetchRequest.fetchBatchSize = 20

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.coreDataStack.managedObjectContext,
                                                                  sectionNameKeyPath: "category",
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

        navigationItem.rightBarButtonItem = editButtonItem()

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
        //        let fetchRequest = NSFetchRequest(entityName: "Location")
        //
        //        do {
        //            if let results = try coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest) as? [Location]{
        ////                self.locations = results
        tableView.reloadData()
        //            }
        //        } catch {
        //            fatalError("There was an error fetching the list of location")
        //        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.name
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

        let location = fetchedResultsController.objectAtIndexPath(indexPath)
        coreDataStack.managedObjectContext.deleteObject(location as! Location)
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
                let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location
                controller?.locationToEdit = location
            }
        }
    }
}


// MARK: - Fetched Result Controller Delegate

extension LocationViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print("*** Controller Will Change Content")
        tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

        switch type {
        case .Insert:
            print("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            print("*** NSFetchedResultsChangeDelete (object)")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            print("*** NSFetchedResultsChangeUpdate (object)")
            if let cell = tableView.cellForRowAtIndexPath(indexPath!) as? LocationCell{
                let location = fetchedResultsController.objectAtIndexPath(indexPath!) as! Location
                cell.configure(forLocation: location)
            }
        case .Move:
            print("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {

        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            print("*** NSFetchedResultsChangeInsert (section)")
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            print("*** NSFetchedResultsChangeDelete (section)")
        case .Update:
            print("*** NSFetchedResultsChangeUpdate (section)")
        case .Move:
            print("*** NSFetchedResultsChangeMove (section)")
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("*** NSFetchedResultsDidChangeContent")
        tableView.endUpdates()
    }
    
}






