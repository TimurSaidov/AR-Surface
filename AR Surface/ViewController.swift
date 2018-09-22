//
//  ViewController.swift
//  AR Surface
//
//  Created by Timur Saidov on 19.09.2018.
//  Copyright © 2018 Timur Saidov. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        sceneView.debugOptions = [
            ARSCNDebugOptions.showWorldOrigin,
            ARSCNDebugOptions.showFeaturePoints] // Желтые точки - точки, по которым можно строить модель окружающего пространства и отслеживать положение устройства. Т.е. эти точки просто показывают, есть ли поверхность или нет, не определяют ее. Т.о. желтая точка - это точка, определенная на разных кадрах, как одна и та же точка (То есть камера - это глаз. Он смотрит на точку на одном кадре, затем он смотрит на эту же самую точку на другом кадре, с другого угла). И засчет этого определяется, насколько поверхность сдвинулась при изменение кадра.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = [.horizontal] // То есть теперь приложение не только генерирует точки, но и, если достаточное кол-во точек попадает на одну поверхность, определяет ее. Распознавание плоскости. Найденный объект (распознанный) anchor попадает в метод renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor).

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // Отображение поверхности (плоскости).
    func createPlane(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let width = CGFloat(planeAnchor.extent.x)
        let heigth = CGFloat(planeAnchor.extent.z)
        
        let geometry = SCNPlane(width: width, height: heigth)
        
        let boxNode = SCNNode() // Node is a structural element of a scene graph, representing a position and transform in a 3D coordinate space, to which you can attach geometry, lights, cameras, or other displayable content. То есть node - трехмерная система координат.
        boxNode.position = SCNVector3(0, 0, 0.05)
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = UIColor.red
        boxNode.geometry = box
        
        let planeNode = SCNNode()
        planeNode.geometry = geometry
        planeNode.opacity = 0.25
        planeNode.eulerAngles.x = -Float.pi / 2
        
        planeNode.addChildNode(boxNode)
        
        return planeNode
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return } // Если произошло распознование, определяем, что за сущность распознана. Кастим ее до поверхности. Если кастится, то распознана плоскость. Помимо этого есть еще распознование объекта и картинки.
        
        print(#function, planeAnchor)
        
        let plane = createPlane(planeAnchor: planeAnchor) // Визуализация распознанной поверхности.
        
        node.addChildNode(plane) // node, переданная функции, закреплена так, где распознана поверхность, в ее центре. И в ней визуализируется поверхность. То есть planeNode совпадает с node.
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Вызывается в тот момент, когда 2 плоскости - это одна и та же плоскость, и, следовательно, они объединяются.
        guard let planeAnchor = anchor as? ARPlaneAnchor, let plane = node.childNodes.first, let geometry = plane.geometry as? SCNPlane else { return } // Берется node первой поверхности и ее геометрия, чтобы затем увеличить ее размеры до размеров объединенной плоскости anchor и позиции ее node.
        
        geometry.width = CGFloat(planeAnchor.extent.x)
        geometry.height = CGFloat(planeAnchor.extent.z)
        
        plane.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
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
}
