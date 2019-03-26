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
            print("RECIEVED DATA")
            if !self.initalizedWorldMap {
                print("IN INIT")
                if let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) {
                    // Run the session with the received world map.
                    let configuration = ARWorldTrackingConfiguration()
                    guard let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: "gallery", bundle: nil) else {
                        fatalError("Missing expected asset catalog resources.")
                    }
                    configuration.detectionObjects = referenceObjects
                    configuration.planeDetection = [.horizontal, .vertical]
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
                    if lineNode?.name == "tutorial" {
                        self.buildingCounter += 1
                        
                        //boxNode.physicsBody?.categoryBitMask = SCNPhysicsCollisionCategory.
                        self.lastBuiltNode!.parent!.addChildNode(lineNode!)
                        self.lastBuiltNode = lineNode
                    }else{
                        self.sceneView.scene.rootNode.addChildNode(lineNode!)
                    }
                    
                    print("Added node to screen")
                }else if let boxAnchor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARAnchor.self, from: data) {
                    sceneView.session.add(anchor: boxAnchor!)
                }else if let _ = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARObjectAnchor.self, from: data){
                    //probably wont need this if statement...
                    //sceneView.session.add(anchor: obj)
                    print("WE WERENT SUPPOSED TO BE HERE BUT WE HERE BOI MULTIPEER AROBJECTANCHOR!!!")
                }else if let actions = try? NSKeyedUnarchiver.unarchivedObject(ofClass: SCNAction.self, from: data){
                    print("Got Actions")
                    self.pipeNode?.runAction(actions!)
                } else{
                    print("unknown data recieved from \(peer)")
                }
        } catch {
            print("can't decode data recieved from \(peer). Was probably lines")
        }
    }
}
