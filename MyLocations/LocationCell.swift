//
//  LocationCell.swift
//  MyLocations
//
//  Created by kemchenj on 7/2/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = UIColor.black
        
        descriptionLabel.textColor = UIColor.white
        descriptionLabel.highlightedTextColor = descriptionLabel.textColor

        addressLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        addressLabel.highlightedTextColor = addressLabel.textColor

        photoImageView.layer.cornerRadius = photoImageView.bounds.size.width / 2
        photoImageView.clipsToBounds = true

        separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
    }

    func configure(forLocation location: Location) {
        descriptionLabel.text = location.locationDescription

        if let placemark = location.placemark {
            var text = ""

            text.add(placemark.subThoroughfare)
            text.add(placemark.thoroughfare, withSeperator: " ")
            text.add(placemark.locality, withSeperator: ", ")

            addressLabel.text = text
        } else {
            addressLabel.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude, location.longitude)
        }

        photoImageView.image = imageForLocation(location)
    }

    func imageForLocation(_ location: Location) -> UIImage {
        if location.hasPhoto, let image = location.photoImage {
            return image.resizedImage(with: CGSize(width: 52, height: 52))
        }
        return UIImage(named: "No Photo")!
    }
    
}
