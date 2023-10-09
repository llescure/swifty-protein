//
//  Coordinator.swift
//  swifty-protein
//
//  Created by Julien Richard on 09/10/2023.
//

import Foundation
import UIKit
import SceneKit

class Coordinator: NSObject, UIGestureRecognizerDelegate {
    var scnView: SCNView?
    
    var parent: SceneKitView
    
    init(_ parent: SceneKitView) {
        self.parent = parent
    }
    
    @objc func handleTap(_ gestureRecognize: UITapGestureRecognizer) {
        print("handleTap function")
        guard let scnView = self.scnView else { return }
        
        // Attribut camera name
        if scnView.allowsCameraControl, scnView.pointOfView?.name == nil {
            scnView.pointOfView?.name = "userControlledCamera"
        }
        
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        
        if let cameraNode = scnView.scene?.rootNode.childNode(withName: "userControlledCamera", recursively: true) {
            scnView.pointOfView = cameraNode // Use own camera
            scnView.allowsCameraControl = false // Disable auto camera
            if hitResults.count > 0 {
                handleAtomTap(hitResults[0], cameraNode: cameraNode)
            } else {
                handleEmptySpaceTap(cameraNode: cameraNode)
            }
            scnView.allowsCameraControl = true
        }
    }
    
    func showInfoCapsule(message: String) {
        // Crée la capsule (UIView)
        let capsule = UILabel()
        capsule.text = message
        capsule.font = UIFont(name: "HelveticaNeue", size: 20)
        capsule.textColor = UIColor.black
        capsule.backgroundColor = UIColor.lightGray
        capsule.textAlignment = .center
        capsule.layer.cornerRadius = 10
        capsule.clipsToBounds = true

        // Positionne la capsule
        let capsuleSize = CGSize(width: 200, height: 50)
        capsule.frame = CGRect(x: 100, y: 100, width: capsuleSize.width, height: capsuleSize.height)
        
        // Ajoute la capsule à la vue
        scnView?.addSubview(capsule)
        
        // Fait disparaître la capsule après 3 secondes
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            capsule.removeFromSuperview()
        }
    }

    func handleAtomTap(_ result: SCNHitTestResult, cameraNode: SCNNode) {
        if let name = result.node.name {
            // Affiche le nom et l'ID de l'atome dans une fenêtre d'alerte
            showInfoCapsule(message: name)

            let atomPosition = result.node.position
            
            // Modification de la position de la caméra
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            cameraNode.position = SCNVector3(x: atomPosition.x, y: atomPosition.y, z: 10)
            SCNTransaction.commit()
        }
    }

    func handleEmptySpaceTap (cameraNode: SCNNode){
        // Ajustement de la position de la caméra si aucun atome n'est touché
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 50)
        SCNTransaction.commit()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
