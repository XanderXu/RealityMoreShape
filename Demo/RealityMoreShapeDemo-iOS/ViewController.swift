//
//  ViewController.swift
//  RealityGeometry
//
//  Created by CoderXu on 2022/2/17.
//

import UIKit
import RealityKit
import ARKit
import RealityMoreShape

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var arView: ARView!
    let coachingOverlay = ARCoachingOverlayView()
    let modelAnchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: simd_float2(0.1, 0.1)))
    var selectedIndex: Int = 0 {
        didSet {
            if selectedIndex != oldValue {
                updateMesh()
            }
        }
    }
    let meshNames: [String] = [
        "CirclePlane",
        "ArcPlane",
        "SquirclePlane",
        "RoundedRectPlane",
        "Cone",
        "Cylinder",
        "Capsule",
        "Torus",
        "LissajousCurveTorus",
        "Tetrahedron",
        "Hexahedron",
        "Octahedron",
        "Dodecahedron",
        "Icosahedron",
        "GeoSphere",
        "ExtrudedRoundedRectPad",
        "RoundedCube",
        "CubeSphere",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        setupCoachingOverlay()
        
        var m = PhysicallyBasedMaterial()
        m.baseColor = .init(tint: .white, texture:.init(try! TextureResource.load(named: "number.jpeg", in: nil)))
        var m2 = PhysicallyBasedMaterial()
        m2.baseColor = .init(tint: .red, texture: nil)
        do {
            let mesh = try MeshResource.generateCirclePlane(radius:0.1, angularResolution: 30, radialResolution: 5, circleUV: true)
            let model = ModelEntity(mesh:mesh, materials: [m,m,m2])
            model.position.y = 0.1
//            model.orientation = simd_quatf(angle: -.pi/4, axis: SIMD3<Float>(1,0,0))
            model.name = "model"
            modelAnchor.addChild(model)
        } catch {
            print(error)
        }
        resetTracking()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Prevent the screen from being dimmed to avoid interuppting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true

        // Start the `ARSession`.
        resetTracking()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    // MARK: - Session management
    
    /// Creates a new AR configuration to run on the `session`.
    func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
//        configuration.environmentTexturing = .automatic
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        // Add the anchor to the scene
        arView.scene.anchors.append(modelAnchor)
        coachingOverlay.setActive(true, animated: true)
    }
    @IBAction func resetBtnAnction(_ sender: UIButton) {
        resetTracking()
    }
    @IBAction func shapeBtnAction(_ sender: UIButton) {
        tableView.isHidden = sender.isSelected
        sender.isSelected = !sender.isSelected
    }
    @IBAction func segChanged(_ sender: UISegmentedControl) {
        if let model = arView.scene.findEntity(named: "model") as? ModelEntity {
            model.components.remove(ModelDebugOptionsComponent.self)
            switch sender.selectedSegmentIndex {
            case 0:
                break
            case 1:
                let debug = ModelDebugOptionsComponent(visualizationMode: .normal)
                model.components.set(debug)
            case 2:
                let debug = ModelDebugOptionsComponent(visualizationMode: .textureCoordinates)
                model.components.set(debug)
            default:
                break
            }
        }
        
    }
    
    
    func updateMesh() {
        guard let model = arView.scene.findEntity(named: "model") as? ModelEntity else {
            return
        }
        do {
            switch selectedIndex {
            case 0:
                let mesh = try MeshResource.generateCirclePlane(radius:0.1, angularResolution: 30, radialResolution: 5, circleUV: true)
                model.model?.mesh = mesh
            case 1:
                let mesh = try MeshResource.generateArcPlane(innerRadius: 0.02, outerRadius: 0.1, startAngle: 0, endAngle: .pi, angularResolution: 30, radialResolution: 5, circleUV: true)
                model.model?.mesh = mesh
            case 2:
                let mesh = try MeshResource.generateSquirclePlane(size: 0.2, p: 4, angularResolution: 30, radialResolution: 5, circleUV: true)
                model.model?.mesh = mesh
            case 3:
                let mesh = try MeshResource.generateRoundedRectPlane(width: 0.2, height: 0.2, radius: 0.05, angularResolution: 10, edgeXResolution: 5, edgeYResolution: 5, radialResolution: 5, circleUV: true)
                model.model?.mesh = mesh
            case 4:
                let mesh = try MeshResource.generateCone(radius: 0.1, height: 0.15, angularResolution: 24, radialResolution: 2, verticalResolution: 3, splitFaces: true, circleUV: false)
                model.model?.mesh = mesh
            case 5:
                let mesh = try MeshResource.generateCylinder(radius: 0.05, height: 0.2, angularResolution: 24, radialResolution: 2, verticalResolution: 3, splitFaces: false, circleUV: false)
                model.model?.mesh = mesh
            case 6:
                let mesh = try MeshResource.generateCapsule(radius: 0.05, height: 0.1, angularResolution: 24, radialResolution: 5, verticalResolution: 3, splitFaces: true)
                model.model?.mesh = mesh
            case 7:
                let mesh = try MeshResource.generateTorus(minorRadius: 0.02, majorRadius: 0.1)
                model.model?.mesh = mesh
            case 8:
                let mesh = try MeshResource.generateLissajousCurveTorus(minorRadius: 0.008, majorRadius: 0.1, height: 0.1, cycleTimes: 4, majorResolution: 96)
                model.model?.mesh = mesh
            case 9:
                let mesh = try MeshResource.generateTetrahedron(radius: 0.1, res: 3)
                model.model?.mesh = mesh
            case 10:
                let mesh = try MeshResource.generateHexahedron(radius: 0.1, res: 3)
                model.model?.mesh = mesh
            case 11:
                let mesh = try MeshResource.generateOctahedron(radius: 0.1, res: 3)
                model.model?.mesh = mesh
            case 12:
                let mesh = try MeshResource.generateDodecahedron(radius: 0.1, res: 3)
                model.model?.mesh = mesh
            case 13:
                let mesh = try MeshResource.generateIcosahedron(radius: 0.1, res: 3)
                model.model?.mesh = mesh
            case 14:
                let mesh = try MeshResource.generateGeoSphere(radius: 0.1, res: 3)
                model.model?.mesh = mesh
            case 15:
                let mesh = try MeshResource.generateExtrudedRoundedRectPad(width: 0.2, height: 0.2, depth: 0.1, radius: 0.05, splitFaces: false, circleUV: false)
                model.model?.mesh = mesh
            case 16:
                let mesh = try MeshResource.generateRoundedCube(width: 0.2, height: 0.2, depth: 0.2, radius: 0.1, widthResolution: 20, heightResolution: 20, depthResolution: 20, splitFaces: false)
                model.model?.mesh = mesh
            case 17:
                let mesh = try MeshResource.generateCubeSphere(radius: 0.1, resolution: 20, splitFaces: false)
                model.model?.mesh = mesh
            default:
                break
            }
            
        } catch {
            print(error)
        }
        
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 18
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = meshNames[indexPath.row]
        if indexPath.row == selectedIndex {
            cell?.backgroundColor = UIColor.gray
        } else {
            cell?.backgroundColor = .clear
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
    }
    
}
