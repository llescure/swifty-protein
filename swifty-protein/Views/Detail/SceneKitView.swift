//
//  SceneKitView.swift
//  swifty-protein
//
//  Created by Julien Richard on 09/10/2023.
//

import SceneKit
import SwiftUI
import UIKit

struct SceneKitView: UIViewRepresentable {
    let searchText: String
    let toggleHydrogen: Bool
    let alternativeForm: Bool

    @Binding var isLoading: Bool
    @Binding var isError: Bool
    
    private let zoom: Float = 22
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = createSceneView(context: context)
        setupGestureRecognizers(sceneView, context: context)
        return sceneView
    }
    
    private func createSceneView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        sceneView.scene = SCNScene()
        sceneView.allowsCameraControl = true
        context.coordinator.scnView = sceneView
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.name = "userControlledCamera"
        cameraNode.position = SCNVector3(x: 0, y: 0, z: zoom)
        sceneView.scene?.rootNode.addChildNode(cameraNode)
        sceneView.pointOfView = cameraNode
        
        return sceneView
    }
    
    private func setupGestureRecognizers(_ sceneView: SCNView, context: Context) {
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tapGesture.delegate = context.coordinator
        
        sceneView.addGestureRecognizer(tapGesture)
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.scnView = uiView
        
        removeUnwantedNodes(from: uiView)
        setupCamera(in: uiView)
        
        getSdfFile(moleculeCode: searchText) { atoms, connects in
            createAtomsAndConnections(uiView: uiView, atoms: atoms, connects: connects)
        }
        
        setupLights(in: uiView.scene?.rootNode)
        uiView.setNeedsDisplay()
    }
    
    func removeUnwantedNodes(from uiView: SCNView) {
        if !toggleHydrogen {
            removeNodes(from: uiView, matching: ["Light", "H"])
        }
        if !alternativeForm {
            removeNodes(from: uiView, matching: ["Light", "Atom"])
        }
    }

    private func removeNodes(from uiView: SCNView, matching names: [String]) {
        uiView.scene?.rootNode.enumerateChildNodes { (node, _) in
            for name in names where node.name?.contains(name) == true {
                node.removeFromParentNode()
            }
        }
    }

    private func setupCamera(in uiView: SCNView) {
        var cameraNode = uiView.scene?.rootNode.childNode(withName: "cameraNode", recursively: false)
        if cameraNode == nil {
            cameraNode = SCNNode()
            cameraNode?.camera = SCNCamera()
            cameraNode?.name = "cameraNode"
            uiView.scene?.rootNode.addChildNode(cameraNode!)
        }
        if uiView.allowsCameraControl, uiView.pointOfView?.name == nil {
            uiView.pointOfView?.name = "userControlledCamera"
        }
        cameraNode?.position = SCNVector3(x: 0, y: 0, z: zoom)
    }

    private func createAtomsAndConnections(uiView: SCNView, atoms: [Atom], connects: [Connect]) {
        for atom in atoms {
            self.createAtom(uiView: uiView, atom: atom)
        }
        for connect in connects {
            if let from = atoms.first(where: {$0.id == connect.from}) {
                if let to = atoms.first(where: {$0.id == connect.to}) {
                    self.createConnection(uiView: uiView, from: from, to: to, weight: connect.weight)
                }
            }
        }
    }
}

private extension SceneKitView {
    func setupLights(in rootNode: SCNNode?) {
        let lightPositions = [
            SCNVector3(x: 0, y: 0, z: 50),  // Front
            SCNVector3(x: -50, y: 0, z: 0), // Left
            SCNVector3(x: 50, y: 0, z: 0),  // Right
            SCNVector3(x: 0, y: 50, z: 0),  // Top
            SCNVector3(x: 0, y: -50, z: 0), // Bottom
            SCNVector3(x: 0, y: 0, z: -50)  // Back
        ]
        
        for position in lightPositions {
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.name = "Light"
            lightNode.light?.type = .omni
            lightNode.light?.intensity = 2000
            lightNode.light?.color = UIColor(white: 0.5, alpha: 1)
            lightNode.position = position
            rootNode?.addChildNode(lightNode)
        }
    }
    
    func getSdfFile(moleculeCode: String, completion: @escaping ([Atom], [Connect]) -> Void) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        var atoms: [Atom] = []
        var connects: [Connect] = []
        
        let urlString = "https://files.rcsb.org/ligands/view/\(moleculeCode)_ideal.sdf"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            defer { dispatchGroup.leave() }
            
            guard let data = data else { return }
            let sdfString = String(data: data, encoding: .utf8) ?? ""
            
