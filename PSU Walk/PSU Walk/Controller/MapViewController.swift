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
class MapViewController: UIViewController, BuildingTableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UIScrollViewDelegate{

    
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var navScrollView: UIScrollView!
    @IBOutlet weak var directionsView: UIView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet var mapView: MKMapView!
    let walkModel = WalkModel.sharedInstance
    let locationManager = CLLocationManager()
    var navOverlay : MKRoute?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        // Do any additional setup after loading the view.
        let location = walkModel.initialLocation
        let coordinate = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: walkModel.spanDeltaNormal, longitudeDelta: walkModel.spanDeltaNormal)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        etaLabel.adjustsFontForContentSizeCategory = true
        locationManager.delegate = self
        navScrollView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.directionsView.backgroundColor = .lightGreen
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
    
    override func viewDidLayoutSubviews() {
        if !self.directionsView.isHidden {
            let contentWidth = self.directionsView.frame.width * CGFloat((self.navOverlay?.steps.count)!)
            self.navScrollView.contentSize = CGSize(width: contentWidth, height: self.directionsView.frame.height)
            var index = 0
            self.navScrollView.subviews.forEach({
                if $0 is UILabel {
                    $0.frame.size = CGSize(width: self.directionsView.frame.width, height: self.directionsView.frame.height)
                    $0.frame.origin = CGPoint(x: self.directionsView.frame.width*CGFloat(index), y: 0)
                    index += 1
                }
            })
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
            deleteButton.tag = 0
            deleteButton.setImage(walkModel.deleteImage(), for: .normal)
            view.leftCalloutAccessoryView = deleteButton
            let infoButton = UIButton(type: .detailDisclosure)
            infoButton.tag = 1
            view.rightCalloutAccessoryView = infoButton
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation
        switch control.tag {
        case 0:
            mapView.removeAnnotation(annotation!)
        case 1:
            let buildingPin = annotation as! BuildingPin
            var message = "Unknown completion date for building."
            if let year = walkModel.buildingYear(at: buildingPin.indexPath) {
                message = "Building built in \(year)."
            }
            let alert = UIAlertController(title: buildingPin.title, message: message, preferredStyle: .actionSheet)
            let info = UIAlertAction(title: "Show Info", style: .default){action->Void in
                self.performSegue(withIdentifier: "InfoSegue", sender: buildingPin)
            }
            let close = UIAlertAction(title: "Done", style: .cancel, handler: nil)
            
            alert.addAction(info)
            alert.addAction(close)
            
            let containerViewWidth = 200
            let containerViewHeight = 200
            let containerFrame = CGRect(x:10, y: 70, width: CGFloat(containerViewWidth), height: CGFloat(containerViewHeight))
            let imageView : UIImageView = UIImageView(image: walkModel.imageNotFound())
            imageView.contentMode = .scaleAspectFit
            if walkModel.buildingImage(at: buildingPin.indexPath) != nil {
                imageView.image = walkModel.buildingImage(at: buildingPin.indexPath)
            }else if !walkModel.buildingPhoto(at: buildingPin.indexPath)!.isEmpty {
                imageView.image = UIImage(named: walkModel.buildingPhoto(at: buildingPin.indexPath)!)
            }
            imageView.frame = containerFrame
            imageView.center = CGPoint(x: alert.view.center.x, y: imageView.center.y)
            
            alert.view.addSubview(imageView)
            
            // Got constraints from online, really helped with making this look nice.
            let cons:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: imageView, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1.00, constant: 200)
            
            alert.view.addConstraint(cons)
            
            let cons2:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: imageView, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1.00, constant: 20)
            
            alert.view.addConstraint(cons2)
            
            /*let cons3:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: imageView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.00, constant: 0)
            
            alert.view.addConstraint(cons3)
            
            let cons4:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: imageView, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.00, constant: 0)
            
            alert.view.addConstraint(cons4)*/
            
            if let popoverPresentationController = alert.popoverPresentationController {
                popoverPresentationController.sourceView = view
                popoverPresentationController.sourceRect = view.bounds
                //alert
            }
            // present with our view controller
            self.present(alert, animated: true, completion: nil)
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
        let coordinate = walkModel.buildingLocation(at: indexPath)!
        
        let pinAnnotation = BuildingPin(title: walkModel.buildingName(at: indexPath)!, coordinate: coordinate, favorite: nil, indexPath: indexPath)
        
        mapView.addAnnotation(pinAnnotation)
        let span = MKCoordinateSpan(latitudeDelta: walkModel.spanDeltaZoomed, longitudeDelta: walkModel.spanDeltaZoomed)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func addDirectionPins(withSource indexPathSource:IndexPath, withDestination indexPathDest:IndexPath) {
        
        /*let allAnnotations = self.mapView.annotations
         self.mapView.removeAnnotations(allAnnotations)*/
        self.dismiss(animated: true, completion: nil)
        
        var sourceCoordinate = walkModel.buildingLocation(at: indexPathSource) ?? mapView.userLocation.coordinate
        if indexPathSource.row >= 0 {
            sourceCoordinate = walkModel.buildingLocation(at: indexPathSource)!
        }
        
        let sourceAnnotation = BuildingPin(title: walkModel.buildingName(at: indexPathSource) ?? "Current Location", coordinate: sourceCoordinate, favorite: nil, indexPath: indexPathSource)
        
        let destCoordinate = walkModel.buildingLocation(at: indexPathDest) ?? mapView.userLocation.coordinate
        
        
        let destAnnotation = BuildingPin(title: walkModel.buildingName(at: indexPathDest) ?? "Current Location", coordinate: destCoordinate, favorite: nil, indexPath: indexPathDest)
        
        mapView.addAnnotation(sourceAnnotation)
        mapView.addAnnotation(destAnnotation)
        
        //distance formula
        let centerPoint = (sourceCoordinate + destCoordinate)/2.0
        let latDelta = (sourceAnnotation.coordinate.latitude - destAnnotation.coordinate.latitude) * walkModel.spanBuffer
        let longDelta = (sourceAnnotation.coordinate.longitude - destAnnotation.coordinate.longitude) * walkModel.spanBuffer
        let span = MKCoordinateSpan(latitudeDelta: latDelta.magnitude, longitudeDelta: longDelta.magnitude)
        let region = MKCoordinateRegion(center: centerPoint, span: span)
        mapView.setRegion(region, animated: true)
        self.requestDirections(source: sourceAnnotation, destination: destAnnotation)
    }
    
    // MARK: - Scroll View Delegate Methods
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x/scrollView.bounds.width)
        if let step = self.navOverlay?.steps[index] {
            let stepBounds = step.polyline.boundingMapRect.offsetBy(dx: Double(-self.directionsView.frame.height/4.0), dy: Double(-self.directionsView.frame.height))
            let rect = MKMapRect(origin: stepBounds.origin, size: MKMapSize(width: stepBounds.width*walkModel.spanBuffer, height: stepBounds.height*walkModel.spanBuffer))
            let region = MKCoordinateRegion(rect)
            mapView.setRegion(region, animated: true)
            
        }
        
    }
    
    //MARK: - Map Controller
    
    
    @IBAction func trackUserLocation(_ sender: Any) {
        mapView.showsUserLocation = !mapView.showsUserLocation
        if mapView.showsUserLocation {
            let span = MKCoordinateSpan(latitudeDelta: walkModel.spanDeltaNormal, longitudeDelta: walkModel.spanDeltaNormal)
            let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
        
    }
    
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        switch overlay {
        case is MKPolygon:
            let polygon = MKPolygonRenderer(polygon: overlay as! MKPolygon)
            polygon.fillColor = UIColor.lightGray
            polygon.strokeColor = UIColor.blue
            polygon.alpha = 0.4
            polygon.lineWidth = 2.0
            return polygon
        case is MKCircle:
            let circle = MKCircleRenderer(circle: overlay as! MKCircle)
            circle.fillColor = UIColor.psuBlue
            circle.alpha = 0.4
            return circle
        case is MKPolyline:
            let line = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            line.strokeColor = UIColor.blue
            line.lineWidth = 4.0
            return line
        default:
            assert(false, "unhandled overlay")
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
            guard error == nil else {print(error!.localizedDescription); return}
            
            let route = response?.routes.first!
            //set eta
            let eta = Date(timeInterval: route?.expectedTravelTime ?? 0.0, since: Date())
            let formattedEta = DateFormatter.localizedString(from: eta, dateStyle: .none, timeStyle: .short)
            self.etaLabel.text = "Arrival By: \(formattedEta)"
            print("ETA (seconds): \(formattedEta)")
            
            
            let size = self.directionsView.frame.size
            let contentWidth = size.width * CGFloat(route!.steps.count)
            self.navScrollView.contentSize = CGSize(width: contentWidth, height: size.height)
            for (index, step) in (route?.steps)!.enumerated() {
                let stepLabel = UILabel(frame: self.directionsView.frame)
                stepLabel.text = " In \(step.distance) meters, \(step.instructions) "
                if step.instructions.count == 0 {
                    stepLabel.text = "In \(step.distance) meters, Turn onto a main road."
                }
                stepLabel.contentMode = .center
                stepLabel.textAlignment = .center
                stepLabel.adjustsFontSizeToFitWidth = true
                stepLabel.font = UIFont(descriptor: stepLabel.font!.fontDescriptor, size: 100)
                stepLabel.textColor = .white
                stepLabel.frame.origin = CGPoint(x: size.width*CGFloat(index), y: 0)
                self.navScrollView.addSubview(stepLabel)
                
                
            }
            if let overlay = self.navOverlay {
                self.mapView.removeOverlay(overlay.polyline)
                self.navScrollView.subviews.forEach({$0.removeFromSuperview()})
            }
            self.directionsView.isHidden = false
            self.navOverlay = route
            self.cancelButton.isEnabled = true
            self.cancelButton.title = "Cancel"
            self.mapView.addOverlay((route?.polyline)!)
            
            
        }
    }
    
    @IBAction func cancelNavigation(_ sender: Any) {
        if let overlay = self.navOverlay {
            self.mapView.removeOverlay(overlay.polyline)
            self.cancelButton.isEnabled = false
            self.cancelButton.title = ""
            self.navScrollView.subviews.forEach({$0.removeFromSuperview()})
            self.directionsView.isHidden = true
            self.navOverlay = nil
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
            buildingTableViewController.delegate?.view = self.view
        case "FavoriteSegue":
            let navController = segue.destination as! UINavigationController
            let buildingTableViewController = navController.topViewController! as! FavoriteViewController
            buildingTableViewController.delegate = self
            buildingTableViewController.delegate?.view = self.view
        case "InfoSegue":
            let navController = segue.destination as! UINavigationController
            let infoViewController = navController.topViewController! as! InfoViewController
            let buildingPin = sender as! BuildingPin
            infoViewController.configureView(with: buildingPin.indexPath)
            infoViewController.delegate = self
            infoViewController.delegate?.view = self.view
        default:
            //check if this is casued by tutorial
            assert(false, "Unhandled Segue")
        }
    }
    

}
