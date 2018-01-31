//
//  MapViewController.swift
//  On The Map
//
//  Created by scythe on 11/29/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController {

    
    //MARK: Alerts
    private struct Alerts {
        
        //MARK: Network Alerts
        struct NetworkAlerts{
            /* Title */
            static let title  = "No Internet Connection"
            /* Message */
            static let message = "The Internet Connection Appears to be Offline"
        }
        
        //MARK: Data alerts
        struct DataError {
            // Titles
            static let serverError = "Server Error"
            //Message
            
        }
        
        //MARK: Map Alerts
        struct MapError{
            /* Title */
            static let mapErrorTitle = "Map Error"
            
            /* messages */
            static let mapUploadingMsg = "Map is Busy try again"
        }
    }
    
    
    //MARK: Properties

    @IBOutlet weak var mapView: MKMapView!
    
    var students : [StudentInformation] = []
    var annotations = [MKAnnotation]()
    //Indicator about map updating the locations
    var updatingLocations : Bool = false
    
   
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        mapView.delegate = self
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
  

    }
    
    /* Takes the address(mapString) or Coordinates latitude/longitude and add annotations on the map */
    private func showPinAnnotationsOnMap(locations : [StudentInformation]){
        
        mapView.removeAnnotations(mapView.annotations)
        
        var annotations = [MKPointAnnotation]()
        
        for location in locations {
            
            
            if location.latitude != 0.0 && location.longitude != 0.0{
                annotations.append(addAnnotation(location: location))
            }else if location.mapString != ""{
                if let annotationReturned = geocodingAddressString(location: location){
                    annotations.append(annotationReturned)
                }
            }else{
                print("error adding annotation for user \(location.uniqueKey)")
            }
        }
        
        
        mapView.addAnnotations(annotations)

    }
    
    
    /* geocoding the address and add annotation to the Map */
    private func geocodingAddressString(location: StudentInformation) -> MKPointAnnotation?{
        
        let geocoder = CLGeocoder()
        var annotation1 : MKPointAnnotation?
        geocoder.geocodeAddressString(location.mapString) { (placemarks, error) in
            
            guard error == nil else{

                print("Error on location : \(location) : \(error!.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first{
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude = placemark.location!.coordinate.latitude
                annotation.coordinate.longitude = placemark.location!.coordinate.longitude
                
                annotation.title = "\(location.firstname) \(location.lastname)"
                annotation.subtitle = "\(location.mediaURL)"
                
                annotation1 = annotation
            }
            
            
        }
        return annotation1
    }
    
    
    /* Adding annotation on the map having latitude and longitude */
    private func addAnnotation(location : StudentInformation) -> MKPointAnnotation{
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(location.latitude), longitude: CLLocationDegrees(location.longitude))
        //annotation.coordinate.longitude = location.longitude as! CLLocationDegrees
        
        annotation.title = "\(location.firstname) \(location.lastname)"
        annotation.subtitle = "\(location.mediaURL)"
        
        return annotation
    
    }
    
    
    
    /* Show Alert depending the issue */
    private func showAlert(title : String , message : String){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (_) in }
        
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    /* Refresh the map annotations by calling the getStudentData */
     func refreshMap() {
        print("RefreshMap(MAPVIEWCONTROLLER)")
        showPinAnnotationsOnMap(locations: Storage.sharedInstance().students)
        
    }
    
    func pinLocation(sender: UITabBarItem){
        
        
        
    }


}

extension MapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        //var pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        
        if annotationView == nil {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView.isEnabled = true
            pinView.canShowCallout = true
            pinView.animatesDrop = false
            /* MKAnnotationView only allows to change the image */
            //annotationView!.image = UIImage(named:"logo-u")!
            pinView.pinTintColor = UIColor(red: 0/255, green: 180/255, blue: 230/255, alpha: 1)
            
            let rightButton = UIButton(type: .detailDisclosure)
            rightButton.tintColor = UIColor.blue
            pinView.rightCalloutAccessoryView = rightButton
            
            annotationView = pinView
            
        }

        return annotationView

    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            if let link = view.annotation!.subtitle{
                openURL(urlString: link!)
            }
        }
    }
}
















