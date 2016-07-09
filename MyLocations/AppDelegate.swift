//
//  AppDelegate.swift
//  MyLocations
//
//  Created by kemchenj on 5/24/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let coreDataStack: CoreDataStack = CoreDataStack.sharedInstance

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        customizeAppearence()

        let tabBarController = window?.rootViewController as! UITabBarController

        if let viewControllers = tabBarController.viewControllers {
            for child in viewControllers {
                if let child = child as? UINavigationController, top = child.topViewController as? LocationViewController {
                    top.coreDataStack = coreDataStack
                    let _ = top.view
                } else {
                    let controller = child as? CurrentLocationViewController
                    controller?.coreDataStack = coreDataStack
                }
            }
        }

        listenForFatalCoreDataNotifications()

        return true
    }

    func applicationDidEnterBackground(application: UIApplication) {
        coreDataStack.saveAllContext()
    }

    func applicationWillTerminate(application: UIApplication) {
        coreDataStack.saveAllContext()
    }
}



// MARK: - Appearence

extension AppDelegate {

    func customizeAppearence() {
        UINavigationBar.appearance().barTintColor = UIColor.blackColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

        UITabBar.appearance().barTintColor = UIColor.blackColor()

        let tintColor = UIColor(red: 255 / 255.0, green: 238 / 255.0, blue: 136 / 255.0, alpha: 1)
        UITabBar.appearance().tintColor = tintColor
    }
}


// MARK: - Error Handling

extension AppDelegate {

    func listenForFatalCoreDataNotifications() {

        NSNotificationCenter.defaultCenter().addObserverForName(coreDataStack.MyManagedObjectContextSaveDidFailNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in

            let alert = UIAlertController(title: "Internal Error", message: "There is a fatal error in the app and it cannot continue.\n\n" + "Press OK to terminate the app", preferredStyle: .Alert)

            let action = UIAlertAction(title: "OK", style: .Default, handler: { (_) in
                let exception = NSException(name: NSInternalInconsistencyException, reason: "Fatal Core Data error", userInfo: nil)
                exception.raise()
            })

            alert.addAction(action)

            self.viewControllerForShowingAlert().presentViewController(alert, animated: true, completion: nil)
        }
    }

    func viewControllerForShowingAlert() -> UIViewController {
        let rootViewController  = self.window!.rootViewController!
        if let pressentViewController = rootViewController.presentedViewController {
            return pressentViewController
        } else {
            return rootViewController
        }
    }
}

