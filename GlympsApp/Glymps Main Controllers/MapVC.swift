//
//  MapVC.swift
//  GlympsApp
//
//  Created by James B Morris on 8/25/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics
import Mapbox
import CoreLocation
import GeoFire

// heat map so current user can find concentrations of nearby users
class MapVC: UIViewController, MGLMapViewDelegate {
    
    @IBOutlet weak var navBar: UIView!
    
    @IBOutlet weak var mapView: MGLMapView!
    
    @IBOutlet weak var dismissBtn: UIButton!
    
    // setup GeoFire
    var userLat = ""
    var userLong = ""
    var geoFire: GeoFire!
    var geoFireRef: DatabaseReference!
    let manager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLocationManager()

        navBar.setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: 10), color: .init(white: 0, alpha: 0.3))
        
        mapView.delegate = self
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true, completionHandler: nil)
    }
    
    // setup location manager
    func configureLocationManager() {
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.pausesLocationUpdatesAutomatically = true
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
        }
        
        self.geoFireRef = Database.database().reference().child("Geolocs")
        self.geoFire = GeoFire(firebaseRef: self.geoFireRef)
    }
    
    // layout heatmap
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        
        // Parse GeoJSON data. This example uses all M1.0+ earthquakes from 12/22/15 to 1/21/16 as logged by USGS' Earthquake hazards program.
        guard let url = URL(string: "https://www.mapbox.com/mapbox-gl-js/assets/earthquakes.geojson") else { return }
        let source = MGLShapeSource(identifier: "earthquakes", url: url, options: nil)
        style.addSource(source)
        
        // Create a heatmap layer.
        let heatmapLayer = MGLHeatmapStyleLayer(identifier: "earthquakes", source: source)
        
        // Adjust the color of the heatmap based on the point density.
        let colorDictionary: [NSNumber: UIColor] = [
            0.0: .clear,
            0.01: .white,
            0.15: UIColor(red: 0.19, green: 0.30, blue: 0.80, alpha: 1.0),
            0.5: UIColor(red: 0.73, green: 0.23, blue: 0.25, alpha: 1.0),
            1: .yellow
        ]
        heatmapLayer.heatmapColor = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($heatmapDensity, 'linear', nil, %@)", colorDictionary)
        
        // Heatmap weight measures how much a single data point impacts the layer's appearance.
        heatmapLayer.heatmapWeight = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:(mag, 'linear', nil, %@)",
                                                  [0: 0,
                                                   6: 1])
        
        // Heatmap intensity multiplies the heatmap weight based on zoom level.
        heatmapLayer.heatmapIntensity = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                                     [0: 1,
                                                      9: 3])
        heatmapLayer.heatmapRadius = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                                  [0: 4,
                                                   9: 30])
        
        // The heatmap layer should be visible up to zoom level 9.
        heatmapLayer.heatmapOpacity = NSExpression(format: "mgl_step:from:stops:($zoomLevel, 0.75, %@)", [0: 0.75, 9: 0])
        style.addLayer(heatmapLayer)
        
        // Add a circle layer to represent the earthquakes at higher zoom levels.
        let circleLayer = MGLCircleStyleLayer(identifier: "circle-layer", source: source)
        
        let magnitudeDictionary: [NSNumber: UIColor] = [
            0: .white,
            0.5: .yellow,
            2.5: UIColor(red: 0.73, green: 0.23, blue: 0.25, alpha: 1.0),
            5: UIColor(red: 0.19, green: 0.30, blue: 0.80, alpha: 1.0)
        ]
        circleLayer.circleColor = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:(mag, 'linear', nil, %@)", magnitudeDictionary)
        
        // The heatmap layer will have an opacity of 0.75 up to zoom level 9, when the opacity becomes 0.
        circleLayer.circleOpacity = NSExpression(format: "mgl_step:from:stops:($zoomLevel, 0, %@)", [0: 0, 9: 0.75])
        circleLayer.circleRadius = NSExpression(forConstantValue: 20)
        style.addLayer(circleLayer)
        
    }
    
    // go back to "card deck"
    @IBAction func dismissBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

// check on authorization status for location manager
extension MapVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if (status == .authorizedAlways) || (status == .authorizedWhenInUse) {
            
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location services authorization error: \(error.localizedDescription)")
    }
    // update current location of current user whenever changed, on Firebase via GeoFire
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let updatedLocation: CLLocation = locations.first!
        let newCoordinate: CLLocationCoordinate2D = updatedLocation.coordinate
        let userDefaults: UserDefaults = UserDefaults.standard
        userDefaults.setValue("\(newCoordinate.latitude)", forKey: "current_location_latitude")
        userDefaults.setValue("\(newCoordinate.longitude)", forKey: "current_location_longitude")
        userDefaults.synchronize()
        
        if let userLat = UserDefaults.standard.value(forKey: "current_location_latitude") as? String, let userLong = UserDefaults.standard.value(forKey: "current_location_longitude") as? String {
            
            let location: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(userLat)!), longitude: CLLocationDegrees(Double(userLong)!))
            
            self.geoFire.setLocation(location, forKey: API.User.CURRENT_USER!.uid)
        }
    }
    
}
