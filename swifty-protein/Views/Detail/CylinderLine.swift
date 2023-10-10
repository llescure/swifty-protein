//
//  CylinderLine.swift
//  swifty-protein
//
//  Created by Julien Richard on 09/10/2023.
//

import Foundation
import SceneKit

class   CylinderLine: SCNNode {
    init(parent: SCNNode,// Needed to add destination point of your line
         v1: SCNVector3,// source
         v2: SCNVector3,// destination
         radius: CGFloat,// somes option for the cylinder
         radSegmentCount: Int, // other option
         color: UIColor,// color of your node object
         name: String )// name of your node object
    {
        super.init()
        // Calculate the height of our line
        let  height = v1.distance(receiver: v2)
        // set position to v1 coordinate
        position = v1
        // add a name to the node
        self.name = name
        // Create the second node to draw direction vector
        let nodeV2 = SCNNode()
        // define his position
        nodeV2.position = v2
        // add it to parent
        parent.addChildNode(nodeV2)
        // Align Z axis
        let zAlign = SCNNode()
        zAlign.eulerAngles.x = Float(Double.pi / 2)
        // create our cylinder
        let cyl = SCNCylinder(radius: radius, height: CGFloat(height))
        cyl.radialSegmentCount = radSegmentCount
        cyl.firstMaterial?.diffuse.contents = color
        // Create node with cylinder
        let nodeCyl = SCNNode(geometry: cyl )
        nodeCyl.position.y = -height/2
        zAlign.addChildNode(nodeCyl)
        // Add it to child
        addChildNode(zAlign)
        // set constraint direction to our vector
        constraints = [SCNLookAtConstraint(target: nodeV2)]
    }
    override init() {
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

private extension SCNVector3 {
    func distance(receiver: SCNVector3) -> Float {
        let xd = receiver.x - self.x
        let yd = receiver.y - self.y
        let zd = receiver.z - self.z
        let distance = Float(sqrt(xd * xd + yd * yd + zd * zd))
        if distance < 0 {
            return distance * -1
        } else {
            return distance
        }
    }
}
