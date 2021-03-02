//
//  ExampleApp.swift
//  Example
//
//  Created by 안창범 on 2021/02/26.
//

import SwiftUI
import Open3DSupport
import NumPySupport
import PythonSupport
import PythonKit
import SceneKit

@main
struct ExampleApp: App {
    let pcd: PythonObject
    
    var scene: SCNScene? = nil
    
    var body: some Scene {
        WindowGroup {
            SceneView(scene: scene, options: [.allowsCameraControl])
        }
    }
    
    init() {
        PythonSupport.initialize()
        Open3DSupport.sitePackagesURL.insertPythonPath()
        NumPySupport.sitePackagesURL.insertPythonPath()

        let o3d = Python.import("open3d")
        let np = Python.import("numpy")

        let url = Bundle.main.url(forResource: "fragment", withExtension: "ply")!
        pcd = o3d.io.read_point_cloud(url.path)
        print(pcd)
        print(np.asarray(pcd.points))
        
        scene = makeScene()
        
        let points = np.asarray(pcd.points)
        print(points, pcd.get_max_bound(), pcd.get_min_bound())
        
        let vertices = points.map { point in
            SCNVector3(Float(point[0])!, Float(point[1])!, Float(point[2])!) }
        let geometrySource = SCNGeometrySource(vertices: vertices)
        let indices: [CInt] = Array(0..<CInt(vertices.count))
        let geometryElement = SCNGeometryElement(indices: indices, primitiveType: .point)
        let geometry = SCNGeometry(sources: [geometrySource], elements: [geometryElement])
        let node = SCNNode(geometry: geometry)
        scene?.rootNode.addChildNode(node)
        
//        let zoom = 0.3412
        let front = simd_normalize(simd_float3(0.4257, -0.2125, -0.8795))
        let lookAt = simd_float3(2.6172, 2.0475, 1.532)
        let up = simd_float3(-0.0694, -0.9768, 0.2024)
        
//        let right = simd_normalize(simd_cross(up, front))
//        up = simd_normalize(simd_cross(front, right))
        let distance: Float = 3
        let eye = lookAt + front * distance
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene?.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(eye)
        cameraNode.look(at: SCNVector3(lookAt), up: SCNVector3(up), localFront: SCNVector3(front))
    }
    
    func makeScene() -> SCNScene {
        let scene = SCNScene()
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        return scene
    }
}
