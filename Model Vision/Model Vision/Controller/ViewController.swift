//
//  ViewController.swift
//  Model Vision
//
//  Created by Pranav Jain on 11/4/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import UIKit
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
    
    //MARK: - Variables
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
    var mapProvider: MCPeerID?
    
    //Download Model Tools
    var internetModelString = "http://nuntagri.com/Lowpoly_Notebook_2.obj"
    var documentsUrl : URL?
    
    
    /// Marks if the AR experience is available for restart.
    var isRestartAvailable = true
    
    var classifier : Classification!
    
    //Pilot Brain
    var goalNode : SCNNode?
    var brain : PilotBrain?
    var drone : SCNNode?
    
    /// The view controller that displays the status and "restart experience" UI.
    //taken from apple's best practices guide for arkit: https://developer.apple.com/documentation/arkit/handling_3d_interaction_and_ui_controls_in_augmented_reality
    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    
    //MARK: - Main Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup Classifier
        self.classifier = Classification(statusController: self.statusViewController)
        
        //setup multipeer connectivity
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
        
        
        configureLighting()
        //TODO: Talk about this and show downloader (Why these models are hard to import)
        guard let newModel = URL(string: self.internetModelString) else { fatalError() }
        var documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        documentsUrl!.appendPathComponent("1.obj")
        self.documentsUrl = documentsUrl
        Downloader.load(url: newModel, to: documentsUrl!) {
            print("Loaded Document!")
            
        }
        //set switch
        self.switchModelButton.setTitle("Use Drone", for: .normal)
        
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
        guard let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: "gallery", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        configuration.detectionObjects = referenceObjects
        configuration.planeDetection = [.horizontal, .vertical]
        if #available(iOS 12.0, *) {
            configuration.environmentTexturing = .automatic
        }
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        //remove draw lines
        self.sceneView.scene.rootNode.enumerateChildNodes{ (child, _) in
            child.removeFromParentNode()
            
        }
        statusViewController.scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT", inSeconds: 7.5, messageType: .planeEstimation)
        
        // Disable restart for a while in order to give the session time to restart.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.isRestartAvailable = true
        }
        //TODO: send the reset to peers somehow
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        guard let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: "gallery", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        configuration.detectionObjects = referenceObjects
        configuration.planeDetection = [.horizontal, .vertical]
        // Run the view's session
        self.sceneView.session.run(configuration)
        statusViewController.scheduleMessage("TRY MOVING LEFT OR RIGHT", inSeconds: 5.0, messageType: .focusSquare)
         print("ROOTNODE WORLD POS: \(self.sceneView.scene.rootNode.worldPosition)")
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
            self.modelName = "drone"
            self.switchModelButton.setTitle("Use Other", for: .normal)
        }else if self.modelName == "drone" {
            self.modelName = "internet"
            self.switchModelButton.setTitle("Use Box", for: .normal)
        }else{
            //model is currently "internet"
            self.modelName = "box"
            self.switchModelButton.setTitle("Use Drone", for: .normal)
        }
        
    }
    
    func extraModelGeneration(){
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
    }
    
    // MARK: - PilotBrain loop and ARSCNViewDelegate
    var prevVelocity : SCNVector3?
    var prevTime : TimeInterval?
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        if let droneNode = self.drone {
            //print("found drone")
            if let pilotBrain = self.brain {
                if let goalNode = self.goalNode {
                    
                    //update data
                    //double check this
                    self.brain!.droneLocation = SCNVector3Zero
                    //self.brain!.droneLocation = droneNode.presentation.worldPosition
                    let goalLoc = droneNode.presentation.convertPosition(goalNode.worldPosition, from: self.sceneView.scene.rootNode)
                    self.brain!.goalLocation = goalLoc
                    //self.brain!.goalLocation = goalNode.worldPosition
                    let eulerAnglesInDegrees = droneNode.presentation.eulerAngles * (180.0/Float.pi)
                    self.brain!.droneRotation = eulerAnglesInDegrees
                    let currentVelocity = droneNode.physicsBody!.velocity
                    self.brain!.droneVelocity = currentVelocity
                    let angularVelocity = droneNode.physicsBody!.angularVelocity
                    let angularMagnitudeInDeg = angularVelocity.w * (180.0/Float.pi)
                    self.brain!.droneAngleVelocity = SCNVector3(angularVelocity.x, angularVelocity.y, angularVelocity.z)*angularMagnitudeInDeg
                    //droneNode.physicsBody!.angularVelocity
                    //droneNode.position
                    //droneNode.presentation.position
                    
                    self.brain!.droneAcceleration = (currentVelocity - (self.prevVelocity ?? SCNVector3Zero))/Float(time - (self.prevTime ?? 0.0))
                    self.prevTime = time
                    self.prevVelocity = droneNode.physicsBody!.velocity
                    
                    //print("Physics:\nVelocity:\(droneNode.physicsBody!.velocity)\nAngular Velocity:\(droneNode.physicsBody!.angularVelocity)")
                    //print("Drone Presentation Location: \(droneNode.presentation.position)")
                    //print("Input Values in Session: \(goalLoc)")
                    
                    let newForces = self.brain!.getDroneVectors()
                    
                    droneNode.physicsBody!.clearAllForces()
                    print("------------")
                    print(newForces)
                    for i in 0...3 {
                        let force = newForces[i]
                        //Double(exactly: force)! * 40.0
                        let finalForce = self.clamp( Double(exactly: force)! * 20.0, minValue: 0.0, maxValue: 20.0)
                        
                        print(finalForce)
                        let thruster = self.brain!.thrusters[2*i]
                        //droneNode.rotation
                        //assume applyforce is local
                        let forceVector = SCNVector3(0, finalForce, 0)
                        //assume applyforce is world
                        let thrustVector = droneNode.presentation.convertVector(forceVector, to: self.sceneView.scene.rootNode)
                        //print("Thrust vector: \(thrustVector)")
                        droneNode.physicsBody!.applyForce(thrustVector, at: thruster.position, asImpulse: false)
                        //pilotBrain.droneAcceleration += forceVector
                        
                    }
                    
                }
                
            }
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
    //adding anchors and nodes
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let objectAnchor = anchor as? ARObjectAnchor {
            let referenceObj = objectAnchor.referenceObject
            let scale = CGFloat(referenceObj.scale.x)
            //TODO: make it so that this adding is sent to peers
            node.addChildNode(DetectedBoundingBox(points: referenceObj.rawFeaturePoints.points, scale: scale))
            self.goalNode = node
        }
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
            //mat.colorBufferWriteMask = []
            //mat.isDoubleSided = true
            internetObject.materials = [mat]
            let internetNode = SCNNode(geometry: internetObject)
            //boxNode.simdTransform = anchor.transform
            internetNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            internetNode.physicsBody?.mass = 2.0
            internetNode.simdWorldTransform = anchor.transform
            
            //boxNode.physicsBody?.categoryBitMask = SCNPhysicsCollisionCategory.
            node.addChildNode(internetNode)
        }else if let name = anchor.name, name.hasPrefix("drone") {
            
            guard let url = Bundle.main.url(forResource: "liteDrone", withExtension: "obj", subdirectory: "art.scnassets") else {
                fatalError("Failed to find model file.")
            }
            let mdlAsset = MDLAsset(url: url)
            let droneObject = SCNGeometry(mdlMesh: mdlAsset.object(at: 0) as! MDLMesh)
            let mat = SCNMaterial()
            mat.diffuse.contents = UIColor.white
            //mat.colorBufferWriteMask = []
            //mat.isDoubleSided = true
            droneObject.materials = [mat]
            let droneNode = SCNNode(geometry: droneObject)
            //boxNode.simdTransform = anchor.transform
            droneNode.simdWorldTransform = anchor.transform
            
            droneNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            droneNode.physicsBody?.isAffectedByGravity = true
            //self.goalNode?.position
            self.brain = PilotBrain(droneLocation: droneNode.worldPosition, goalLocation: (self.goalNode?.worldPosition ?? SCNVector3Zero))
            //droneNode.physicsBody?.applyForce(SCNVector3(0, 3, 0), asImpulse: false)
            droneNode.physicsBody?.mass = 1.0
            
            let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
            let matNew = SCNMaterial()
            matNew.diffuse.contents = UIColor.red
            box.materials = [matNew]
            for i in 0...3 {
                let thruster = SCNNode(geometry: box)
                thruster.position = self.brain!.thrusters[2*i].position
                droneNode.addChildNode(thruster)
            }
            self.drone = droneNode
            //boxNode.physicsBody?.categoryBitMask = SCNPhysicsCollisionCategory.
            node.addChildNode(droneNode)
        }else if let planeAnchor = anchor as? ARPlaneAnchor {
            // Place content only for anchors found by plane detection.
            //self.statusViewController.cancelScheduledMessage(for: .planeEstimation)
            //self.statusViewController.showMessage("SURFACE DETECTED")
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
    
    
    
    // MARK: - Hit Test detection
    //TODO: Talk about this
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
    
    
}
