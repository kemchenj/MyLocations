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

private let dateFormatter:DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .mediumStyle
    formatter.timeStyle = .shortStyle
    return formatter
}()


// MARK: - Class

class LocationDetailsViewController: UITableViewController, Hud {

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var categoryName = "No Category"

    var hudText: NSString = ""

    var managedObjectContext: NSManagedObjectContext!
}



// MARK: - View

extension LocationDetailsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        descriptionTextView.text = ""
        categoryLabel.text = categoryName

        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)

        if let placemark = placemark {
            addressLabel.text = string(fromPlacemark: placemark)
        } else {
            addressLabel.text = "Place Not Found"
        }

        dateLabel.text = format(date: Date())
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
}



// MARK: - Button Click

extension LocationDetailsViewController {

    @IBAction func done() {
        hudText = "Tagged"
        showHudInView(rootView: navigationController!.view, animated: true)

        afterDelay(seconds: 1.5) {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
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



// MARK: - Segue

extension LocationDetailsViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destinationViewController as! CategoryPickerViewController

            controller.selectedCategoryName = categoryName
        }
    }
}



// MARK: - Tool

private extension LocationDetailsViewController {

    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
}
