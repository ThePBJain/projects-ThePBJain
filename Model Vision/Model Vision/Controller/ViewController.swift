//
//  ViewController.swift
//  Model Vision
//
//  Created by Pranav Jain on 11/4/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import ModelIO
import SceneKit.ModelIO
import MultipeerConnectivity

extension MDLMaterial {
    func setTextureProperties(_ textures: [MDLMaterialSemantic:String]) -> Void {
        for (key,value) in textures {
            guard let url = Bundle.main.url(forResource: value, withExtension: "") else {
                fatalError("Failed to find URL for resource \(value).")
            }
            let property = MDLMaterialProperty(name:value, semantic: key, url: url)
            self.setProperty(property)
        }
    }
}

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var planes : [ARPlaneAnchor] = []
    var object : MDLMesh!
    var setup = false
    var buttonPressed = false
    var previousPoint: SCNVector3?
    @IBOutlet weak var drawLineButton: UIButton!
    let lineColor = UIColor.red
    
    var multipeerSession: MultipeerSession!
    var initalizedWorldMap: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.multipeerSession = MultipeerSession(receivedDataHandler: receivedData)
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]//[ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        // Load the .OBJ file
        guard let url = Bundle.main.url(forResource: "Fighter", withExtension: "obj", subdirectory: "art.scnassets/xwing") else {
            fatalError("Failed to find model file.")
        }
        let asset = MDLAsset(url:url)
        guard let object = asset.object(at: 0) as? MDLMesh else {
            fatalError("Failed to get mesh from asset.")
        }
        // Create a material from the various textures
        let scatteringFunction = MDLScatteringFunction()
        let material = MDLMaterial(name: "baseMaterial", scatteringFunction: scatteringFunction)
        
        material.setTextureProperties([
            .baseColor:"art.scnassets/xwing/textures/Fighter_Diffuse_25.jpg",
            .specular:"art.scnassets/xwing/textures/Fighter_Specular_25.jpg",
            .emission:"art.scnassets/xwing/textures/Fighter_Illumination_25.jpg"])
        
        // Apply the texture to every submesh of the asset
        for  submesh in object.submeshes!  {
            if let submesh = submesh as? MDLSubmesh {
                submesh.material = material
            }
        }
        
        // Wrap the ModelIO object in a SceneKit object
        self.object = object
        /*let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor.red
        box.materials = [mat]
        let boxNode = SCNNode(geometry: box)
        boxNode.position = SCNVector3(0,0,-0.5)
        self.sceneView.scene.rootNode.addChildNode(boxNode)*/
        
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    

    // MARK: - ARSCNViewDelegate
    

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update only anchors and nodes set up by `renderer(_:didAdd:for:)`.
        guard let planeAnchor = anchor as? ARPlaneAnchor,
            let plane = node.childNodes.first as? Plane
            else { return }
        
        // Update ARSCNPlaneGeometry to the anchor's new estimated shape.
        if let planeGeometry = plane.meshNode.geometry as? ARSCNPlaneGeometry {
            planeGeometry.update(from: planeAnchor.geometry)
        }
        
        // Update extent visualization to the anchor's new bounding rectangle.
        if let extentGeometry = plane.extentNode.geometry as? SCNPlane {
            extentGeometry.width = CGFloat(planeAnchor.extent.x)
            extentGeometry.height = CGFloat(planeAnchor.extent.z)
            plane.extentNode.simdPosition = planeAnchor.center
        }
        
        // Update the plane's classification and the text position
        if #available(iOS 12.0, *),
            let classificationNode = plane.classificationNode,
            let classificationGeometry = classificationNode.geometry as? SCNText {
            let currentClassification = "\(planeAnchor.classification)"
            if let oldClassification = classificationGeometry.string as? String, oldClassification != currentClassification {
                classificationGeometry.string = currentClassification
                classificationNode.centerAlign()
            }
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Create a custom object to visualize the plane geometry and extent.
        let plane = Plane(anchor: planeAnchor, in: sceneView)
        
        // Add the visualization to the ARKit-managed node so that it tracks
        // changes in the plane anchor as plane estimation continues.
        node.addChildNode(plane)
    }
    
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        if let planeAnchor = anchor as? ARPlaneAnchor {
            planes.append(planeAnchor)
            if !setup {
                self.setup = true
                //self.addNode()
            }
            
        }
        return node
    }
    
    func addNode(){
        let node = SCNNode(mdlObject: self.object)
        node.position = SCNVector3.positionFromTransform(planes[0].transform)
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    //MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        switch frame.worldMappingStatus {
        case .notAvailable, .limited:
            print("unavaliable")
        case .extending:
            if !multipeerSession.connectedPeers.isEmpty {
                self.shareSession()
            }
        case .mapped:
            if !multipeerSession.connectedPeers.isEmpty {
                self.shareSession()
            }
        }
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
    
    // MARK: - Hit Test detection
    @objc func tapped(recognizer :UITapGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(touchLocation, options: [:])
        if !hitResults.isEmpty {
            // this means the node has been touched
        }
    }
    
    // MARK: - Drawing Lines
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.buttonPressed = self.drawLineButton.isHighlighted
        }
    }
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        guard let pointOfView = sceneView.pointOfView else { return }
        
        let mat = pointOfView.transform
        let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
        let currentPosition = pointOfView.position + (dir * 0.1)
        
        if self.buttonPressed {
            if let previousPoint = previousPoint {
                let lineNode = lineFrom(vector: previousPoint, toVector: currentPosition)
                //lineNode.position = midpoint(first: previousPoint, second: currentPosition)
                sceneView.scene.rootNode.addChildNode(lineNode)
                /*guard let hitTestResult = sceneView
                    .hitTest(sceneView.center, types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane])
                    .first
                    else { return }
                let anchor = sceneView.anchor(for: lineNode)*/
                
                // Send the anchor info to peers, so they can place the same content.
                guard let data = try? NSKeyedArchiver.archivedData(withRootObject: lineNode, requiringSecureCoding: true)
                    else { fatalError("can't encode anchor") }
                self.multipeerSession.sendToAllPeers(data)
                
            }
        }
        previousPoint = currentPosition
    }
    func midpoint(first: SCNVector3, second: SCNVector3) -> SCNVector3 {
        return SCNVector3Make((first.x + second.x) / 2, (first.y + second.y) / 2, (first.z + second.z) / 2)
    }
    
    func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNNode {
        
        let cyl = SCNCylinder(radius: 0.002, height: CGFloat(vector1.distance(to: vector2)))
        //return SCNGeometry(sources: [source], elements: [element])
        let lineNode = SCNNode(geometry: cyl)
        //lineNode.position = midpoint(first: previousPoint, second: currentPosition)
        let distDiff = vector2 - vector1
        let height = distDiff.length()
        let y = distDiff.normalized()
        let up = distDiff.cross(vector2).normalized()
        let x = y.cross(up).normalized()
        let z = x.cross(y).normalized()
        
        /* Matrix transform
         x.x  x.y  x.z  0
         y.x  y.y  y.z  0
         z.x  z.y  z.z  0
         w.x  w.y  w.z  1
         */
        let transform = SCNMatrix4(m11: x.x, m12: x.y, m13: x.z, m14: 0.0, m21: y.x, m22: y.y, m23: y.z, m24: 0.0, m31: z.x, m32: z.y, m33: z.z, m34: 0.0, m41: vector1.x, m42: vector1.y, m43: vector1.z, m44: 1.0)
        lineNode.transform = SCNMatrix4Mult(SCNMatrix4MakeTranslation(0.0, height / 2.0, 0.0), transform)
        lineNode.geometry?.firstMaterial?.diffuse.contents = lineColor
        return lineNode
        
    }
    
    //MARK: - Multipeer functions
    
    /// - Tag: GetWorldMap
    func shareSession() {
        sceneView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap
                else { print("Error: \(error!.localizedDescription)"); return }
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                else { fatalError("can't encode map") }
            self.multipeerSession.sendToAllPeers(data)
            self.initalizedWorldMap = true
        }
    }
    var mapProvider: MCPeerID?
    /// - Tag: ReceiveData
    func receivedData(_ data: Data, from peer: MCPeerID) {
        
        do {
            if !self.initalizedWorldMap {
                if let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) {
                    // Run the session with the received world map.
                    let configuration = ARWorldTrackingConfiguration()
                    configuration.planeDetection = .horizontal
                    configuration.initialWorldMap = worldMap
                    sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
                    
                    // Remember who provided the map for showing UI feedback.
                    mapProvider = peer
                    self.initalizedWorldMap = true
                    
                }
            }
            else
                if let lineNode = try NSKeyedUnarchiver.unarchivedObject(ofClass: SCNNode.self, from: data) {
                    // Add anchor to the session, ARSCNView delegate adds visible content.
                    //sceneView.session.add(anchor: anchor)
                    sceneView.scene.rootNode.addChildNode(lineNode)
                }
                else {
                    print("unknown data recieved from \(peer)")
            }
        } catch {
            print("can't decode data recieved from \(peer)")
        }
    }
}
