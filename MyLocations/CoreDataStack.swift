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

    func fatalCoreDataError(_ error: Error) {
        print("*** fatal error: \(error)")
        NotificationCenter.default.post(name: Notification.Name(rawValue: MyManagedObjectContextSaveDidFailNotification), object: nil)
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

    lazy var storeURL: URL = {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last

        guard let newURL = url?.appendingPathComponent("DataStore.sqlite") else {
            fatalError("Error to find sqlite file")
        }

        return newURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: "DataModel", withExtension: "momd") else {
            fatalError("Could not find data model in app bundle")
        }

        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing model from: \(modelURL)")
        }

        return model
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator

        return managedObjectContext
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)

        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.storeURL, options: [NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true])
        } catch {
            fatalError("Error adding persistent store at document: \(error)")
        }

        return coordinator
    }()

}













