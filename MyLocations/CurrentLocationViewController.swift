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
    
    var updatingLocation = false
    var lastLocationError: NSError?
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
        
        startLocationManager()
        updateLabels()
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
        
        print("Did Faild With Error: \(error)")
        
        if error.code == CLError.locationUnknown.rawValue {
            return
        }
        
        lastLocationError = error
        
        stopLocationManager()
        updateLabels()
    }
    
    private func startLocationManager() {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
        }
    }
    
    private func stopLocationManager() {
        
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last
        print("Did Update Locations \(newLocation)")
        
        if newLocation?.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        if newLocation?.horizontalAccuracy < 0 {
            return
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation?.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
            
            updateLabels()
            
            if newLocation?.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("***** We are done!")
                stopLocationManager()
            }
        }
    }
}



// MARK: - UIView

extension CurrentLocationViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLabels()
    }
    
     private func updateLabels() {
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
            
            let statusMessage: String
            if let error = lastLocationError {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services disabled"
            } else if updatingLocation{
                statusMessage = "Searching... ..."
            } else {
                statusMessage = "Tag 'Get My Location' To Start"
            }
            
            print(statusMessage)
            
            messageLabel.text = statusMessage
        }
    }
    
}









