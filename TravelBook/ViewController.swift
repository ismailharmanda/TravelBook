//
//  ViewController.swift
//  TravelBook
//
//  Created by ismail harmanda on 31.10.2023.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer: )))
        gestureRecognizer.minimumPressDuration = 1
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let touchedPoint = gestureRecognizer.location(in: mapView)
            let touchedCoordinates =
            self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            let region = MKCoordinateRegion(center: touchedCoordinates, span: span)
            mapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = "New Annotation"
            annotation.subtitle = "Travel Book"
            self.mapView.addAnnotation(annotation)
        }
            }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
  
        let region = MKCoordinateRegion(center: location, span: span)
        
        mapView.setRegion(region, animated: true)
    }

    
}

