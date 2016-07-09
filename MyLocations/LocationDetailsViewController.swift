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

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!

    var image: UIImage?

    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?

    var categoryName = "No Category"
    var date = NSDate()

    var hudText: NSString = ""
    var descriptionText = ""

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

    var observer: AnyObject!

    deinit {
        print("*** deinit \(self)")
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }

}



// MARK: - Core Data

extension LocationDetailsViewController {

    func listenForBackgroundNotification() {
        observer =  NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] _ in  // 告诉闭包self会被捕获, 但是是以指针的形式被捕获

            if let strongSelf = self { // self在这里会以一个optional的形式存在, 所以必须用ifsa拆包
                if strongSelf.presentedViewController != nil {
                    strongSelf.dismissViewControllerAnimated(false, completion: nil)
                }

                strongSelf.descriptionTextView.resignFirstResponder()
            }
        }
    }
}



// MARK: - View

extension LocationDetailsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let location = locationToEdit {
            title = "Edit Location"
            if location.hasPhoto {
                if let image = location.photoImage {
                    showImage(image)
                }
            }
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

        listenForBackgroundNotification()
    }


    private func string(fromPlacemark placemark: CLPlacemark) -> String {

//        var text = ""
//
//        if let s = placemark.subThoroughfare {
//            text += s + " "
//        }
//        if let s = placemark.thoroughfare {
//            text += s + " "
//        }
//        if let s = placemark.locality {
//            text += s + " "
//        }
//        if let s = placemark.administrativeArea {
//            text += "\n" + s + " "
//        }
//        if let s = placemark.postalCode {
//            text += s + " "
//        }
//        if let s = placemark.country {
//            text += s
//        }

        var line1 = ""
        line1.add(placemark.subThoroughfare)
        line1.add(placemark.thoroughfare, withSeperator: " ")

        var line2 = ""
        line2.add(placemark.locality)
        line2.add(placemark.administrativeArea, withSeperator: " ")
        line2.add(placemark.postalCode, withSeperator: " ")

        line1.add(line2, withSeperator: "\n")

        return line1
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
            // 新建location对象的时候, photoID会被初始化为0, 所以需要重新
            location.photoID = nil
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

        if let image = image {
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID()
            }

            if let data = UIImageJPEGRepresentation(image, 0.5) {
                do {
                    try data.writeToFile(location.photoPath, options: .DataWritingAtomic)
                } catch {
                    print("Error writing file: \(error)")
                }
            }
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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        switch (indexPath.section, indexPath.row) {
        case (0,0):
            descriptionTextView.becomeFirstResponder()
        case (1,0):
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            pickPhoto()
        default:
            print("")
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        switch (indexPath.section, indexPath.row) {
        case (0,0):
            return 88

        case (1,_):
            return imageView.hidden ? 44 : 260

        case (2,2):
            addressLabel.frame.size = CGSize(width: view.bounds.width - 115,
                                             height: 10000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.width - addressLabel.frame.size.width - 15
            return addressLabel.frame.size.height + 20

        default:
            return 44
        }
    }

}


// MARK: - Image Picker

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func showImage(image: UIImage) {
        imageView.image = image
        imageView.hidden = false
        imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
        addPhotoLabel.hidden = true
    }

    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }

    func showPhotoMenu() {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default) {
            _ in
            self.takePhotoWithCamera()
        }
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .Default) {
            _ in
            self.choosePhotoFromLibrary()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(takePhotoAction)
        alertController.addAction(chooseFromLibraryAction)

        presentViewController(alertController, animated: true, completion: nil)
    }

    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true

        presentViewController(imagePicker, animated: true, completion: nil)
    }

    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true

        presentViewController(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        image = info[UIImagePickerControllerEditedImage] as? UIImage

        if let image = image {
            showImage(image)
        }
        
        tableView.reloadData()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}


// MARK: - Tool

private extension LocationDetailsViewController {
    
    func format(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
}