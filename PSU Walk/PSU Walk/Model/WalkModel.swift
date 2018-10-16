//
//  WalkModel.swift
//  PSU Walk
//
//  Created by Pranav Jain on 10/14/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import Foundation
import MapKit



struct Building : Codable {
    var name : String
    var opp_bldg_code : Int
    var year_constructed: Int
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var photo : String
}

// All Parks are read in and maintained in an array
typealias Buildings = [Building]

class WalkModel {
    
    static let sharedInstance = WalkModel()
    let allBuildings : Buildings
    
    fileprivate let buildingByInitial: [String:[Building]]
    fileprivate let buildingKeys : [String]
    
    fileprivate init() {
        
        let mainBundle = Bundle.main
        let solutionURL = mainBundle.url(forResource: "buildings", withExtension: "plist")
        
        do {
            let data = try Data(contentsOf: solutionURL!)
            let decoder = PropertyListDecoder()
            allBuildings = try decoder.decode(Buildings.self, from: data)
            // create dictionary mapping first letter to states
            var _buildingByInitial = [String:[Building]]()
            for building in allBuildings {
                let letter = String(building.name.first!)
                if  _buildingByInitial[letter]?.append(building) == nil {
                    _buildingByInitial[letter] = [building]
                }
            }
            /*for (_, var value) in _buildingByInitial {
                value.sort { (building1, building2) -> Bool in
                    return building1.name < building2.name
                }
            }*/
            buildingByInitial = _buildingByInitial
            buildingKeys = buildingByInitial.keys.sorted()
        } catch {
            print(error)
            allBuildings = []
            buildingByInitial = [:]
            buildingKeys = []
        }
        print(allBuildings)
    }
    
    //MARK: - Methods for TableView
    var numberOfBuildings : Int {return allBuildings.count }
    
    var numberOfInitials : Int {return buildingKeys.count}
    
    func numberOfValuesForKey(atIndex index:Int) -> Int {
        let key = buildingKeys[index]
        let buildings = buildingByInitial[key]!
        return buildings.count
        
    }
    
    
    
    
    func theBuilding(at indexPath:IndexPath) -> Building {
        let key = buildingKeys[indexPath.section]
        let buildings = buildingByInitial[key]!
        let building = buildings[indexPath.row]
        return building
    }
    
    func buildingName(at indexPath:IndexPath) -> String {
        let building = theBuilding(at: indexPath)
        return building.name
    }
    
    func buildingCode(at indexPath:IndexPath) -> Int {
        let building = theBuilding(at: indexPath)
        
        return building.opp_bldg_code
    }
    
    func buildingYear(at indexPath:IndexPath) -> Int {
        let building = theBuilding(at: indexPath)
        
        return building.year_constructed
    }
    
    func buildingLocation(at indexPath:IndexPath) -> CLLocationCoordinate2D {
        let building = theBuilding(at: indexPath)
        
        return CLLocationCoordinate2D(latitude: building.latitude, longitude: building.longitude)
    }
    
    var buildingIndexTitles : [String] {return buildingKeys}
    func buildingIndexTitle(forIndex index:Int) -> String {
        return buildingKeys[index]
    }
    
    
    
    
    
    //MARK: - Locations
    // Centered in Penn State Main
    let initialLocation = CLLocation(latitude: 40.7982133, longitude: -77.8599084)
    let spanDeltaNormal = 0.03
    let spanDeltaZoomed = 0.015
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
    
    
    //MARK: - Pin PNGs
    
    func deleteImage() -> UIImage? {
        return UIImage(named: "delete_sign")
    }
    
    
    //MARK: -Visits
    
}
