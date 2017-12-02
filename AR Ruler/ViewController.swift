//
//  ViewController.swift
//  AR Ruler
//
//  Created by Ryan Wittrup on 12/2/17.
//  Copyright © 2017 Ryan Wittrup. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.autoenablesDefaultLighting = true
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
        }
    }
    
    func addDot(at hitResult: ARHitTestResult) -> Void {
        let dotGeometry = SCNSphere(radius: 0.005)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3Make(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y + dotGeometry.boundingSphere.radius,
            hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculateDistance()
        }
    }
    
    func calculateDistance() -> Void {
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        print(start.position)
        print(end.position)
        
        let xDelta = start.position.x - end.position.y
        let yDelta = start.position.y - end.position.y
        let zDelta = start.position.z - end.position.z
        let distance = sqrt(pow(xDelta, 2) + pow(yDelta, 2) + pow(zDelta, 2))
        
        updateText(text: "\(distance)", atPosition: end.position)
    }
    
    func updateText(text: String, atPosition position: SCNVector3) -> Void {
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3Make(position.x, position.y + 0.05, position.z)
        textNode.scale = SCNVector3Make(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
}