            // here, you can call your existing parsing function
            let (fetchedAtoms, fetchedConnects) = self.parseSdfFile(contents: sdfString)
            atoms = fetchedAtoms
            connects = fetchedConnects
        }.resume()
        
        dispatchGroup.notify(queue: .main) {
            isLoading = false
            completion(atoms, connects)
        }
    }
    
    func parseSdfFile (contents: String) -> ([Atom], [Connect]) {
        var atoms: [Atom] = []
        var connects: [Connect] = []
        do {
            let lines = contents.split(separator: "\n")
            var isAtomSection = false
            var isConnectSection = false
            var atomCount = 0
            var connectCount = 0
            for line in lines {
                if line.contains("V2000") {
                    let counts = line.split(separator: " ")
                    atomCount = Int(counts[0]) ?? 0
                    connectCount = Int(counts[1]) ?? 0
                    isAtomSection = true
                    continue
                }
                if atomCount > 1 && connectCount < 1 {
                    print("Error while fetching")
                    isError = true
                    return (atoms, connects)
                }
                if isAtomSection && atomCount > 0 {
                    let words = line.split(separator: " ", maxSplits: 10, omittingEmptySubsequences: true)
                    let x = Float(words[0]) ?? 0.0
                    let y = Float(words[1]) ?? 0.0
                    let z = Float(words[2]) ?? 0.0
                    let name = String(words[3])
                    // we add every atom except hydrogen except if the toggle is on
                    if name != "H" || toggleHydrogen {
                        atoms.append(Atom(id: atoms.count + 1, name: name, radius: 0.3, x: x, y: y, z: z))
                    }
                    atomCount -= 1
                    if atomCount == 0 {
                        isAtomSection = false
                        isConnectSection = true
                    }
                    continue
                }
                if isConnectSection && connectCount > 0 {
                    let words = line.split(separator: " ", maxSplits: 4, omittingEmptySubsequences: true)
                    let from = Int(words[0]) ?? 0
                    let to = Int(words[1]) ?? 0
                    let weight = Int(words[2]) ?? 0
                    connects.append(Connect(from: from, to: to, weight: weight))
                    connectCount -= 1
                }
            }
            return (atoms, connects)
        }
    }
    
    func createAtom(uiView: SCNView, atom: Atom) {
        guard let color = color(for: atom.name) else { return }
        if alternativeForm {
            createCube(uiView: uiView, radius: CGFloat(atom.radius), color: color, x: atom.x, y: atom.y, z: atom.z, atom: atom)
        } else {
            createSphere(uiView: uiView, radius: CGFloat(atom.radius), color: color, x: atom.x, y: atom.y, z: atom.z, atom: atom)
        }
    }
    
    func createSphere(uiView: SCNView, radius: CGFloat, color: UIColor, x: Float, y: Float, z: Float, atom: Atom) {
        // add a sphere
        let sphere = SCNSphere(radius: radius)
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3(x: x, y: y, z: z)
        
        // add metadatas
        sphereNode.name = "Atom \(atom.id): \(atom.name)"
                
        // add a material to the sphere
        let material = SCNMaterial()
        material.diffuse.contents = color
        sphere.materials = [material]
        
        uiView.scene?.rootNode.addChildNode(sphereNode)
    }
    
    func createCube(uiView: SCNView, radius: CGFloat, color: UIColor, x: Float, y: Float, z: Float, atom: Atom) {
        // add a cube
        let cube = SCNBox(width: radius * 2, height: radius * 2, length: radius * 2, chamferRadius: 0)
        let cubeNode = SCNNode(geometry: cube)
        cubeNode.position = SCNVector3(x: x, y: y, z: z)
        
        // add metadatas
        cubeNode.name = "Atom \(atom.id): \(atom.name)"
        
        // add a material to the cube
        let material = SCNMaterial()
        material.diffuse.contents = color
        cube.materials = [material]
        
        uiView.scene?.rootNode.addChildNode(cubeNode)
    }
    
    func createConnection (uiView: SCNView, from: Atom, to: Atom, weight: Int) {
        guard let fromColor = color(for: from.name) else { return }
        guard let toColor = color(for: to.name) else { return }
        var radius = 0.2
        let direction = SCNVector3(to.x - from.x, to.y - from.y, to.z - from.z)
        let length = sqrt(direction.x * direction.x + direction.y * direction.y + direction.z * direction.z)
        let normalizedDirection = SCNVector3(direction.x / length, direction.y / length, direction.z / length)
        
        let perpendicular = SCNVector3(-normalizedDirection.y, normalizedDirection.x, 0)
        
        let offsets: [SCNVector3]
        
        switch weight {
        case 1:
            radius = 0.2
            offsets = [SCNVector3(0, 0, 0)]
        case 2:
            radius = 0.1
            offsets = [SCNVector3(-perpendicular.x * 0.2, -perpendicular.y * 0.2, -perpendicular.z * 0.2),
                       SCNVector3(perpendicular.x * 0.2, perpendicular.y * 0.2, perpendicular.z * 0.2)]
        default:
            radius = 0.2
            offsets = [SCNVector3(0, 0, 0)]
        }
        
        for offset in offsets {
            let adjustedFrom = SCNVector3(from.x + offset.x, from.y + offset.y, from.z + offset.z)
            let adjustedTo = SCNVector3(to.x + offset.x, to.y + offset.y, to.z + offset.z)
            
            let halfDistance = SCNVector3((adjustedFrom.x + adjustedTo.x) / 2, (adjustedFrom.y + adjustedTo.y) / 2, (adjustedFrom.z + adjustedTo.z) / 2)
            
            uiView.scene?.rootNode.addChildNode(CylinderLine(parent: uiView.scene!.rootNode, v1: adjustedFrom, v2: halfDistance, radius: radius, radSegmentCount: 10, color: fromColor, name: "Connection \(from.name) to \(to.name)"))
            uiView.scene?.rootNode.addChildNode(CylinderLine(parent: uiView.scene!.rootNode, v1: halfDistance, v2: adjustedTo, radius: radius, radSegmentCount: 10, color: toColor, name: "Connection \(from.name) to \(to.name)"))
        }
    }
}
