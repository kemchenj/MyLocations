//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by kemchenj on 6/19/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit
import CoreLocation


private let dateFormatter:DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .mediumStyle
    formatter.timeStyle = .shortStyle
    return formatter
}()


// MARK: - Class

class LocationDetailsViewController: UITableViewController {
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var categoryName = "No Category"
    
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
        
        let gestureRecognizer = UITapGestureRecognizer(target: self,
                                                       action: #selector(self.hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    
    func hideKeyboard(gestureRecognizer: UITapGestureRecognizer) {
    
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        if indexPath != nil && indexPath!.section == 0
                            && indexPath!.row == 0 {
            return
        }
        
        descriptionTextView.resignFirstResponder()
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
        let hudView = HudView.hudInView(view: navigationController!.view, animated: true)
        hudView.text = "Tagged"
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
}



// MARK: - Table View

extension LocationDetailsViewController {
    
    // MARK: - Delegate
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = indexPath
        
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
    }
    
}



// MARK: - Segue

extension LocationDetailsViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destinationViewController as! CategoryPickerViewController
            
            controller.selectedCategoryName = categoryName
        }
    }
    
    // MARK: Unwind Segue
    
    @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue) {
        
        let controller = segue.sourceViewController as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
}



// MARK: - Tool

private extension LocationDetailsViewController {
    
    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
}
