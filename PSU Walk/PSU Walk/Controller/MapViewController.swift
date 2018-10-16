//
//  MapViewController.swift
//  PSU Walk
//
//  Created by Pranav Jain on 10/14/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController{//, MKMapViewDelegate, CLLocationManagerDelegate{

    
    @IBOutlet var mapView: MKMapView!
    let walkModel = WalkModel.sharedInstance
    let spanDelta = 0.01
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let location = walkModel.initialLocation
        let coordinate = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: spanDelta, longitudeDelta: spanDelta)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addPin(recognizer:)))
        mapView.addGestureRecognizer(recognizer)
        
        //locationManager.delegate = self
    }
    
    @objc func addPin(recognizer:UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            break
        default:
            break
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
