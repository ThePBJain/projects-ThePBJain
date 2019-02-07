//
//  PilotExtension.swift
//  Model Vision
//
//  Created by Pranav Jain on 2/3/19.
//  Copyright © 2019 Pranav Jain. All rights reserved.
//

import Foundation
import UIKit
import CoreML
import SceneKit
public struct Thruster {
    var position: SCNVector3
    var rotation: SCNVector3
    func toArray() -> Array<Double> {
        return position.toArray() + rotation.toArray()
    }
}
extension SCNVector3 {
    func toArray() -> Array<Double> {
        return [Double(self.x), Double(self.y), Double(self.z)]
    }
}
public class PilotBrain {
    var goalLocation: SCNVector3
    //Drone
    var droneLocation: SCNVector3
    var droneRotation: SCNVector3
    var droneVelocity: SCNVector3
    var droneAngleVelocity: SCNVector3
    var droneAcceleration: SCNVector3
    
    //Thrusters
    var thrusters = [Thruster]()
    
    init(droneLocation: SCNVector3, goalLocation: SCNVector3){
        //everything is in meters, seconds and degrees
        
        self.droneLocation = droneLocation
        //for testing set it to camera origin
        self.goalLocation = goalLocation
        //drone rotation might not be zero
        self.droneRotation = SCNVector3Zero
        self.droneVelocity = SCNVector3Zero
        self.droneAngleVelocity = SCNVector3Zero
        self.droneAcceleration = SCNVector3Zero
        //initalize drone velocity to 0
        
        //setup your 8 thrusters: Odd thrusters are inactive, even ones are active
        for i in 0...7 {
            var thruster = Thruster.init(position: SCNVector3Zero, rotation: SCNVector3Zero)
            //if even...
            if i % 2 == 0 {
                switch i {
                case 0:
                    thruster.position = SCNNode.localFront * 0.4 //SCNVector3(0.0, 0.0, -0.4)
                    
                case 2:
                    thruster.position = SCNNode.localRight * 0.4 //SCNVector3(0.4, 0.0, 0.0)
                case 4:
                    thruster.position = SCNNode.localFront * -0.4 //SCNVector3(0.0, 0.0, 2.0)
                case 6:
                    thruster.position = SCNNode.localRight * -0.4 //SCNVector3(-2.0, 0.0, 0.0)
                default:
                    fatalError("Unexpected value for thruster: \(i)")
                }
            }
            self.thrusters.append(thruster)
        }
        
    }
    /*
    private lazy var DroneForceVectors: MLMultiArray = {
        // Instantiate the model from its generated Swift class.
        let model = pilotbrain_v1()
        //TODO: find a cleaner way of doing this
        var inputArray = goalLocation.toArray() + droneLocation.toArray() + droneRotation.toArray() + droneVelocity.toArray() + droneAngleVelocity.toArray() + droneAcceleration.toArray()
        
        //use reduce in the future
        for thruster in thrusters {
            inputArray += thruster.toArray()
        }
        
        guard let multiArray = try? MLMultiArray(shape: [66], dataType: .double) else {
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        for (index, element) in inputArray.enumerated() {
            multiArray[index] = NSNumber(floatLiteral: element)
        }
        print(multiArray)
        
        let pilotInput = pilotbrain_v1Input(vector_observation__0: multiArray)
        guard let pilotBrainOutput = try? model.prediction(input: pilotInput) else {
            fatalError("Unexpected runtime error.")
        }
        
        return pilotBrainOutput.action__0
        
    }()*/
    
    func getDroneVectors() -> MLMultiArray {
        //return self.DroneForceVectors
        // Instantiate the model from its generated Swift class.
        //let model = pilotbrain_v1()
        let model = pilotbrain_v2()
        //TODO: find a cleaner way of doing this
        var inputArray = goalLocation.toArray() + droneLocation.toArray() + droneRotation.toArray() + droneVelocity.toArray() + droneAngleVelocity.toArray() + droneAcceleration.toArray()
        print("------------")
        print("Input Values in PilotBrain: \(inputArray)")
        //use reduce in the future
        for thruster in thrusters {
            inputArray += thruster.toArray()
        }
        
        guard let multiArray = try? MLMultiArray(shape: [66], dataType: .double) else {
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        for (index, element) in inputArray.enumerated() {
            multiArray[index] = NSNumber(floatLiteral: element)
        }
        //print(multiArray)
        
        //let pilotInput = pilotbrain_v1Input(vector_observation__0: multiArray)
        let pilotInput = pilotbrain_v2Input(vector_observation__0: multiArray)
        guard let pilotBrainOutput = try? model.prediction(input: pilotInput) else {
            fatalError("Unexpected runtime error.")
        }
        
        return pilotBrainOutput.action__0
    }
    
}



