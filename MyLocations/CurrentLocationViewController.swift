//
//  FirstViewController.swift
//  MyLocations
//
//  Created by kemchenj on 5/24/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import QuartzCore
import AudioToolbox


// MARK: - Class

class CurrentLocationViewController: UIViewController {

    var coreDataStack: CoreDataStack!
    var soundID: SystemSoundID = 0

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longtitudeLabel: UILabel!

    @IBOutlet weak var latitudeTextLabel: UILabel!
    @IBOutlet weak var longitudeTextLabel: UILabel!
    
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!

    @IBOutlet weak var containerView: UIView!
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    
    var updatingLocation = false
    var lastLocationError: NSError?
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: NSError?
    var timer: NSTimer?

    var logoVisible = false
    lazy var logoButton: UIButton! = {
        let button = UIButton(type: .Custom)
        button.setBackgroundImage(UIImage(named: "Logo"), forState: [])
        button.sizeToFit()
        button.addTarget(self, action: Selector("getLocation"), forControlEvents: .TouchUpInside)
        button.center.x = CGRectGetMidX(self.view.bounds)
        button.center.y = 220

        return button
    }()
}



// MARK: - Button Action

private extension CurrentLocationViewController {
    
    @IBAction func getLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .Denied || authStatus == .Restricted {
            showLocationServicesDeniedAlert()
            return
        }

        if logoVisible {
            hideLogoView()
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

    private func showLogoView() {
        if !logoVisible {
            logoVisible = true
            containerView.hidden = true
            view.addSubview(logoButton)
        }
    }

    private func hideLogoView() {
        if !logoVisible { return }

        logoVisible = false
        containerView.hidden = false

        containerView.center.x = view.bounds.size.width * 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2

        let centerX = CGRectGetMidX(view.bounds)

        let paneMover = CABasicAnimation(keyPath: "position")
        paneMover.removedOnCompletion = false
        paneMover.fillMode = kCAFillModeForwards
        paneMover.duration = 0.6
        paneMover.fromValue = NSValue(CGPoint: containerView.center)
        paneMover.toValue = NSValue(CGPoint: CGPoint(x: centerX, y: containerView.center.y))
        paneMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        paneMover.delegate = self
        containerView.layer.addAnimation(paneMover, forKey: "panelMover")

        let logoMover = CABasicAnimation(keyPath: "position")
        logoMover.removedOnCompletion = false
        logoMover.fillMode = kCAFillModeForwards
        logoMover.duration = 0.5
        logoMover.fromValue = NSValue(CGPoint: logoButton.center)
        logoMover.toValue = NSValue(CGPoint: CGPoint(x: -centerX, y: logoButton.center.y))
        logoMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        logoButton.layer.addAnimation(logoMover, forKey: "logoMover")

        let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
        logoRotator.removedOnCompletion = false
        logoRotator.fillMode = kCAFillModeForwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0.0
        logoRotator.toValue = -2 * M_PI
        logoRotator.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        logoButton.layer.addAnimation(logoRotator, forKey: "logoRotator")
    }

    override internal func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        containerView.layer.removeAllAnimations()
        containerView.center.x = view.bounds.size.width / 2 - 25
        containerView.center.y = 40 + containerView.bounds.size.height / 2

        logoButton.layer.removeAllAnimations()
        logoButton.removeFromSuperview()
    }
    
    private func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alert .addAction(okAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func configureGetButton() {
        let spinnerTag = 1000

        if updatingLocation {
            getButton.setTitle("Stop", forState: [])

            if view.viewWithTag(spinnerTag) == nil {
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
                spinner.center = messageLabel.center
                spinner.center.y += (spinner.bounds.size.height / 2 + 15)
                spinner.startAnimating()
                spinner.tag = spinnerTag
                containerView.addSubview(spinner)
            }
        } else {
            getButton.setTitle("Get My Location", forState: [])

            if let spinner = view.viewWithTag(spinnerTag) {
                spinner.removeFromSuperview()
            }
        }
    }
}



// MARK: - Location Manager Delegate

extension CurrentLocationViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("Did Faild With Error: \(error)")
        
        if error.code == CLError.LocationUnknown.rawValue {
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

            timer = NSTimer.scheduledTimerWithTimeInterval(60,
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
            distance = (newLocation?.distanceFromLocation(location))!
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
                        if self.placemark == nil {
                            print("First Time")
                            self.playSoundEffect()
                        }
                        self.placemark = p.last
                    } else {
                        self.placemark = nil
                    }
                    
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                }
            }
        } else if distance < 1.0 {
            let timeInterval = newLocation?.timestamp.timeIntervalSinceDate(location!.timestamp)

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
        loadSoundEffect("Sound.caf")
    }
    
    private func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f",location.coordinate.latitude)
            longtitudeLabel.text = String(format: "%.8f",location.coordinate.longitude)
            tagButton.hidden = false
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

            latitudeTextLabel.hidden = false
            longitudeTextLabel.hidden = false
        } else {
            addressLabel.text = ""
            latitudeLabel.text = ""
            longtitudeLabel.text = ""
            tagButton.hidden = true
            messageLabel.text = "Tag 'Get My Location' To Start"

            let statusMessage: String
            if let error = lastLocationError {
                print(error.code)
                print(CLError.Denied.rawValue)
                if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services disabled"
            } else if updatingLocation{
                statusMessage = "Searching... ..."
            } else {
                statusMessage = ""
                showLogoView()
            }
            
            print(statusMessage)
            
            messageLabel.text = statusMessage
            latitudeTextLabel.hidden = true
            longitudeTextLabel.hidden = true
        }
    }
    
    private func string(fromPlacemark placemark:CLPlacemark) -> String {
        
//        var line1 = ""
//        
//        if let s = placemark.subThoroughfare {
//            line1 += s + " "
//        }
//        if let s = placemark.thoroughfare {
//            line1 += s + " "
//        }
//        
//        var line2 = ""
//        
//        if let s = placemark.locality {
//            line2 += s + " "
//        }
//        if let s = placemark.administrativeArea {
//            line2 += s + " "
//        }
//        if let s = placemark.postalCode {
//            line2 += s
//        }
//        return line1 + "\n" + line2

        var line = ""
        line.add(placemark.subThoroughfare)
        line.add(placemark.thoroughfare, withSeperator: " ")
        line.add(placemark.locality, withSeperator: ", ")
        line.add(placemark.administrativeArea, withSeperator: ", ")
        line.add(placemark.postalCode, withSeperator: " ")
        line.add(placemark.country, withSeperator: ", ")

        return line
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "TagLocation" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController

            if let coordinate = location?.coordinate {
                controller.coordinate = coordinate
            }

            controller.placemark = placemark

            print(coreDataStack)
            controller.coreDataStack = coreDataStack
            print(controller)
        }
    }
    
}



// MARK: - Audio

extension CurrentLocationViewController {

    func loadSoundEffect(name: String) {
        if let path = NSBundle.mainBundle().pathForResource(name, ofType: nil) {
            let fileURL = NSURL.fileURLWithPath(path)
            let error = AudioServicesCreateSystemSoundID(fileURL, &soundID)
            if error != kAudioServicesNoError {
                print("Error code \(error) loading sound at path: \(path)")
            }
        }
    }

    func uploadSoundEffect() {
        AudioServicesDisposeSystemSoundID(soundID)
        soundID = 0
    }

    func playSoundEffect() {
        AudioServicesPlaySystemSound(soundID)
    }
}








