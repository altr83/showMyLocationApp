//
//  ViewController.swift
//  showMyLocation
//
//  Created by Vitaliy on 1/10/19.
//  Copyright © 2019 Vitaliy. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var currentUserLocation: CLLocation!
    var mapOverlay: MKOverlay!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuth()
        } else {
            let alertV = UIAlertController(title: "Error", message: "Location services is unavaible", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel , handler: nil)
            alertV.addAction(action)
            self.present(alertV, animated: true, completion: nil)
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationAuth() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            centerMapView()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            break
        case .authorizedAlways:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        }
    }
    
    func centerMapView() {
        if let location = locationManager.location?.coordinate {
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegion.init(center: location, span: span)
            map.setRegion(region, animated: true)
            currentUserLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        }
    }
    
    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        let overlays = map.overlays
        map.removeOverlays(overlays)
        let pinLocation = sender.location(in: self.map)
        let pinCoord = self.map.convert(pinLocation, toCoordinateFrom: self.map)
        let annotation = MKPointAnnotation()
        annotation.coordinate = pinCoord
        annotation.title = "Destiny"
        
        self.map.removeAnnotations(map.annotations)
        self.map.addAnnotation(annotation)
        
        let destinationLocation = CLLocation(latitude: pinCoord.latitude, longitude: pinCoord.longitude)
        
        let distance = "\(Int(currentUserLocation.distance(from: destinationLocation))) meters"
        
        distanceLabel.text! = distance
        drawRoute(to: destinationLocation)
    }
    
    func drawRoute(to destination: CLLocation) {
        let destinationPlacemark = MKPlacemark(coordinate: destination.coordinate, addressDictionary: nil)
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = MKMapItem.forCurrentLocation()
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = .automobile
        let direction = MKDirections(request: directionRequest)
        
        direction.calculate { (response, error)->Void in
            guard let response = response else {
                if let error = error {
                        print("Error: \(error)")
                    }
                return
            }
            
            let route = response.routes[0]
            self.map.add((route.polyline), level: MKOverlayLevel.aboveRoads)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        mapOverlay = overlay
        renderer.strokeColor = .red
        renderer.lineWidth = 4.0
        return renderer
    }
}

