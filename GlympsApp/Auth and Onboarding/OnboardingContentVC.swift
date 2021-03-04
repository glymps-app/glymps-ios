//
//  OnboardingContentVC.swift
//  GlympsApp
//
//  Created by James B Morris on 9/5/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation
import Amplitude_iOS
import AppTrackingTransparency

// page for walkthrough controller for new Glymps users :)
class OnboardingContentVC: UIViewController, UNUserNotificationCenterDelegate, UIApplicationDelegate {
    
    @IBOutlet weak var backgroundImg: UIImageView! // page images
    
    @IBOutlet weak var titleLabel: UILabel! // page title
    
    @IBOutlet weak var contentLabel: UILabel! // page text
    
    @IBOutlet weak var pageControl: UIPageControl! // dot indicators
    
    @IBOutlet weak var enableNotificationsBtn: UIButton! // button to enable notifications
    
    @IBOutlet weak var enableLocationServicesBtn: UIButton! // button to enable location
    
    @IBOutlet weak var improveMyExperienceBtn: UIButton! // button to enable tracking
    
    
    @IBOutlet weak var nextBtn: UIButton! // button to next page
    
    var index = 0 // pageIndex
    var imageForPage: UIImage?
    var content = ""
    var contentTitle = ""
    
    let manager = CLLocationManager()
    
    var presenter: LoginVC?

    // setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Index: \(index)")

        titleLabel.text = contentTitle
        contentLabel.text = content
        backgroundImg.image = imageForPage
        backgroundImg.contentMode = .scaleAspectFit
        
        if index == 4 {
            enableNotificationsBtn.isEnabled = true
            enableNotificationsBtn.isHidden = false
            enableNotificationsBtn.layer.zPosition = 5
            enableLocationServicesBtn.layer.zPosition = 1
            enableLocationServicesBtn.isEnabled = false
            enableLocationServicesBtn.isHidden = true
            improveMyExperienceBtn.layer.zPosition = 0
            improveMyExperienceBtn.isEnabled = false
            improveMyExperienceBtn.isHidden = true
            
            nextBtn.isEnabled = false
            nextBtn.backgroundColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
            nextBtn.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        }
        if index == 5 {
            enableNotificationsBtn.isEnabled = false
            enableNotificationsBtn.isHidden = true
            enableNotificationsBtn.layer.zPosition = 1
            improveMyExperienceBtn.layer.zPosition = 0
            improveMyExperienceBtn.isEnabled = false
            improveMyExperienceBtn.isHidden = true
            enableLocationServicesBtn.layer.zPosition = 5
            enableLocationServicesBtn.isEnabled = true
            enableLocationServicesBtn.isHidden = false
            
            nextBtn.isEnabled = false
            nextBtn.backgroundColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
            nextBtn.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        }
        if index == 6 {
            enableNotificationsBtn.isEnabled = false
            enableNotificationsBtn.isHidden = true
            enableNotificationsBtn.layer.zPosition = 1
            enableLocationServicesBtn.layer.zPosition = 0
            improveMyExperienceBtn.layer.zPosition = 5
            enableLocationServicesBtn.isEnabled = false
            enableLocationServicesBtn.isHidden = true
            improveMyExperienceBtn.isEnabled = true
            improveMyExperienceBtn.isHidden = false
            
            nextBtn.isEnabled = false
            nextBtn.backgroundColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
            nextBtn.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        }
        
