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
import SmaatoSDKCore
import SmaatoSDKBanner
import Amplitude_iOS

// heat map so current user can find concentrations of nearby users
class MapVC: UIViewController, MGLMapViewDelegate {
    
    @IBOutlet weak var navBar: UIView!
    
    @IBOutlet weak var mapView: MGLMapView!
    
    @IBOutlet weak var dismissBtn: UIButton!
    
    @IBOutlet weak var bannerView: SMABannerView!

    var heatmapLoaded = false
    var locations: [CLLocationCoordinate2D] = []

    let manager = CLLocationManager()
    lazy var functions = Functions.functions(app: FirebaseApp.app()!)

    let icon = UIImage(named: "icon-info")!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.logAmplitudeUserNearbyMapViewEvent()
        
        configureLocationManager()

        navBar.setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: 10), color: .init(white: 0, alpha: 0.3))
        
        mapView.userTrackingMode = .follow
        mapView.delegate = self
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true, completionHandler: nil)
        
        // set banner view events delegate (Google AdMob)
        bannerView.delegate = self
        
        // load ads
        loadAds()
    }
    
    // setup banner ad
    func loadAds() {
        bannerView.autoreloadInterval = .short
        bannerView.delegate = self
        bannerView.load(withAdSpaceId: "131522462", adSize: .xxLarge_320x50)
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
    }
    
    // layout heatmap
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        if !locations.isEmpty {
            configureHeatmap(with: style)
        }
    }

    func configureHeatmap(with style: MGLStyle) {
        if heatmapLoaded {
            return
        }

        heatmapLoaded = true

        var points = [MGLPointFeature]()
        for location in locations {
            let point = MGLPointFeature()
            point.coordinate = location
            points.append(point)
        }

//        let source = MGLShapeSource(identifier: "locations", shapes: points, options: nil)
        let source = MGLShapeSource(identifier: "clusteredLocations",
                                    features: points,
                                    options: [.clustered: true, .clusterRadius: 30.0])
        style.addSource(source)

        // Use a template image so that we can tint it with the `iconColor` runtime styling property.
        style.setImage(icon.withRenderingMode(.alwaysTemplate), forName: "icon")

        // Show unclustered features as icons. The `cluster` attribute is built into clustering-enabled
        // source features.
//        let locations = MGLSymbolStyleLayer(identifier: "locations", source: source)
//        locations.iconImageName = NSExpression(forConstantValue: "icon")
//        locations.iconColor = NSExpression(forConstantValue: UIColor.darkGray.withAlphaComponent(0.9))
//        locations.predicate = NSPredicate(format: "cluster != YES")
//        locations.iconAllowsOverlap = NSExpression(forConstantValue: true)

        let locations = MGLCircleStyleLayer(identifier: "locations", source: source)
        locations.circleRadius = NSExpression(forConstantValue: NSNumber(value: 15.0))
        locations.circleOpacity = NSExpression(forConstantValue: 0.75)
        locations.circleStrokeColor = NSExpression(forConstantValue: UIColor.white.withAlphaComponent(0.75))
        locations.circleStrokeWidth = NSExpression(forConstantValue: 2)
        locations.circleColor = NSExpression(forConstantValue: UIColor.glympsBlue.withAlphaComponent(0.75))
        locations.predicate = NSPredicate(format: "cluster != YES")
        style.addLayer(locations)

        // Color clustered features based on clustered point counts.
        let stops = [
            2: UIColor.glympsBlue,
            50: UIColor.red,
            100: UIColor.orange
        ]

        // Show clustered features as circles. The `point_count` attribute is built into
        // clustering-enabled source features.
        let circlesLayer = MGLCircleStyleLayer(identifier: "clusteredLocations", source: source)
        circlesLayer.circleRadius = NSExpression(forConstantValue: NSNumber(value: 15.0))
        circlesLayer.circleOpacity = NSExpression(forConstantValue: 0.75)
        circlesLayer.circleStrokeColor = NSExpression(forConstantValue: UIColor.white.withAlphaComponent(0.75))
        circlesLayer.circleStrokeWidth = NSExpression(forConstantValue: 2)
        circlesLayer.circleColor = NSExpression(format: "mgl_step:from:stops:(point_count, %@, %@)", UIColor.lightGray, stops)
        circlesLayer.predicate = NSPredicate(format: "cluster == YES")
        style.addLayer(circlesLayer)

        // Label cluster circles with a layer of text indicating feature count. The value for
        // `point_count` is an integer. In order to use that value for the
        // `MGLSymbolStyleLayer.text` property, cast it as a string.
        let numbersLayer = MGLSymbolStyleLayer(identifier: "clusteredLocationsNumbers", source: source)
        numbersLayer.textColor = NSExpression(forConstantValue: UIColor.white)
        numbersLayer.textFontSize = NSExpression(forConstantValue: NSNumber(value: 15.0))
        numbersLayer.iconAllowsOverlap = NSExpression(forConstantValue: true)
        numbersLayer.text = NSExpression(format: "CAST(point_count, 'NSString')")
        numbersLayer.predicate = NSPredicate(format: "cluster == YES")
        style.addLayer(numbersLayer)

//        // Create a heatmap layer.
//        let heatmapLayer = MGLHeatmapStyleLayer(identifier: "locations", source: source)
//
//        // Adjust the color of the heatmap based on the point density.
//        let colorDictionary: [NSNumber: UIColor] = [
//            0.0: .clear,
//            0.01: .white,
//            0.15: UIColor(red: 0.19, green: 0.30, blue: 0.80, alpha: 1.0),
//            0.5: UIColor(red: 0.73, green: 0.23, blue: 0.25, alpha: 1.0),
//            1: .yellow
//        ]
//        heatmapLayer.heatmapColor = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($heatmapDensity, 'linear', nil, %@)", colorDictionary)
//
//        // Heatmap weight measures how much a single data point impacts the layer's appearance.
//        heatmapLayer.heatmapWeight = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:(mag, 'linear', nil, %@)",
//                                                  [0: 0,
//                                                   6: 1])
//
//        // Heatmap intensity multiplies the heatmap weight based on zoom level.
//        heatmapLayer.heatmapIntensity = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
//                                                     [0: 1,
//                                                      9: 3])
//        heatmapLayer.heatmapRadius = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
//                                                  [0: 4,
//                                                   9: 30])
//
//        // The heatmap layer should be visible up to zoom level 9.
//        heatmapLayer.heatmapOpacity = NSExpression(forConstantValue: 0.75)
//
//        if let symbolLayer = style.layers.filter({ $0 is MGLSymbolStyleLayer })[safe: 8] {
//            style.insertLayer(heatmapLayer, below: symbolLayer)
//        } else {
//            style.addLayer(heatmapLayer)
//        }
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
    
    func logAmplitudeUserNearbyMapViewEvent() {
        Amplitude.instance().logEvent("User Nearby Map View")
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

extension MapVC: SMABannerViewDelegate {
   // return presenting view controller to display Ad contents modally, e.g. in internal WebBrowser
   func presentingViewController(for bannerView: SMABannerView) -> UIViewController {
        return self
   }
   
   // check if banner loaded successfully
   func bannerViewDidLoad(_ bannerView: SMABannerView) {
        print("Banner has loaded successfully!")
   }
    
   // check if banner failed to load
   func bannerView(_ bannerView: SMABannerView, didFailWithError error: Error) {
        print("Banner failed to load with error: \(error.localizedDescription)")
   }
 
   // notification callback: ads TTL has expired
   func bannerViewDidTTLExpire(_ bannerView: SMABannerView) {
        print("Banner TTL has expired. You should load new one")
   }
}

extension Array {
    public subscript(safe index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }
}
