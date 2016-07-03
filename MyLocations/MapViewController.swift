//
//  MapViewController.swift
//  MyLocations
//
//  Created by kemchenj on 7/3/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    var coreDataStack: CoreDataStack = CoreDataStack.sharedInstance {
        didSet {
            if coreDataStack.managedObjectContext.hasChanges {
                updateLocations()
            }
        }
    }

    @IBOutlet weak var mapView: MKMapView!

    var locations = [Location]()
}


// MARK: - View

extension MapViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocations()
        mapView.delegate = self

        if !locations.isEmpty {
            showLocations()
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditLocation" {
            let navigationController = segue.destinationViewController as! UINavigationController

            let controller = navigationController.topViewController as! LocationDetailsViewController

            controller.coreDataStack = coreDataStack

            let button = sender as! UIButton
            let location = locations[button.tag]

            controller.locationToEdit = location
        }
    }
}


// MARK: - IBAction

extension MapViewController {

    @IBAction func showUser() {
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(region, animated: true)
    }

    @IBAction func showLocations() {
        let region = regionForAnnotations(locations)
        mapView.setRegion(region, animated: true)
    }
}


// MARK: - MapView Delegate

extension MapViewController: MKMapViewDelegate {

    func regionForAnnotations(annotations: [MKAnnotation]) -> MKCoordinateRegion{

        var region: MKCoordinateRegion

        switch annotations.count {
        case 0:
            region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)

        case 1:
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)

        default:
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)

            for annotation in annotations {
                topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
                topLeftCoord.longitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
                bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude)
                bottomRightCoord.longitude = max(bottomRightCoord.longitude, annotation.coordinate.longitude)
            }

            let center = CLLocationCoordinate2D(latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2, longitude: topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)

            let extraSpace = 1.1
            let span = MKCoordinateSpan(latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace,
                                        longitudeDelta: abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)

            region = MKCoordinateRegion(center: center, span: span)

        }

        return mapView.regionThatFits(region)
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {

        // 1. MKAnnotation是个协议, 用来指代类型的时候是指泛型约束
        //    用is可以用来验证annotation是不是一个Location类型
        guard annotation is Location else {
            return nil
        }

        // 2. 类似于table view的重用机制, 有则重用, 无则新建
        //    这里用的是Pin Annotation View去约束, 也可以用自己创建一个Annotation View的子类
        let identifier = "Location"

        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as! MKPinAnnotationView?
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)

            // 3. 这里一系列的Property设置都是在调整外观
            annotationView?.enabled = true
            annotationView?.canShowCallout = true
            annotationView?.animatesDrop = false
            annotationView?.pinTintColor = UIColor(red: 0.32,
                                                   green: 0.82,
                                                   blue: 0.4,
                                                   alpha: 1)

            // 4. 给Annotation View创建按钮, 类似于cell的detail
            let rightButton = UIButton(type: .DetailDisclosure)
            rightButton.addTarget(self,
                                  action: #selector(self.showLocationDetails(_:)),
                                  forControlEvents: .TouchUpInside)
            annotationView?.rightCalloutAccessoryView = rightButton
        } else {
            annotationView?.annotation = annotation
        }

        let button = annotationView?.rightCalloutAccessoryView as! UIButton
        if let index = locations.indexOf(annotation as! Location) {
            button.tag = index
        }

        return annotationView
    }

    func showLocationDetails(sender: UIButton) {

        performSegueWithIdentifier("EditLocation", sender: sender)
    }
}


// MARK: - Data

extension MapViewController {

    func updateLocations() {

        mapView.removeAnnotations(locations)

        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: coreDataStack.managedObjectContext)

        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity

        locations = try! coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest) as! [Location]

        mapView.addAnnotations(locations)
        print(locations)
    }
}

// MARK: - NavigationBar Delegate

extension MapViewController: UINavigationBarDelegate {

    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}
