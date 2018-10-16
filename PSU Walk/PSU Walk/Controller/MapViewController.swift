//
//  MapViewController.swift
//  PSU Walk
//
//  Created by Pranav Jain on 10/14/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, BuildingTableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate{

    
    @IBOutlet var mapView: MKMapView!
    let walkModel = WalkModel.sharedInstance
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        // Do any additional setup after loading the view.
        let location = walkModel.initialLocation
        let coordinate = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: walkModel.spanDeltaNormal, longitudeDelta: walkModel.spanDeltaNormal)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        locationManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                mapView.showsUserLocation = true
            default:
                break
                
            }
        }
    }
    
    //MARK: - Location Manager Delegate
    //taken from the Around Town code
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied, .restricted:
            mapView.showsUserLocation = false
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.showsUserLocation = true
        default:
            break
            
        }
    }
    
    //MARK: - MapView Delegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is BuildingPin:
            return annotationView(forPin: annotation as! BuildingPin)
        default:
            return nil
        }
    }
    
 
    
    func annotationView(forPin droppedPin:BuildingPin) -> MKAnnotationView {
        let identifier = "BuildingPin"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: droppedPin, reuseIdentifier: identifier)
            view.pinTintColor = .psuBlue
            view.animatesDrop = true
            view.isDraggable = false
            view.canShowCallout = true
            let deleteButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
            deleteButton.setImage(walkModel.deleteImage(), for: .normal)
            view.rightCalloutAccessoryView = deleteButton
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation
        mapView.removeAnnotation(annotation!)
        
    }
    
    @objc func addPin(recognizer:UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            break
        default:
            break
        }
    }
    
    // MARK: - Building Table View Delegate Methods
    func dismissMe(with indexPath:IndexPath) {
        
        /*let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)*/
        
        
        self.dismiss(animated: true, completion: nil)
        let coordinate = walkModel.buildingLocation(at: indexPath)
        
        let pinAnnotation = BuildingPin(title: walkModel.buildingName(at: indexPath), coordinate: coordinate, favorite: nil)
        
        mapView.addAnnotation(pinAnnotation)
        let span = MKCoordinateSpan(latitudeDelta: walkModel.spanDeltaZoomed, longitudeDelta: walkModel.spanDeltaZoomed)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    
    //MARK: - Map Type Controller
    
    
    @IBAction func changeMapType(_ sender: Any) {
        if let segment = sender as? UISegmentedControl {
            switch segment.selectedSegmentIndex{
            case 0:
                mapView.mapType = .standard
            case 1:
                mapView.mapType = .satellite
            case 2:
                mapView.mapType = .hybrid
            default:
                mapView.mapType = .standard
            }
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        switch segue.identifier {
        case "BuildingSegue":
            let navController = segue.destination as! UINavigationController
            let buildingTableViewController = navController.topViewController! as! BuildingViewController
            buildingTableViewController.delegate = self
        default:
            //check if this is casued by tutorial
            assert(false, "Unhandled Segue")
        }
    }
    

}
