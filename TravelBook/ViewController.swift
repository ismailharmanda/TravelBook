//
//  ViewController.swift
//  TravelBook
//
//  Created by ismail harmanda on 31.10.2023.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var selectedLocation: Place?
    
    
    @IBOutlet weak var mapView: MKMapView!
    let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
    var didLocationUpdatedFirstTime = false
    
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
        
        if (selectedLocation != nil){
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let location = CLLocationCoordinate2D(latitude: selectedLocation!.latitude, longitude: selectedLocation!.longitude)
            let region = MKCoordinateRegion(center: location, span: span)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            let titleField = selectedLocation!.title
            let descriptionField = selectedLocation!.subtitle
            annotation.title = titleField
            annotation.subtitle = descriptionField
            mapView.addAnnotation(annotation)
            mapView.setRegion(region, animated: true)
        }
    }
    
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let context = appDelegate.persistentContainer.viewContext
            let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Place", into: context)
            let touchedPoint = gestureRecognizer.location(in: mapView)
            let touchedCoordinates =
            self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            let region = MKCoordinateRegion(center: touchedCoordinates, span: span)
            mapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            var titleField = UITextField()
            var descriptionField = UITextField()
            let alert  = UIAlertController(title: "New Place", message: "", preferredStyle:.alert)
            let confirmAction = UIAlertAction(title: "Add Place", style: .default) { action in
                if let safeTitleField = titleField.text {
                    annotation.title = safeTitleField
                    newPlace.setValue(safeTitleField, forKey: "title")
                }
                if let safeDescriptionField = descriptionField.text{
                    annotation.subtitle = safeDescriptionField
                    newPlace.setValue(safeDescriptionField, forKey: "subtitle")
                }
                newPlace.setValue(touchedCoordinates.latitude, forKey: "latitude")
                newPlace.setValue(touchedCoordinates.longitude, forKey: "longitude")
                newPlace.setValue(UUID(), forKey: "id")
                do {
                    try context.save()
                    self.navigationController?.popViewController(animated: true)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newData"), object: nil)
                }catch{
                    print(error)
                }
                
                self.mapView.addAnnotation(annotation)
                
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                alert.dismiss(animated: true)
            }
          
            alert.addTextField { alertTextField in
                alertTextField.placeholder = "Place"
                titleField = alertTextField
            }
            alert.addTextField { alertTextField in
                alertTextField.placeholder = "Additional Notes"
                descriptionField = alertTextField
            }
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            present(alert,animated:true)
            
        }
            }
    
    override func viewDidDisappear(_ animated: Bool) {
        selectedLocation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if (selectedLocation != nil || didLocationUpdatedFirstTime){
            return
        }
        
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
  
        let region = MKCoordinateRegion(center: location, span: span)
        
        didLocationUpdatedFirstTime = true
        
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
    
        let reuseId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        } else {
            pinView?.annotation = annotation
        }
        
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        var requestLocation = CLLocation(latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)!)
        
        CLGeocoder().reverseGeocodeLocation(requestLocation) { placemarks, error in
            
            if let safePlacemarks = placemarks {
                let newPlacemark = MKPlacemark(placemark: safePlacemarks[0])
                let item = MKMapItem(placemark: newPlacemark)
                item.name = (view.annotation?.title)!
                
                let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                
                item.openInMaps(launchOptions: launchOptions)
            }
        }
    }

    
}