        pageControl.currentPage = index
        pageControl.pageIndicatorTintColor = #colorLiteral(red: 0.6140708327, green: 0.7837085724, blue: 0.8509241939, alpha: 1)
        pageControl.currentPageIndicatorTintColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
        // switch below checks if button should be "next" or "done" based on page index. If last page, done button appears, otherwise arrow appears
        switch index {
        case 0...6:
            nextBtn.setTitle("Next", for: .normal)
        case 7:
            nextBtn.setTitle("Go to signup", for: .normal)
        default:
            break
        }
    }
    
    @IBAction func nextBtnWasPressed(_ sender: Any) {
        // checks if User has navigated walkthrough before, also goes to next page
        switch index {
        case 0...6:
            let pageVC = parent as! OnboardingVC
            pageVC.forward(index: index)
        case 7:
            self.logAmplitudeIntroEndEvent()
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "hasViewedWalkthrough")
            dismiss(animated: true, completion: nil)
            
            let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
            let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpVC")
            self.presenter?.navigationController?.pushViewController(signUpVC, animated: true)
            
        default:
            print("")
        }
    }
    
    // authorize and enable push notifications (pretty nice to have) for Glymps iOS
    @IBAction func enableNotificationsBtnWasPressed(_ sender: Any) {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if error != nil {
                // Error Occurred
                print("Notification Authorization Error: \(error!.localizedDescription)")
            } else {
                // Notification Authorization Success!
                print("Notification Permissions Granted: \(granted)")
                self.logAmplitudeNotificationsEnabledEvent()
                UNUserNotificationCenter.current().delegate = self

                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    
                    self.enableNotificationsBtn.isHidden = true
                    self.enableNotificationsBtn.isEnabled = false
                    
                    self.nextBtn.isEnabled = true
                    self.nextBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
                    self.nextBtn.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
                }
            }
        }
    }
    
    // setup location manager and request authorization
    func configureLocationManager() {
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.pausesLocationUpdatesAutomatically = true
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
            self.logAmplitudeLocationEnabledEvent()
        }
        
        DispatchQueue.main.async {
            self.enableLocationServicesBtn.isHidden = true
            self.enableLocationServicesBtn.isEnabled = false
            
            self.nextBtn.isEnabled = true
            self.nextBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
            self.nextBtn.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        }
        
    }
    
    // setup AppTrackingTransparency manager
    func configureATTManager() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { (authorizationStatus) in
                var trackingPermissionsEventProperties: [AnyHashable : Any] = [:]
                switch authorizationStatus {
                case .notDetermined:
                    trackingPermissionsEventProperties.updateValue("Not Determined", forKey: "Status")
                case .restricted:
                    trackingPermissionsEventProperties.updateValue("Restricted", forKey: "Status")
                case .denied:
                    trackingPermissionsEventProperties.updateValue("Denied", forKey: "Status")
                case .authorized:
                    trackingPermissionsEventProperties.updateValue("Authorized", forKey: "Status")
                default:
                    trackingPermissionsEventProperties.updateValue("Not Determined", forKey: "Status")
                }
            }
        } else {
            print("ATT Manager not displayed, since user is not on iOS 14+.")
        }
        
        DispatchQueue.main.async {
            self.improveMyExperienceBtn.isHidden = true
            self.improveMyExperienceBtn.isEnabled = false
            
            self.nextBtn.isEnabled = true
            self.nextBtn.backgroundColor = #colorLiteral(red: 0.08732911403, green: 0.7221731267, blue: 1, alpha: 1)
            self.nextBtn.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        }
        
    }
    
    func logAmplitudeLocationEnabledEvent() {
        Amplitude.instance().logEvent("Location Enabled")
    }
    
    func logAmplitudeNotificationsEnabledEvent() {
        Amplitude.instance().logEvent("Notifications Enabled")
    }
    
    func logAmplitudeTrackingEnabledEvent(status: [AnyHashable : Any]) {
        Amplitude.instance()?.logEvent("Tracking Permissions", withEventProperties: status)
    }
    
    func logAmplitudeIntroEndEvent() {
        Amplitude.instance().logEvent("Intro End")
    }
    
    // authorize and enable location services (pretty necessary) for Glymps iOS
    @IBAction func enableLocationServicesBtnWasPressed(_ sender: Any) {
        
        configureLocationManager()
    }
    
    @IBAction func improveMyExperienceBtnWasPressed(_ sender: Any) {
        
        configureATTManager()
    }
    

}

// observe status of location authorization
extension OnboardingContentVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if (status == .authorizedAlways) || (status == .authorizedWhenInUse) {

            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location services authorization error: \(error.localizedDescription)")
    }
    
    // update current user's current location on Firebase via GeoFire when changed
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let updatedLocation: CLLocation = locations.first!
        let newCoordinate: CLLocationCoordinate2D = updatedLocation.coordinate
        let userDefaults: UserDefaults = UserDefaults.standard
        userDefaults.setValue("\(newCoordinate.latitude)", forKey: "current_location_latitude")
        userDefaults.setValue("\(newCoordinate.longitude)", forKey: "current_location_longitude")
        userDefaults.synchronize()
    }
    
}
