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

        tableView.backgroundColor = UIColor.blackColor()
        tableView.separatorColor = UIColor(white: 1, alpha: 0.2)
        tableView.indicatorStyle = .White

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
        return sectionInfo.name.uppercaseString
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! LocationCell
        cell.configure(forLocation: location)

        let selectionView = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = UIColor(white: 1, alpha: 0.2)
        cell.selectedBackgroundView = selectionView

        return cell
    }
}


// MARK: - TableView Delegate

extension LocationViewController {

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location
            location.removePhotoFile()
            coreDataStack.managedObjectContext.deleteObject(location)
            coreDataStack.saveAllContext()
        }
        
        reloadData()
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let labelRect = CGRect(x: 15,
                               y: tableView.sectionHeaderHeight - 14,
                               width: 300,
                               height: 14)
        let label = UILabel(frame: labelRect)
        label.font = UIFont.boldSystemFontOfSize(11)
        // 对tableView(_, titleForHeaderInSection:_)这个方法进行拆包
        label.text = tableView.dataSource!.tableView!(tableView, titleForHeaderInSection: section)
        label.textColor = UIColor(white: 1.0, alpha: 0.4)
        label.backgroundColor = UIColor.clearColor()

        let separatorRect = CGRect(x: 15,
                                   y: tableView.sectionHeaderHeight - 0.5,
                                   width: tableView.bounds.size.width - 15,
                                   height: 0.5)
        let separator = UIView(frame: separatorRect)
        separator.backgroundColor = tableView.separatorColor

        let viewRect = CGRect(x: 0,
                              y: 0,
                              width: tableView.bounds.size.width,
                              height: tableView.sectionHeaderHeight)
        let view = UIView(frame: viewRect)
        view.backgroundColor = UIColor(white: 0, alpha: 0.85)
        view.addSubview(label)
        view.addSubview(separator)

        return view
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






