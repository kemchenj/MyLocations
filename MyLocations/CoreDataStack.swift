//
//  CoreDataStack.swift
//  MyLocations
//
//  Created by kemchenj on 7/2/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import Foundation
import CoreData


class CoreDataStack: NSObject {

    static var sharedInstance = CoreDataStack()

    let MyManagedObjectContextSaveDidFailNotification = "MyManagedObjectContextSaveDidFailNotification"

    func fatalCoreDataError(error: ErrorType) {
        print("*** fatal error: \(error)")
        NSNotificationCenter.defaultCenter().postNotificationName(MyManagedObjectContextSaveDidFailNotification, object: nil)
    }

    func saveAllContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print("Error: \(error)")
            }
        }
    }

    lazy var storeURL: NSURL = {
        let url = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last

        guard let newURL = url?.URLByAppendingPathComponent("DataStore.sqlite") else {
            fatalError("Error to find sqlite file")
        }

        return newURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd") else {
            fatalError("Could not find data model in app bundle")
        }

        guard let model = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing model from: \(modelURL)")
        }

        return model
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)

        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator

        return managedObjectContext
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)

        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: self.storeURL, options: [NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true])
        } catch {
            fatalError("Error adding persistent store at document: \(error)")
        }

        return coordinator
    }()

}













