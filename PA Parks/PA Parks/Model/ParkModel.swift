//
//  ParkModel.swift
//  PA Parks
//
//  Created by Pranav Jain on 9/20/18.
//  Copyright (c) 2018 Pranav Jain. All rights reserved.
//  Further supporting code given by John Hannan for 475

import Foundation

struct ParkData : Codable {
    var name : String
    var count : Int
}

// All Parks are read in and maintained in an array
typealias Park = ParkData
typealias Parks = [Park]

class ParkModel {
    //all variables to handle layout
    let numParks = 6
    let allParks : Parks
    private let images : [String:[String]]
    
    init () {
        let mainBundle = Bundle.main
        let solutionURL = mainBundle.url(forResource: "Parks", withExtension: "plist")
        
        do {
            let data = try Data(contentsOf: solutionURL!)
            let decoder = PropertyListDecoder()
            allParks = try decoder.decode(Parks.self, from: data)
        } catch {
            print(error)
            allParks = []
        }
        var _images = [String:[String]]()
        for park in allParks{
            let name = park.name
            let count = park.count
            var _imageNames = [String]()
            for i in 1...count{
                //TODO: fix this for when over 10
                _imageNames.append("\(name)0\(i)")
            }
            _images[name] = _imageNames
        }
        images = _images
    }
    
    func parkNames(index i:Int) -> String {
        return allParks[i].name
    }
    
    func parkImageCount(index i:Int) -> Int {
        return allParks[i].count
    }
    
    func parkImages(park s:String) -> [String] {
        if let images = images[s] {
            return images
        }else{
            return []
        }
    }
    
    
}
