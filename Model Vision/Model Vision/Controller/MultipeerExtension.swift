//
//  MultipeerExtension.swift
//  Model Vision
//
//  Created by Pranav Jain on 1/4/19.
//  Copyright © 2019 Pranav Jain. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import ARKit
extension ViewController {
    //MARK: - Multipeer functions
    
    //initalizing shared data
    @IBAction func shareSession(_ sender: Any) {
        sceneView.session.getCurrentWorldMap { worldMap, error in
            DispatchQueue.main.async {
                guard let map = worldMap
                    else { print("Error: \(error!.localizedDescription)"); return }
                guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                    else { fatalError("can't encode map") }
                self.multipeerSession.sendToAllPeers(data)
                self.initalizedWorldMap = true
                DispatchQueue.main.async {
                    self.statusViewController.cancelAllScheduledMessages()
                    self.statusViewController.scheduleMessage("SENT MAP TO PEERS", inSeconds: 5.0, messageType: .focusSquare)
                }
            }
            
        }
    }
    
    /// - Tag: ReceiveData
    func receivedData(_ data: Data, from peer: MCPeerID) {
        
        do {
            //set to false down the road
            if !self.initalizedWorldMap {
                if let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) {
                    // Run the session with the received world map.
                    let configuration = ARWorldTrackingConfiguration()
                    configuration.planeDetection = .horizontal
                    configuration.initialWorldMap = worldMap
                    self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
                    
                    // Remember who provided the map for showing UI feedback.
                    mapProvider = peer
                    self.isServer = false
                    self.initalizedWorldMap = true
                    DispatchQueue.main.async {
                        self.statusViewController.cancelAllScheduledMessages()
                        self.statusViewController.scheduleMessage("Recieved map from peer.", inSeconds: 5.0, messageType: .focusSquare)
                    }
                }
            }
            else
                if let lineNode = try? NSKeyedUnarchiver.unarchivedObject(ofClass: SCNNode.self, from: data) {
                    // Add anchor to the session, ARSCNView delegate adds visible content.
                    //sceneView.session.add(anchor: anchor)
                    //check that data exists
                    //put in right location
                    self.sceneView.scene.rootNode.addChildNode(lineNode!)
                    print("Added node to screen")
                }else if let boxAnchor = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARAnchor.self, from: data) {
                    sceneView.session.add(anchor: boxAnchor)
                }else{
                    print("unknown data recieved from \(peer)")
            }
        } catch {
            print("can't decode data recieved from \(peer). Was probably lines")
        }
    }
}
