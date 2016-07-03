//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by kemchenj on 6/19/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

private let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .ShortStyle
    return formatter
}()


// MARK: - Class

class LocationDetailsViewController: UITableViewController, Hud {

    var coreDataStack: CoreDataStack! 

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?

    var categoryName = "No Category"
    var date = NSDate()

    var hudText: NSString = ""

    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                placemark = location.placemark
                coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            }
        }
    }

    var descriptionText = ""

}



// MARK: - View

extension LocationDetailsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let _ = locationToEdit {
            navigationController?.title = "Edit Location"
        }

        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName

        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)

        if let placemark = placemark {
            addressLabel.text = string(fromPlacemark: placemark)
        } else {
            addressLabel.text = "Place Not Found"
        }

        dateLabel.text = format(date)
    }


    private func string(fromPlacemark placemark: CLPlacemark) -> String {

        var text = ""

        if let s = placemark.subThoroughfare {
            text += s + " "
        }
        if let s = placemark.thoroughfare {
            text += s + " "
        }
        if let s = placemark.locality {
            text += s + " "
        }
        if let s = placemark.administrativeArea {
            text += "\n" + s + " "
        }
        if let s = placemark.postalCode {
            text += s + " "
        }
        if let s = placemark.country {
            text += s
        }

        return text
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "PickCategory" {
            let controller = segue.destinationViewController as! CategoryPickerViewController
            
            controller.selectedCategoryName = categoryName
        }
    }
}



// MARK: - Button Click

extension LocationDetailsViewController {

    @IBAction func done() {

        let location: Location
        if let temp = locationToEdit {
            hudText = "Updated"
            location = temp
        } else {
            hudText = "Tagged"
            location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: coreDataStack.managedObjectContext) as! Location
        }

        showHudInView(rootView: navigationController!.view, animated: true)

        afterDelay(1.5) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }

        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date

        if let placemark = placemark {
            location.placemark = placemark
        }

        do {
            try coreDataStack.managedObjectContext.save()
        } catch {
            coreDataStack.fatalCoreDataError(error)
        }

        afterDelay(0.6) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue) {

        let controller = segue.sourceViewController as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
}



// MARK: - Table View

extension LocationDetailsViewController {

}


// MARK: - Tool

private extension LocationDetailsViewController {
    
    func format(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
}


// MARK: - Image Picker

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true

        presentViewController(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {

        dismissViewControllerAnimated(true, completion: nil)
    }
}