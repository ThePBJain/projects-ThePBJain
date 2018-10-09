//
//  ParkModel.swift
//  PA Parks
//
//  Created by Pranav Jain on 9/20/18.
//  Copyright (c) 2018 Pranav Jain. All rights reserved.
//  Further supporting code given by John Hannan for 475

import Foundation

struct Image : Codable {
    var imageName : String
    var caption : String
}
struct Park : Codable {
    var name : String
    var photos : [Image]
}

// All Parks are read in and maintained in an array
typealias Parks = [Park]

class ParkModel {
    static let sharedInstance = ParkModel()
    
    //all variables to handle layout
    let numParks = 6
    let allParks : Parks
    private let parkImages : [String:[Image]]
    private let tutorialImageNames = ["Tutorial1", "Tutorial2", "Tutorial3"]
    init () {
        let mainBundle = Bundle.main
        let solutionURL = mainBundle.url(forResource: "StateParks", withExtension: "plist")
        
        do {
            let data = try Data(contentsOf: solutionURL!)
            let decoder = PropertyListDecoder()
            allParks = try decoder.decode(Parks.self, from: data)
        } catch {
            print(error)
            allParks = []
        }
        var _parkImages = [String:[Image]]()
        for park in allParks{
            let name = park.name
            _parkImages[name] = park.photos
        }
        parkImages = _parkImages
    }
    
    func parkNames(index i:Int) -> String {
        return allParks[i].name
    }
    
    func parkImageCount(index i:Int) -> Int {
        return allParks[i].photos.count
    }
    
    func parkImageNames(park s:String) -> [String] {
        if let images = parkImages[s]?.map({ (image) -> String in
            image.imageName
        }) {
            return images
        }else{
            return []
        }
        
    }
    
    func parkImages(park s:String) -> [Image] {
        if let images = parkImages[s] {
            return images
        }else{
            return []
        }
    }
    
    func parkImage(at indexPath:IndexPath) -> Image {
        let key = allParks[indexPath.section].name
        let images = parkImages[key]!
        let image = images[indexPath.row]
        return image
    }
    
    func parkImageCaption(at indexPath:IndexPath) -> String {
        let image = parkImage(at: indexPath)
        return image.caption
    }
    
    func parkImageName(at indexPath:IndexPath) -> String {
        let image = parkImage(at: indexPath)
        return image.imageName
    }
    
    func parkTutorialImageNames(at i:Int) -> String {
        return tutorialImageNames[i]
    }
    
    var numberOfTutorialImages : Int {return tutorialImageNames.count}
    
    var numberOfParks : Int {return allParks.count }
    
    
    
}
