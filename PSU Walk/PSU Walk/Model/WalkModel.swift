//
//  WalkModel.swift
//  PSU Walk
//
//  Created by Pranav Jain on 10/14/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import Foundation
import MapKit

class WalkModel {
    
    static let sharedInstance = WalkModel()
    fileprivate init() {
    }
    
    
    
    //MARK: - Locations
    // Centered in downtown State College
    let initialLocation = CLLocation(latitude: 40.794978, longitude: -77.860785)
    
    // define 4 corner points of downtown State College
    let downtownCoordinates = [(40.791831951313,-77.865203974557),
                               (40.800364570711,-77.853778542571),
                               (40.799476294037,-77.8525124806654),
                               (40.7908968034537,-77.8638607142546)].map {(a,b) in CLLocationCoordinate2D(latitude: a, longitude: b)}
    
    
    
    
    //MARK: - Search Categories
    fileprivate let categories = ["Airport", "Bar", "Coffee", "Dining", "Gas Station", "Grocery", "Hospital", "Hotel", "Laundry", "Library", "Movies", "Parking", "Pizza", "Shopping"]
    
    var categoryCount : Int {return categories.count}
    
    func category(atIndex index:Int) -> String? {
        guard categories.indices.contains(index) else {return nil}
        return categories[index]
    }
    
    func imageNameFor(category:String) -> String {
        return category
    }
    
    //MARK: - Search Results
    
    
    //MARK: -Visits
    
}
