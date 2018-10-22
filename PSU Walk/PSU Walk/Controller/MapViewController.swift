//
//  MapViewController.swift
//  PSU Walk
//
//  Created by Pranav Jain on 10/14/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import UIKit
import MapKit

extension CLLocationCoordinate2D {
    static func + (left: CLLocationCoordinate2D, right: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: left.latitude+right.latitude, longitude: left.longitude+right.longitude)
    }
    static func - (left: CLLocationCoordinate2D, right: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: left.latitude-right.latitude, longitude: left.longitude-right.longitude)
    }
    static func / (left: CLLocationCoordinate2D, right: Double) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: left.latitude/right, longitude: left.longitude/right)
    }
}
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
    
    // MARK: - TableView Delegate Dismiss Functions
    
    func dismissMe() {
        self.dismiss(animated: true, completion: nil)
    }
    
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
    
    func addDirectionPins(withSource indexPathSource:IndexPath, withDestination indexPathDest:IndexPath) {
        
        /*let allAnnotations = self.mapView.annotations
         self.mapView.removeAnnotations(allAnnotations)*/
        self.dismiss(animated: true, completion: nil)
        
        var sourceCoordinate = MKMapItem.forCurrentLocation().placemark.coordinate
        if indexPathSource.row >= 0 {
            sourceCoordinate = walkModel.buildingLocation(at: indexPathSource)
        }
        
        let sourceAnnotation = BuildingPin(title: walkModel.buildingName(at: indexPathSource), coordinate: sourceCoordinate, favorite: nil)
        
        var destCoordinate = MKMapItem.forCurrentLocation().placemark.coordinate
        if indexPathDest.row >= 0 {
            destCoordinate = walkModel.buildingLocation(at: indexPathDest)
        }
        
        let destAnnotation = BuildingPin(title: walkModel.buildingName(at: indexPathDest), coordinate: destCoordinate, favorite: nil)
        
        mapView.addAnnotation(sourceAnnotation)
        mapView.addAnnotation(destAnnotation)
        
        //distance formula
        let centerPoint = (sourceCoordinate + destCoordinate)/2.0
        let latDelta = (sourceAnnotation.coordinate.latitude - destAnnotation.coordinate.latitude) * 1.3
        let longDelta = (sourceAnnotation.coordinate.longitude - destAnnotation.coordinate.longitude) * 1.3
        let span = MKCoordinateSpan(latitudeDelta: latDelta.magnitude, longitudeDelta: longDelta.magnitude)
        let region = MKCoordinateRegion(center: centerPoint, span: span)
        mapView.setRegion(region, animated: true)
        requestDirections(source: sourceAnnotation, destination: destAnnotation)
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
    
    //taken from Around Town
    func requestDirections(source: BuildingPin, destination:BuildingPin) {
        let walkingRouteRequest = MKDirections.Request()
        walkingRouteRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: source.coordinate))
        walkingRouteRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination.coordinate))
        walkingRouteRequest.transportType = .walking
        walkingRouteRequest.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: walkingRouteRequest)
        directions.calculate { (response, error) in
            guard error == nil else {print(error?.localizedDescription); return}
            
            let route = response?.routes.first!
            self.mapView.addOverlay((route?.polyline)!)
            
            
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
        case "FavoriteSegue":
            let navController = segue.destination as! UINavigationController
            let buildingTableViewController = navController.topViewController! as! FavoriteViewController
            buildingTableViewController.delegate = self
        default:
            //check if this is casued by tutorial
            assert(false, "Unhandled Segue")
        }
    }
    

}
