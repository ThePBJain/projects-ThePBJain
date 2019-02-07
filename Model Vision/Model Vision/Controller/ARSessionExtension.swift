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
