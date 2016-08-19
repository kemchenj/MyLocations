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

fileprivate let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
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
    var date = Date()

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
        NotificationCenter.default.removeObserver(observer)
    }

}



// MARK: - Core Data

extension LocationDetailsViewController {

    func listenForBackgroundNotification() {
        observer =  NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground, object: nil, queue: OperationQueue.main) { [weak self] _ in  // 告诉闭包self会被捕获, 但是是以弱引用的形式被捕获

            if let strongSelf = self { // self在这里会以一个optional的形式存在, 所以必须用iflet拆包
                if strongSelf.presentedViewController != nil {
                    strongSelf.dismiss(animated: false, completion: nil)
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

        tableView.backgroundColor = UIColor.black
        tableView.separatorColor = UIColor(white: 1, alpha: 0.2)
        tableView.indicatorStyle = .white

        descriptionTextView.textColor = UIColor.white
        descriptionTextView.backgroundColor = UIColor.black

        addPhotoLabel.textColor = UIColor.white
        addPhotoLabel.backgroundColor = addPhotoLabel.textColor

        addressLabel.textColor = UIColor.white
        addressLabel.highlightedTextColor = addressLabel.textColor
    }


     func string(fromPlacemark placemark: CLPlacemark) -> String {

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController

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
            location = NSEntityDescription.insertNewObject(forEntityName: "Location", into: coreDataStack.managedObjectContext) as! Location
            // 新建location对象的时候, photoID会被初始化为0, 所以需要重新
            location.photoID = nil
        }

        showHudInView(rootView: navigationController!.view, animated: true)

        afterDelay(1.5) {
            self.dismiss(animated: true, completion: nil)
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
                location.photoID = Location.nextPhotoID() as NSNumber
            }

            if let data = UIImageJPEGRepresentation(image, 0.5) {
                do {
                    try data.write(to: URL(fileURLWithPath: location.photoPath), options: .atomic)
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
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {

        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
}



// MARK: - Table View

extension LocationDetailsViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch ((indexPath as NSIndexPath).section, (indexPath as NSIndexPath).row) {
        case (0,0):
            descriptionTextView.becomeFirstResponder()
        case (1,0):
            tableView.deselectRow(at: indexPath, animated: true)
            pickPhoto()
        default:
            print("")
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        switch ((indexPath as NSIndexPath).section, (indexPath as NSIndexPath).row) {
        case (0,0):
            return 88

        case (1,_):
            return imageView.isHidden ? 44 : 260

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

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        cell.backgroundColor = UIColor.black

        if let textLabel = cell.textLabel {
            textLabel.textColor = UIColor.white
            textLabel.highlightedTextColor = textLabel.textColor
        }

        if let detailLabel = cell.detailTextLabel {
            detailLabel.textColor = UIColor(white: 1, alpha: 0.4)
            detailLabel.highlightedTextColor = detailLabel.textColor
        }

        let selectionView = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = UIColor(white: 1, alpha: 0.2)
        cell.selectedBackgroundView = selectionView

        if (indexPath as NSIndexPath).row == 2 {
            let addressLabel = cell.viewWithTag(100) as! UILabel
            addressLabel.textColor = UIColor(white: 1, alpha: 0.4)
            addressLabel.highlightedTextColor = addressLabel.textColor

            let titleLabel = cell.viewWithTag(101) as! UILabel
            titleLabel.textColor = UIColor.white
            titleLabel.highlightedTextColor = titleLabel.textColor
        }
    }

}


// MARK: - Image Picker

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func showImage(_ image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
        addPhotoLabel.isHidden = true
    }

    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }

    func showPhotoMenu() {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) {
            _ in
            self.takePhotoWithCamera()
        }
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .default) {
            _ in
            self.choosePhotoFromLibrary()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(takePhotoAction)
        alertController.addAction(chooseFromLibraryAction)

        present(alertController, animated: true, completion: nil)
    }

    func takePhotoWithCamera() {
        let imagePicker = MyImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.view.tintColor = view.tintColor

        present(imagePicker, animated: true, completion: nil)
    }

    func choosePhotoFromLibrary() {
        let imagePicker = MyImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.view.tintColor = view.tintColor

        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        image = info[UIImagePickerControllerEditedImage] as? UIImage

        if let image = image {
            showImage(image)
        }
        
        tableView.reloadData()
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - Tool

private extension LocationDetailsViewController {
    
    func format(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
}
