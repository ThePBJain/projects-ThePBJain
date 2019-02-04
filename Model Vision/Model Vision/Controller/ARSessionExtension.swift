//
//  ARSessionExtension.swift
//  Model Vision
//
//  Created by Pranav Jain on 1/4/19.
//  Copyright © 2019 Pranav Jain. All rights reserved.
//

import Foundation
import ARKit

extension ViewController: ARSessionDelegate {
    //MARK: - ARSessionDelegate
    func clamp<T>(_ value: T, minValue: T, maxValue: T) -> T where T : Comparable {
        return min(max(value, minValue), maxValue)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        switch frame.worldMappingStatus {
        case .notAvailable, .limited:
            self.shareMapButton.isEnabled = false
        case .extending:
            if !multipeerSession.connectedPeers.isEmpty {
                self.hasSent = true
                self.shareMapButton.isEnabled = true
            }
        case .mapped:
            if !multipeerSession.connectedPeers.isEmpty{
                self.hasSent = true
                self.shareMapButton.isEnabled = true
            }
        }
        
        //Drone Updates
        if let droneNode = self.drone {
            //print("found drone")
            if let pilotBrain = self.brain {
                if let goalNode = self.goalNode {
                    
                    //update data
                    //double check this
                    //pilotBrain.droneLocation = droneNode.worldPosition
                    pilotBrain.droneLocation = SCNVector3Zero
                    let goalLoc = droneNode.convertPosition(goalNode.worldPosition, from: self.sceneView.scene.rootNode)
                    pilotBrain.goalLocation = goalLoc
                    let eulerAnglesInDegrees = droneNode.eulerAngles * (180.0/Float.pi)
                    pilotBrain.droneRotation = eulerAnglesInDegrees
                    pilotBrain.droneVelocity = droneNode.physicsBody!.velocity
                    let angularVelocity = droneNode.physicsBody!.angularVelocity
                    let angularMagnitudeInDeg = angularVelocity.w * (180.0/Float.pi)
                    pilotBrain.droneAngleVelocity = SCNVector3(angularVelocity.x, angularVelocity.y, angularVelocity.z)*angularMagnitudeInDeg
                    //droneNode.physicsBody!.angularVelocity
                    
                    
                    let newForces = pilotBrain.getDroneVectors()
                    //pilotBrain.droneAcceleration = SCNVector3(x: 0.0, y: -9.8, z: 0.0)
                    droneNode.physicsBody!.clearAllForces()
                    print("------------")
                    print(newForces)
                    for i in 0...newForces.count-1 {
                        let force = newForces[i]
                        
                        let finalForce = self.clamp( Double(exactly: force)! * 40.0, minValue: 0.0, maxValue: 40.0)
                        //print(finalForce)
                        /*for thruster in pilotBrain.thrusters {
                            if i%2 == 0 {
                                let forceVector = SCNVector3(0, finalForce, 0)
                                droneNode.physicsBody!.applyForce(forceVector, at: thruster.position, asImpulse: false)
                                //pilotBrain.droneAcceleration += forceVector
                            }
                        }*/
                        if i%2 == 0 {
                            print(finalForce)
                            let thruster = pilotBrain.thrusters[i]
                            //droneNode.rotation
                            let forceVector = SCNVector3(0, finalForce, 0)
                            droneNode.physicsBody!.applyForce(forceVector, at: thruster.position, asImpulse: false)
                            //pilotBrain.droneAcceleration += forceVector
                        }
                        
                    }
                    
                }
                
            }
        }
        
        
        guard self.classifier.currentBuffer == nil, case .normal = frame.camera.trackingState else {
            return
        }
        
        // Retain the image buffer for Vision processing.
        self.classifier.currentBuffer = frame.capturedImage
        self.classifier.classifyCurrentImage()
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
