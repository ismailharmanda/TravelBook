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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
  
        let region = MKCoordinateRegion(center: location, span: span)
        
        mapView.setRegion(region, animated: true)
    }

    
}

