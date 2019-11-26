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
import FirebaseFunctions
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

    var locations: [CLLocationCoordinate2D] = []
//    var geoFire: GeoFire!
//    var geoFireRef: DatabaseReference!
    let manager = CLLocationManager()
    lazy var functions = Functions.functions(app: FirebaseApp.app()!)

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
        
//        self.geoFireRef = Database.database().reference().child("Geolocs")
//        self.geoFire = GeoFire(firebaseRef: self.geoFireRef)
    }
    
    // layout heatmap
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        if !locations.isEmpty {
            configureHeatmap(with: style)
        }
    }

    func configureHeatmap(with style: MGLStyle) {
        if let source = style.sources.first, let layer = style.layers.first {
            style.removeLayer(layer)
            style.removeSource(source)
        }

        var points = [MGLPointAnnotation]()
        for location in locations {
            let point = MGLPointAnnotation()
            point.coordinate = location
            points.append(point)
        }

        let source = MGLShapeSource(identifier: "locations", shapes: points, options: nil)
        style.addSource(source)

        // Create a heatmap layer.
        let heatmapLayer = MGLHeatmapStyleLayer(identifier: "locations", source: source)

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
        //heatmapLayer.heatmapOpacity = NSExpression(format: "mgl_step:from:stops:($zoomLevel, 0.75, %@)", [0: 0.75, 9: 0])
        style.addLayer(heatmapLayer)
    }
    
    // go back to "card deck"
    @IBAction func dismissBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func getHeatmapData(lat: Double, long: Double) {
        functions.httpsCallable("heatmap").call(["latitude": lat, "longitude": long]) { [weak self] (result, error) in
            if let error = error as NSError? {
                print(error)
            }

            guard let response = (result?.data as? [String: [[Double]]])?["locations"] else { return }

            self?.locations =  [
                   CLLocationCoordinate2D(latitude: 37.80243725413708, longitude: -122.42362685443663),
                   CLLocationCoordinate2D(latitude: 37.80243725413708, longitude: -122.42362685443663),
                   CLLocationCoordinate2D(latitude: 37.80243725413708, longitude: -122.42362685443663),
                   CLLocationCoordinate2D(latitude: 37.80243725413708, longitude: -122.42362685443663),
               ]
            
            for locationData in response {
                guard let lat = CLLocationDegrees(exactly: locationData[0]), let long = CLLocationDegrees(exactly: locationData[1]) else { return }
                let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
                self?.locations.append(location)
            }

            if let style = self?.mapView.style {
                self?.configureHeatmap(with: style)
            }
        }
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

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocation = locations.first else { return }

        getHeatmapData(lat: location.coordinate.latitude.magnitude, long: location.coordinate.longitude.magnitude)
    }
    
}
