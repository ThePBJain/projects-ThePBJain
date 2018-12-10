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

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    //scene requirements
    @IBOutlet var sceneView: ARSCNView!
    var planes : [ARPlaneAnchor] = []
    
    //line generation and object setup
    var object : MDLMesh!
    var buttonPressed = false
    var previousPoint: SCNVector3?
    
    //buttons
    @IBOutlet weak var shareMapButton: UIButton!
    @IBOutlet weak var drawLineButton: UIButton!
    @IBOutlet weak var switchModelButton: UIButton!
    
    //Model Tools
    var modelName = "box"
    let lineColor = UIColor.red
    
    //Multipeer tools
    var multipeerSession: MultipeerSession!
    var initalizedWorldMap: Bool = false
    var isServer = true
    var hasSent = false
    
    //Download Model Tools
    var internetModelString = "http://nuntagri.com/Fighter.obj"
    var documentsUrl : URL?
    
    
    /// Marks if the AR experience is available for restart.
    var isRestartAvailable = true
    
    /// The view controller that displays the status and "restart experience" UI.
    //taken from apple's best practices guide for arkit: https://developer.apple.com/documentation/arkit/handling_3d_interaction_and_ui_controls_in_augmented_reality
    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.multipeerSession = MultipeerSession(receivedDataHandler: receivedData)
        
        // Set the view's delegate
        self.sceneView.delegate = self
        self.sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        self.sceneView.showsStatistics = true
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]//[ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
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
        
        //let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapped(recognizer:)))
        //sceneView.addGestureRecognizer(tap)
        
        configureLighting()
        guard let newModel = URL(string: self.internetModelString) else { fatalError() }
        var documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        documentsUrl!.appendPathComponent("1.obj")
        self.documentsUrl = documentsUrl
        Downloader.load(url: newModel, to: documentsUrl!) {
            /*let mdlAsset = MDLAsset(url: documentsUrl!)
            //MDLObject()
            mdlAsset.object(at: 0)
            
            let node = SCNNode(mdlObject: mdlAsset.object(at: 0))
            
            node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            node.physicsBody?.mass = 2.0
            self.sceneView.scene.rootNode.addChildNode(node)*/
            
        }
        //set switch
        self.switchModelButton.setTitle("bob", for: .normal)
        
        
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    func restartExperience() {
        guard isRestartAvailable else { return }
        isRestartAvailable = false
        
        statusViewController.cancelAllScheduledMessages()
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        if #available(iOS 12.0, *) {
            configuration.environmentTexturing = .automatic
        }
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        statusViewController.scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT", inSeconds: 7.5, messageType: .planeEstimation)
        
        // Disable restart for a while in order to give the session time to restart.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.isRestartAvailable = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        // Run the view's session
        self.sceneView.session.run(configuration)
        statusViewController.scheduleMessage("TRY MOVING LEFT OR RIGHT", inSeconds: 5.0, messageType: .focusSquare)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        self.sceneView.session.pause()
    }
    
    // MARK: - Switch Models
    
    
    @IBAction func switchModel(_ sender: Any) {
        if self.modelName == "box" {
            //model is currently "box"
            self.modelName = "internet"
            self.switchModelButton.setTitle("Use Box", for: .normal)
        }else{
            //model is currently "internet"
            self.modelName = "box"
            self.switchModelButton.setTitle("Use Other", for: .normal)
        }
    }
    

    // MARK: - ARSCNViewDelegate
    

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update only anchors and nodes set up by `renderer(_:didAdd:for:)`.
        guard let planeAnchor = anchor as? ARPlaneAnchor,
            let plane = node.childNodes.first as? Plane
            else { return }
        
        plane.update(planeAnchor)
        
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
        if let name = anchor.name, name.hasPrefix("box") {
            
            let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
            //let mdlAsset = MDLAsset(url: documentsUrl!)
            //let box = SCNGeometry(mdlMesh: mdlAsset.object(at: 0) as! MDLMesh)
            let mat = SCNMaterial()
            mat.diffuse.contents = UIColor.red
            //mat.lightingModel = .lambert
            box.materials = [mat]
            let boxNode = SCNNode(geometry: box)
            //boxNode.simdTransform = anchor.transform
            boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            boxNode.physicsBody?.mass = 2.0
            boxNode.simdWorldTransform = anchor.transform
            
            //boxNode.physicsBody?.categoryBitMask = SCNPhysicsCollisionCategory.
            //self.sceneView.scene.rootNode.addChildNode(boxNode)
            node.addChildNode(boxNode)
        }else if let name = anchor.name, name.hasPrefix("internet") {
            
            let mdlAsset = MDLAsset(url: documentsUrl!)
            let internetObject = SCNGeometry(mdlMesh: mdlAsset.object(at: 0) as! MDLMesh)
            let mat = SCNMaterial()
            mat.diffuse.contents = UIColor.red
            internetObject.materials = [mat]
            let internetNode = SCNNode(geometry: internetObject)
            //boxNode.simdTransform = anchor.transform
            internetNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            internetNode.physicsBody?.mass = 2.0
            internetNode.simdWorldTransform = anchor.transform
            
            //boxNode.physicsBody?.categoryBitMask = SCNPhysicsCollisionCategory.
            node.addChildNode(internetNode)
        }else if let planeAnchor = anchor as? ARPlaneAnchor {
            // Place content only for anchors found by plane detection.
            self.statusViewController.cancelScheduledMessage(for: .planeEstimation)
            self.statusViewController.showMessage("SURFACE DETECTED")
            // Create a custom object to visualize the plane geometry and extent.
            let plane = Plane(anchor: planeAnchor, in: sceneView)
            
            // Add the visualization to the ARKit-managed node so that it tracks
            // changes in the plane anchor as plane estimation continues.
            node.addChildNode(plane)
        }
        
    }
    
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        if let planeAnchor = anchor as? ARPlaneAnchor {
            planes.append(planeAnchor)
            
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
    @IBAction func tapped(recognizer :UITapGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(touchLocation, options: [:])
        
        // Hit test to find a place for a virtual object.
        /*guard let hitTestResult = sceneView
            .hitTest(recognizer.location(in: sceneView), types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane])
            .first
            else { return }*/
        if !hitResults.isEmpty{
            // Place an anchor for a virtual character. The model appears in renderer(_:didAdd:for:).
            let hitPosition = hitResults[0].worldCoordinates
            
            let matrix = SCNMatrix4Translate(SCNMatrix4Identity, hitPosition.x , hitPosition.y, hitPosition.z)
            
            let simd_matrix = simd_float4x4(matrix)
            let anchor = ARAnchor(name: self.modelName, transform: simd_matrix)
            self.sceneView.session.add(anchor: anchor)
            
            // Send the anchor info to peers, so they can place the same content.
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true)
                else { fatalError("can't encode anchor") }
            //self.multipeerSession.send(data, to: [mapProvider!])
            self.multipeerSession.sendToAllPeers(data)
            print("Peers#: \(self.multipeerSession.connectedPeers.count)")
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
                let anchor = ARAnchor(name: "line", transform: hitTestResult.worldTransform)
                sceneView.session.add(anchor: anchor)*/
                // Send the anchor info to peers, so they can place the same content.
                if !self.multipeerSession.connectedPeers.isEmpty{
                    guard let data = try? NSKeyedArchiver.archivedData(withRootObject: lineNode, requiringSecureCoding: true)
                        else { fatalError("can't encode anchor") }
                    self.multipeerSession.sendToAllPeers(data)
                }
                
            }
        }
        previousPoint = currentPosition
    }
    func midpoint(first: SCNVector3, second: SCNVector3) -> SCNVector3 {
        return SCNVector3Make((first.x + second.x) / 2, (first.y + second.y) / 2, (first.z + second.z) / 2)
    }
    
    func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNNode {
        //switch this to anchors
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
    
    var mapProvider: MCPeerID?
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
