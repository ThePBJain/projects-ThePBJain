//
//  WalkModel.swift
//  PSU Walk
//
//  Created by Pranav Jain on 10/14/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import Foundation
import MapKit



//Learned about Equatable from Apple Docs: https://developer.apple.com/documentation/swift/equatable
struct Building : Codable , Equatable{
    var name : String
    var opp_bldg_code : Int
    var year_constructed: Int
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var photo : String
    
    static func == (lhs: Building, rhs: Building) -> Bool {
        return lhs.name == rhs.name && lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
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
    
    func numBuildings(in buildings:[Building], for section:Int) -> Int {
        var count = 0
        let key = buildingKeys[section]
        for building in buildingByInitial[key] ?? [] {
            if buildings.contains(building) {
                count += 1
            }
        }
        return count
    }
    
    
    func theBuilding(at indexPath:IndexPath) -> Building? {
        if indexPath.section < 0 || indexPath.row < 0 {
            return nil
        }
        let key = buildingKeys[indexPath.section]
        let buildings = buildingByInitial[key]!
        let building = buildings[indexPath.row]
        return building
    }
    
    func buildingIndexToIndexPath(at index:Int) -> IndexPath? {
        if index < 0 {
            return nil
        }
        let building = allBuildings[index]
        let letter = String(building.name.first!)
        let _row = buildingByInitial[letter]?.firstIndex(of: building)
        
        let _section = buildingKeys.firstIndex(of: letter)
        if let row = _row, let section = _section {
            let indexPath = IndexPath(row: row, section: section)
            return indexPath
        }
        
        return nil
    }
    
    func indexPath(of building:Building) -> IndexPath? {
        let index = allBuildings.firstIndex(of: building)
        if let i = index {
            return buildingIndexToIndexPath(at: i)
        }
        return nil
    }
    
    func buildingName(at indexPath:IndexPath) -> String? {
        let building = theBuilding(at: indexPath)
        return building?.name
    }
    
    func buildingName(at index:Int) -> String? {
        let building = allBuildings[index]
        return building.name
        
    }
    
    func buildingCode(at indexPath:IndexPath) -> Int? {
        let building = theBuilding(at: indexPath)
        
        return building?.opp_bldg_code
    }
    
    func buildingCode(at index:Int) -> Int {
        let building = allBuildings[index]
        return building.opp_bldg_code
    }
    
    func buildingYear(at indexPath:IndexPath) -> Int? {
        let building = theBuilding(at: indexPath)
        
        return building?.year_constructed
    }
    
    func buildingYear(at index:Int) -> Int {
        let building = allBuildings[index]
        return building.year_constructed
    }
    
    func buildingLocation(at indexPath:IndexPath) -> CLLocationCoordinate2D? {
        let building = theBuilding(at: indexPath)
        if let blding = building {
            return CLLocationCoordinate2D(latitude: blding.latitude, longitude: blding.longitude)
        }
        return nil
    }
    

    
    
    var buildingIndexTitles : [String] {return buildingKeys}
    func buildingIndexTitle(forIndex index:Int) -> String {
        return buildingKeys[index]
    }
    
    
    
    
    
    //MARK: - Locations
    let initialLocation = CLLocation(latitude: 40.7982133, longitude: -77.8599084)
    let spanDeltaNormal = 0.03
    let spanDeltaZoomed = 0.015
    let spanBuffer = 1.7
    
    
    
    
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
        let building = theBuilding(at: indexPath)!
        
        if favoriteBuildings.contains(building) {
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
        let index = favoriteBuildings.firstIndex(of: building)
        if let i = index {
            favoriteBuildings.remove(at: i)
            let letter = String(building.name.first!)
            let letterIndex = favoriteBuildingByInitial[letter]?.firstIndex(of: building)
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
    
    func imageNotFound() -> UIImage? {
        return UIImage(named: "image-not-found")
    }
    
    
    //MARK: -Visits
    
}
