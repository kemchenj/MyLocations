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
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longtitudeLabel: UILabel!
    
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    
    var updatingLocation = false
    var lastLocationError: NSError?
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: NSError?
    var timer: Timer?
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
        
        if updatingLocation {
            stopLocationManager()
        }else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        
        updateLabels()
        configureGetButton()
    }
    
    private func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert .addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", for: [])
        } else {
            getButton.setTitle("Get My Location", for: [])
        }
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
        configureGetButton()
    }
    
    private func startLocationManager() {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            timer = Timer.scheduledTimer(timeInterval: 60,
                                         target: self,
                                         selector: #selector(self.didTimeOut),
                                         userInfo: nil,
                                         repeats: false)
        }
    }
    
    
    private func stopLocationManager() {
        
        if updatingLocation {
            if let timer = timer {
                timer.invalidate()
            }
            
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }
    
    func didTimeOut() {
        
        print("*** Time out")
        
        if location == nil {
            stopLocationManager()
            
            lastLocationError = NSError(domain: "MyLocationsErrorDomain",
                                        code: 1,
                                        userInfo: nil)
            
            updateLabels()
            configureGetButton()
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
        
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location {
            distance = (newLocation?.distance(from: location))!
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation?.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
            updateLabels()
            
            if newLocation?.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("***** We are done!")
                stopLocationManager()
                configureGetButton()
                
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }
            
            if !performingReverseGeocoding {
                print("Going to geocode")
                
                performingReverseGeocoding = true
                
                geocoder.reverseGeocodeLocation(newLocation!) { placemarks, error in
                    print("*** Found placements: \(placemarks)")
                    if let code = error?.code {
                        print("error: \(CLError(rawValue: code))")
                    }
                    
                    self.lastGeocodingError = error
                    if error == nil, let p = placemarks where !p.isEmpty{
                        self.placemark = p.last
                    } else {
                        self.placemark = nil
                    }
                    
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                }
            }
        } else if distance < 1.0 {
            let timeInterval = newLocation?.timestamp.timeIntervalSince(location!.timestamp)
            
            if timeInterval > 10 {
                print("*** Force done!")
                stopLocationManager()
                updateLabels()
                configureGetButton()
            }
        }
    }
}



// MARK: - UIView

extension CurrentLocationViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLabels()
        configureGetButton()
    }
    
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f",location.coordinate.latitude)
            longtitudeLabel.text = String(format: "%.8f",location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
            
            if let placemark = placemark {
                addressLabel.text = string(fromPlacemark: placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching For Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
            
        } else {
            addressLabel.text = ""
            latitudeLabel.text = ""
            longtitudeLabel.text = ""
            tagButton.isHidden = true
            messageLabel.text = "Tap 'Get My Location' Button To Start"
            
            let statusMessage: String
            if let error = lastLocationError {
                print(error.code)
                print(CLError.denied.rawValue)
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
    
    func string(fromPlacemark placemark:CLPlacemark) -> String {
        
        var line1 = ""
        
        if let s = placemark.subThoroughfare {
            line1 += s + " "
        }
        if let s = placemark.thoroughfare {
            line1 += s + " "
        }
        
        var line2 = ""
        
        if let s = placemark.locality {
            line2 += s + " "
        }
        if let s = placemark.administrativeArea {
            line2 += s + " "
        }
        if let s = placemark.postalCode {
            line2 += s
        }
        
        return line1 + "\n" + line2
    }
    
}









