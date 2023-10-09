//
//  SceneKitView.swift
//  swifty-protein
//
//  Created by Julien Richard on 09/10/2023.
//

//import Foundation
import SwiftUI
import SceneKit

struct SceneKitView: UIViewRepresentable {
    @Binding var searchText: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        sceneView.scene = SCNScene()
        sceneView.allowsCameraControl = true
        context.coordinator.scnView = sceneView
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.name = "userControlledCamera"
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 50)
        sceneView.scene?.rootNode.addChildNode(cameraNode)
        sceneView.pointOfView = cameraNode
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tapGesture.delegate = context.coordinator
        sceneView.addGestureRecognizer(tapGesture)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.scnView = uiView
        
        if (searchText.count) == 0 {
            uiView.scene?.rootNode.enumerateChildNodes { (node, stop) in
                node.removeFromParentNode()
            }
        }
        // init camera
        var cameraNode = uiView.scene?.rootNode.childNode(withName: "cameraNode", recursively: false)
        
        if (cameraNode == nil) {
            cameraNode = SCNNode()
            cameraNode?.camera = SCNCamera()
            cameraNode?.name = "cameraNode"
            uiView.scene?.rootNode.addChildNode(cameraNode!)
        }
        
        if uiView.allowsCameraControl, uiView.pointOfView?.name == nil {
            uiView.pointOfView?.name = "userControlledCamera"
        }
        
        print("View initiale lors de l'update de la vue: \(uiView.pointOfView?.name ?? "")")
        
        // add camera position
        cameraNode?.position = SCNVector3(x: 0, y: 0, z: 50)
        
        uiView.setNeedsDisplay()
        
        getSdfFile(moleculeCode: searchText) { atoms, connects in
            for atom in atoms {
                self.createAtom(uiView: uiView, atom: atom)
            }
            for connect in connects {
                if let from = atoms.first(where: {$0.id == connect.from}) {
                    if let to = atoms.first(where: {$0.id == connect.to}) {
                        self.createConnection(uiView: uiView, from: from, to: to)
                    }
                }
            }
        }
        // Light positions
        setupLights(in: uiView.scene?.rootNode)
    }
    
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
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer { dispatchGroup.leave() }
            
            guard let data = data else { return }
            let sdfString = String(data: data, encoding: .utf8) ?? ""
            
            // Ici, tu peux appeler ta fonction de parsing existante
            let (fetchedAtoms, fetchedConnects) = self.parseSdfFile(contents: sdfString)
            atoms = fetchedAtoms
            connects = fetchedConnects
        }.resume()
        
        dispatchGroup.notify(queue: .main) {
            completion(atoms, connects)
        }
    }
    
    func parseSdfFile (contents: String) -> ([Atom], [Connect]){
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
                if isAtomSection && atomCount > 0 {
                    let words = line.split(separator: " ", maxSplits: 10, omittingEmptySubsequences: true)
                    let x = Float(words[0]) ?? 0.0
                    let y = Float(words[1]) ?? 0.0
                    let z = Float(words[2]) ?? 0.0
                    let name = String(words[3])
                    if (name != "H") {
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
        createSphere(uiView: uiView, radius: CGFloat(atom.radius), color: color, x: atom.x, y: atom.y, z: atom.z, atom: atom)
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
    
    func createConnection (uiView: SCNView, from: Atom, to: Atom) {
        guard let fromColor = color(for: from.name) else { return }
        guard let toColor = color(for: to.name) else { return }
        print ("from: \(from.id) to: \(to.id)")
        // add coordinates of the first atom
        let fromNode = SCNNode()
        fromNode.position = SCNVector3(x: from.x, y: from.y, z: from.z)
        
        // add coordinates of the second atom
        let toNode = SCNNode()
        toNode.position = SCNVector3(x: to.x, y: to.y, z: to.z)
        
        // add line from A to half distance between A and B
        let halfDistance = SCNVector3((from.x + to.x) / 2, (from.y + to.y) / 2, (from.z + to.z) / 2)
        
        uiView.scene?.rootNode.addChildNode(CylinderLine(parent: uiView.scene!.rootNode, v1: fromNode.position, v2: halfDistance, radius: 0.2, radSegmentCount: 10, color: fromColor))
        uiView.scene?.rootNode.addChildNode(CylinderLine(parent: uiView.scene!.rootNode, v1: halfDistance, v2: toNode.position, radius: 0.2, radSegmentCount: 10, color: toColor))
    }
}

// TODO :
// - Ajouter un bouton share pour partager l'image
