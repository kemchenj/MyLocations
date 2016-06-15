//
//  FirstViewController.swift
//  MyLocations
//
//  Created by kemchenj on 5/24/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit
import CoreLocation



// MARK: - Class

class CurrentLocationViewController: UIViewController {
    
    @IBOutlet weak var messageLabel : UILabel!
    @IBOutlet weak var addressLabel : UILabel!
    @IBOutlet weak var latitudeLabel : UILabel!
    @IBOutlet weak var longtitudeLabel : UILabel!
    
    @IBOutlet weak var tagButton : UIButton!
    @IBOutlet weak var getButton : UIButton!
    
    let locationManager = CLLocationManager()
    var location : CLLocation?
    
}



// MARK: - Button Action

private extension CurrentLocationViewController {
    
    @IBAction func getLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert .addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}



// MARK: - Location Manager Delegate

extension CurrentLocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("Did Faild With Error \(error)")
    }
    
    @objc(locationManager:didUpdateLocations:) func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let newLocation = locations.last
        
        location = newLocation
        updateLabels()
        
        print("Did Update Locations \(newLocation)")
    }
    
}



// MARK: - UIView

extension CurrentLocationViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLabels()
    }
    
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f",location.coordinate.latitude)
            longtitudeLabel.text = String(format: "%.8f",location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
        } else {
            addressLabel.text = ""
            latitudeLabel.text = ""
            longtitudeLabel.text = ""
            tagButton.isHidden = true
            messageLabel.text = "Tap 'Get My Location' Button To Start"
        }
    }
    
}
