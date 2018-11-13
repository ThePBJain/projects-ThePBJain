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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Load the .OBJ file
        guard let url = Bundle.main.url(forResource: "Fighter", withExtension: "obj", subdirectory: "art.scnassets/xwing") else {
            fatalError("Failed to find model file.")
        }
        /*guard let url = Bundle.main.url(forResource: "Fighter", withExtension: "obj") else {
            fatalError("Failed to find model file.")
        }*/
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
        
        let node = SCNNode(mdlObject: object)
        
        /*let session = ARSession()
        guard let cameraTransform = session.currentFrame?.camera.transform else {
                return
        }
        node.position = SCNVector3.positionFromTransform(cameraTransform)*/
        let scene = SCNScene()
        scene.rootNode.addChildNode(node)
        
        // Set up the SceneView
        sceneView.autoenablesDefaultLighting = true
        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.black
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
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
