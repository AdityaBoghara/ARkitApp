//
//  ViewController.swift
//  ARkitApp
//
//  Created by Aditya Boghara on 1/6/24.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var diceArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
//        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        
//        let sphere = SCNSphere(radius: 0.20)
//        
//        let material = SCNMaterial()
//        
//        material.diffuse.contents = UIImage(named: "art.scnassets/8k_moon.jpg")
//        
//        sphere.materials = [material]
//        
//        let node =  SCNNode()
//        
//        node.position = SCNVector3(x: 0, y: 0.1, z: -0.75)
//        
//        node.geometry = sphere
//        sceneView.scene.rootNode.addChildNode(node)
        
        
        
        
        sceneView.autoenablesDefaultLighting = true
        
        //Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true){
            
            diceNode.position = SCNVector3(x: 0, y: 0, z: -0.1)
            
            sceneView.scene.rootNode.addChildNode(diceNode)
        }
        
        // Set the scene to the view
//        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            
            let touchLocation  = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation,types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                
                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                    
                    diceNode.position = SCNVector3(
                        x: hitResult.worldTransform.columns.3.x,
                        y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                        z: hitResult.worldTransform.columns.3.z
                    )
                    
                    diceArray.append(diceNode)
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    
                    roll(dice: diceNode)
                    
                }
                
                
            }
            
            
            
        }
    }
    
    
    func rollAll() {
        
        if !diceArray.isEmpty {
            for dice in diceArray{
                
                roll(dice:dice)
            }
        }
        
    }
    
    
    func roll(dice: SCNNode) {
        
        let randomX = Float((arc4random_uniform(4) + 1)) * (Float.pi/2)
        //        let randomY = Double((arc4random_uniform(10) + 11)) * (Double.pi/2)
        let randomZ = Float((arc4random_uniform(4) + 1)) * (Float.pi/2)
        
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 5), y: 0, z: CGFloat(randomZ * 5), duration: 0.5))
        
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        
        rollAll()
        
        
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    
    @IBAction func removeAll(_ sender: UIBarButtonItem) {
        
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
            
        }
        
        
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //to detect the horizontal plane
        
        if anchor is ARPlaneAnchor {
                    
                    print("plane detected")
                    
                    let planeAnchor = anchor as! ARPlaneAnchor

            let plane = SCNPlane(width: CGFloat(planeAnchor.planeExtent.width), height: CGFloat(planeAnchor.planeExtent.height))
                    
                    let gridMaterial = SCNMaterial()
                    gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
                    plane.materials = [gridMaterial]
                    
                    let planeNode = SCNNode()

                    planeNode.geometry = plane
                    planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
                    planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
                    
                    node.addChildNode(planeNode)
                    
                } else {
                    return
                }
        
        
        
    }

    
}
