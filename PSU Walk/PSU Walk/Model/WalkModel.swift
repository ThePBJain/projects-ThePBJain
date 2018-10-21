//
//  WalkModel.swift
//  PSU Walk
//
//  Created by Pranav Jain on 10/14/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import Foundation
import MapKit




class Place : NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title : String?
    let phoneNumber : String?
    let url : URL?
    let category : String
    
    init(title:String?, category:String, coordinate:CLLocationCoordinate2D, phoneNumber: String?, url: URL?) {
        self.title = title
        self.coordinate = coordinate
        self.phoneNumber = phoneNumber
        self.url = url
        self.category = category
    }
    
    var mapItem : MKMapItem {
        let placeMark = MKPlacemark(coordinate: coordinate)
        let item = MKMapItem(placemark: placeMark)
        return item
    }
}


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
    var favoriteBuildings : Buildings
    fileprivate var favoriteBuildingByInitial: [String:[Building]]
    fileprivate var favoriteBuildingKeys : [String]
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
        favoriteBuildings = []
        favoriteBuildingByInitial = [:]
        favoriteBuildingKeys = []
    }
    
    //Designed and built apon Dr. Hannan's Around Town model.
    
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
    
    
    
    
    //MARK: - Edit Favorites
    
    var numberOfFavoriteBuildings : Int {return favoriteBuildings.count }
    
    var numberOfFavoriteInitials : Int {return favoriteBuildingKeys.count}
    
    func favoriteBuilding(at indexPath:IndexPath) -> Building {
        let key = favoriteBuildingKeys[indexPath.section]
        let buildings = favoriteBuildingByInitial[key]!
        let building = buildings[indexPath.row]
        return building
    }
    
    var favoriteIndexTitles : [String] {return favoriteBuildingKeys}
    func favoriteIndexTitle(forIndex index:Int) -> String {
        return favoriteBuildingKeys[index]
    }
    
    func addToFavorites(with indexPath:IndexPath) -> Bool {
        //return true if successfully added
        let building = theBuilding(at: indexPath)
        if favoriteBuildings.contains(where: { (element) -> Bool in
            return element.name == building.name && element.latitude == building.latitude && element.longitude == building.longitude
        }) {
            return false
        }else{
            favoriteBuildings.append(building)
            let letter = String(building.name.first!)
            if favoriteBuildingByInitial[letter]?.append(building) == nil {
                favoriteBuildingByInitial[letter] = [building]
            }
            favoriteBuildingKeys = favoriteBuildingByInitial.keys.sorted()
            
            return true
        }
    }
    
    func removeFromFavorites(with indexPath:IndexPath) -> Bool {
        let building = favoriteBuilding(at: indexPath)
        
        let index = favoriteBuildings.firstIndex(where: { (element) -> Bool in
            return element.name == building.name && element.latitude == building.latitude && element.longitude == building.longitude
        })
        if let i = index {
            favoriteBuildings.remove(at: i)
            let letter = String(building.name.first!)
            let letterIndex = favoriteBuildingByInitial[letter]?.firstIndex(where: { (element) -> Bool in
                return element.name == building.name && element.latitude == building.latitude && element.longitude == building.longitude
            })
            if letterIndex != nil {
                favoriteBuildingByInitial[letter]?.remove(at: letterIndex!)
            }
            favoriteBuildingKeys = favoriteBuildingByInitial.keys.sorted()
            return true
        }
        
        return false
    }
    
    func numberOfFavoritesForKey(atIndex index:Int) -> Int {
        let key = favoriteBuildingKeys[index]
        let buildings = favoriteBuildingByInitial[key]!
        return buildings.count
        
    }
    
    func returnFavorites(with index:Int) -> Building {
        let building = favoriteBuildings[index]
        
        return building
    }
    
    
    func favoriteBuildingName(at indexPath:IndexPath) -> String {
        let building = favoriteBuilding(at: indexPath)
        return building.name
    }
    
    func favoriteBuildingCode(at indexPath:IndexPath) -> Int {
        let building = favoriteBuilding(at: indexPath)
        
        return building.opp_bldg_code
    }
    
    func favoriteBuildingYear(at indexPath:IndexPath) -> Int {
        let building = favoriteBuilding(at: indexPath)
        
        return building.year_constructed
    }
    
    func favoriteBuildingLocation(at indexPath:IndexPath) -> CLLocationCoordinate2D {
        let building = favoriteBuilding(at: indexPath)
        
        return CLLocationCoordinate2D(latitude: building.latitude, longitude: building.longitude)
    }
    
    
    //MARK: - Pin PNGs
    
    func deleteImage() -> UIImage? {
        return UIImage(named: "delete_sign")
    }
    
    
    //MARK: -Visits
    
}
