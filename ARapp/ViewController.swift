//
//  ViewController.swift
//  ARapp
//
//  Created by Admin on 30/4/2563 BE.
//  Copyright © 2563 Admin. All rights reserved.
//

import ARKit
import SceneKit
import UIKit

class ViewController: UIViewController {

    //var contentNode: SCNNode?
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var tabBar: UITabBar!
    
    let faceOptions = ["look3","look4","look5","look6"]
    let features = ["face"]
    var featureIndices = [[6]]
    
    /*private var originalJawY: Float = 0
    
    private lazy var jawNode = contentNode!.childNode(withName: "jaw", recursively: true)!
    private lazy var eyeLeftNode = contentNode!.childNode(withName: "eyeLeft", recursively: true)!
    private lazy var eyeRightNode = contentNode!.childNode(withName: "eyeRight", recursively: true)!
    
    private lazy var jawHeight: Float = {
        let (min, max) = jawNode.boundingBox
        return max.y - min.y
    }()*/
    
    override func viewDidLoad() {
            super.viewDidLoad()

            guard ARFaceTrackingConfiguration.isSupported else {
                fatalError("Face tracking is not supported on this device")
            }
            
            sceneView.delegate = self
        }
        
        override func viewWillAppear(_ animated: Bool) {
               super.viewWillAppear(animated)
           
               let configuration = ARFaceTrackingConfiguration()
               sceneView.session.run(configuration)
           }
           
           override func viewWillDisappear(_ animated: Bool) {
               super.viewWillAppear(animated)
               
               sceneView.session.pause()
           }
    
        @IBAction func Touch(_ sender: UITapGestureRecognizer) {
            let location = sender.location(in: sceneView)
            let result = sceneView.hitTest(location, options: nil)
            if let result = result.first,let node = result.node as? FaceNode {
                node.next()
            }
        }
        
        func updateFeatures(for node: SCNNode, using anchor: ARFaceAnchor) {
            print(featureIndices)
            for (feature, indices) in zip(features, featureIndices) {
                let child = node.childNode(withName: feature, recursively: false) as? FaceNode
                let vertices = indices.map { anchor.geometry.vertices[$0] }
                child?.updatePosition(for: vertices)
            }
        }
}


extension ViewController : ARSCNViewDelegate{
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let  device : MTLDevice!
        device = MTLCreateSystemDefaultDevice()
        guard let faceAnchor = anchor as? ARFaceAnchor else {
                   return nil
        }
        let faceGeometry = ARSCNFaceGeometry(device:device)
        let node = SCNNode(geometry: faceGeometry)
        //node.geometry?.firstMaterial?.fillMode = .lines
        node.geometry?.firstMaterial?.transparency = 0
        
        let faceNode = FaceNode(with: faceOptions)
        faceNode.name = "face"
        node.addChildNode(faceNode)
        
        updateFeatures(for: node, using: faceAnchor)
        
        return node
        
    }
    
    func  renderer (
        _ renderer: SCNSceneRenderer ,
        didUpdate node: SCNNode,
        for anchor: ARAnchor){
            
        guard  let faceAnchor = anchor as? ARFaceAnchor,
            let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
                return
        }
            
        faceGeometry.update(from: faceAnchor.geometry)
        updateFeatures(for: node, using: faceAnchor)
        
    }
    
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


