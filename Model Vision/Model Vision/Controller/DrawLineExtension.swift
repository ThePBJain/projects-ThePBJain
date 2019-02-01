//
//  DrawLineExtension.swift
//  Model Vision
//
//  Created by Pranav Jain on 1/4/19.
//  Copyright © 2019 Pranav Jain. All rights reserved.
//

import Foundation
import SceneKit

extension ViewController {
    // MARK: - Drawing Lines
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.buttonPressed = self.drawLineButton.isHighlighted
        }
    }
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        guard let pointOfView = sceneView.pointOfView else { return }
        
        let mat = pointOfView.transform
        //TODO: explain how you convert World to camera coords
        // Cam coords = R*C*(worldcoords) (matrix multiplication)
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
        //TODO: Describe the matrix transforms to get this done (right hand rule)
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
}
