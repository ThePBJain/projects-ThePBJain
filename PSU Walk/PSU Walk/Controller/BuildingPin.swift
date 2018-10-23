//
//  BuildingPin.swift
//  PSU Walk
//
//  Created by Pranav Jain on 10/15/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import Foundation
import MapKit

class BuildingPin : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title : String?
    var favorite : Bool?
    var indexPath : IndexPath
    init(title: String, coordinate: CLLocationCoordinate2D, favorite: Bool?, indexPath: IndexPath) {
        self.title = title
        self.coordinate = coordinate
        self.favorite = favorite
        self.indexPath = indexPath
    }
}
