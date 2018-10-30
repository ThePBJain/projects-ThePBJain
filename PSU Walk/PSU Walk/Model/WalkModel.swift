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
class Building : Codable , Equatable{
    var name : String
    var opp_bldg_code : Int
    var year_constructed: Int
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var photo : String
    var image : UIImage?
    var text : String = "Insert Notes Here."
    
    static func == (lhs: Building, rhs: Building) -> Bool {
        return lhs.name == rhs.name && lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    private enum CodingKeys: String, CodingKey {
        case name
        case opp_bldg_code
        case year_constructed
        case latitude
        case longitude
        case photo
    }
    
}

// All Parks are read in and maintained in an array
typealias Buildings = [Building]

class WalkModel {
    
    static let sharedInstance = WalkModel()
    var allBuildings : Buildings
    var filteredBuildings = Buildings()
    
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
        if indexPath.section < 0 || indexPath.section >= buildingKeys.count || indexPath.row < 0 {
            return nil
        }
        let key = buildingKeys[indexPath.section]
        let buildings = buildingByInitial[key]!
        if(indexPath.row >= buildings.count){
            return nil
        }
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
    
    func buildingText(at indexPath:IndexPath) -> String? {
        let building = theBuilding(at: indexPath)
        return building?.text
    }
    
    func buildingPhoto(at indexPath: IndexPath) -> String? {
        let building = theBuilding(at: indexPath)
        return building?.photo
    }
    
    func buildingImage(at indexPath: IndexPath) -> UIImage? {
        let building = theBuilding(at: indexPath)
        return building?.image
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
    
    
    //MARK: - Edit Building Information
    
    func editBuildingName(at indexPath:IndexPath, with name:String) -> Bool {
        
        let building = theBuilding(at: indexPath)
        if (building?.name = name) != nil {
            return true
        }
        return false
    }
    
    func editBuildingName(at index:Int, with name:String) -> Bool {
        if index >= allBuildings.count {
            return false
        }
        let building = allBuildings[index]
        building.name = name
        return true
        
    }
    
    func editBuildingCode(at indexPath:IndexPath, with building_code:Int) -> Bool {
        let building = theBuilding(at: indexPath)
        if (building?.opp_bldg_code = building_code) != nil {
            return true
        }
        return false
    }
    
    func editBuildingCode(at index:Int, with building_code:Int) -> Bool {
        if index >= allBuildings.count {
            return false
        }
        let building = allBuildings[index]
        building.opp_bldg_code = building_code
        return true
    }
    
    func editBuildingYear(at indexPath:IndexPath, with year:Int) -> Bool {
        let building = theBuilding(at: indexPath)
        if (building?.year_constructed = year) != nil {
            return true
        }
        return false
    }
    
    func editBuildingYear(at index:Int, with year:Int) -> Bool {
        if index >= allBuildings.count {
            return false
        }
        let building = allBuildings[index]
        building.year_constructed = year
        return true
    }
    
    func editBuildingLocation(at indexPath:IndexPath, with coordinate:CLLocationCoordinate2D) -> Bool {
        let building = theBuilding(at: indexPath)
        if (building?.latitude = coordinate.latitude) != nil {
            if (building?.longitude = coordinate.longitude) != nil {
                return true
            }
            return false
        }
        return false
    }
    
    func editBuildingText(at indexPath:IndexPath, with text:String) -> Bool {
        let building = theBuilding(at: indexPath)
        if (building?.text = text) != nil {
            return true
        }
        return false
    }
    
    func editBuildingImage(at indexPath: IndexPath, with image:UIImage) -> Bool {
        let building = theBuilding(at: indexPath)
        if (building?.image = image) != nil {
            return true
        }
        return false
    }
    
    //MARK: - Filtered Buildings
    
    var numberOfFilteredBuildings : Int {return filteredBuildings.count }
    
    func updateFilter(filter: (Building) -> Bool){
        
        filteredBuildings = allBuildings.filter(filter)
        for building in filteredBuildings{
            print(building.name)
        }
    }
    
    func buildingFilterName(at index:Int) -> String? {
        let building = filteredBuildings[index]
        return building.name
        
    }
    
    func buildingFilterCode(at index:Int) -> Int {
        let building = filteredBuildings[index]
        return building.opp_bldg_code
    }
    
    func buildingFilterYear(at index:Int) -> Int {
        let building = filteredBuildings[index]
        return building.year_constructed
    }
    
    func buildingFilterLocation(at index:Int) -> CLLocationCoordinate2D? {
        let building = filteredBuildings[index]
        return CLLocationCoordinate2D(latitude: building.latitude, longitude: building.longitude)
    }
    
}
