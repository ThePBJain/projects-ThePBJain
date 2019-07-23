//
//  Tutorials.swift
//  Model Vision
//
//  Created by Pranav Jain on 4/17/19.
//  Copyright © 2019 Pranav Jain. All rights reserved.
//

import Foundation
import ModelIO
import SceneKit.ModelIO
import ARKit

class Rotation : Codable {
    var x : Double
    var y : Double
    var z : Double
    var w : Double
    
    func get() -> SCNVector4 {
        return SCNVector4(x, y, z, w)
    }
}
class Position : Codable {
    var x : Double
    var y : Double
    var z : Double
    
    func get() -> SCNVector3 {
        return SCNVector3(x, y, z)
    }
}
struct Tutorial : Codable {
    var rotations : [Rotation]
    var positions : [Position]
    var orders : [String]
    var max_pieces : Int
}

struct Instruction {
    var rotation : SCNVector4
    var position : SCNVector3
    var order : String
    var instructionNum : Int
}

typealias Tutorials = [Tutorial]

class TutorialModel {
    
    
    static let sharedInstance = TutorialModel()
    var allTutorials : Tutorials
    fileprivate init() {
        
        let mainBundle = Bundle.main
        let solutionURL = mainBundle.url(forResource: "Tutorials", withExtension: "plist")
        
        do {
            let data = try Data(contentsOf: solutionURL!)
            let decoder = PropertyListDecoder()
            allTutorials = try decoder.decode(Tutorials.self, from: data)
            
        } catch {
            print(error)
            allTutorials = []
        }
    }
    
    //MARK: - Methods for Getting Instructions
    func getInstruction(after instruction:Instruction?, for tutorial:Int) -> Instruction? {
        let tutorial = allTutorials[tutorial]
        let num = (instruction?.instructionNum ?? -1) + 1
        if num >= tutorial.max_pieces {
            return nil
        }
        let order = tutorial.orders[num]
        let position = tutorial.positions[num].get()
        let rotation = tutorial.rotations[num].get()
        return Instruction(rotation: rotation, position: position, order: order, instructionNum: num)
    }
    
    //MARK: - Methods for getting Details about Tutorials
    func numTutorials() -> Int {
        return allTutorials.count
    }
}
