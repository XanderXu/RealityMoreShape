//
//  ViewModel.swift
//  RealityMoreShapeDemo-visionOS
//
//  Created by 许同学 on 2024/4/21.
//

import Foundation
import RealityKit
import RealityMoreShape
import SwiftUI

@Observable
class ViewModel: @unchecked Sendable {
    var modelEntity: ModelEntity?
    
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
    let meshNamesLocal: [LocalizedStringKey] = [
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
    
    func generateShapeOfIndex(_ index: Int) -> RealityKit.MeshResource? {
        do {
            switch index {
            case 0:
                let mesh = try MeshResource.generateCirclePlane(radius:0.1, angularResolution: 30, radialResolution: 5, circleUV: true)
                return mesh
            case 1:
                let mesh = try MeshResource.generateArcPlane(innerRadius: 0.02, outerRadius: 0.1, startAngle: 0, endAngle: .pi, angularResolution: 30, radialResolution: 5, circleUV: true)
                return mesh
            case 2:
                let mesh = try MeshResource.generateSquirclePlane(size: 0.2, p: 4, angularResolution: 30, radialResolution: 5, circleUV: true)
                return mesh
            case 3:
                let mesh = try MeshResource.generateRoundedRectPlane(width: 0.2, height: 0.2, radius: 0.05, angularResolution: 10, edgeXResolution: 5, edgeYResolution: 5, radialResolution: 5, circleUV: true)
                return mesh
            case 4:
                let mesh = try MeshResource.generateCone(radius: 0.1, height: 0.15, angularResolution: 24, radialResolution: 2, verticalResolution: 3, splitFaces: true, circleUV: false)
                return mesh
            case 5:
                let mesh = try MeshResource.generateCylinder(radius: 0.05, height: 0.2, angularResolution: 24, radialResolution: 2, verticalResolution: 3, splitFaces: false, circleUV: false)
                return mesh
            case 6:
                let mesh = try MeshResource.generateCapsule(radius: 0.05, height: 0.1, angularResolution: 24, radialResolution: 5, verticalResolution: 3, splitFaces: true)
                return mesh
            case 7:
                let mesh = try MeshResource.generateTorus(minorRadius: 0.02, majorRadius: 0.1)
                return mesh
            case 8:
                let mesh = try MeshResource.generateLissajousCurveTorus(minorRadius: 0.008, majorRadius: 0.1, height: 0.1, cycleTimes: 4, majorResolution: 96)
                return mesh
            case 9:
                let mesh = try MeshResource.generateTetrahedron(radius: 0.1, res: 3)
                return mesh
            case 10:
                let mesh = try MeshResource.generateHexahedron(radius: 0.1, res: 3)
                return mesh
            case 11:
                let mesh = try MeshResource.generateOctahedron(radius: 0.1, res: 3)
                return mesh
            case 12:
                let mesh = try MeshResource.generateDodecahedron(radius: 0.1, res: 3)
                return mesh
            case 13:
                let mesh = try MeshResource.generateIcosahedron(radius: 0.1, res: 3)
                return mesh
            case 14:
                let mesh = try MeshResource.generateGeoSphere(radius: 0.1, res: 3)
                return mesh
            case 15:
                let mesh = try MeshResource.generateExtrudedRoundedRectPad(width: 0.2, height: 0.2, depth: 0.1, radius: 0.05, splitFaces: false, circleUV: false)
                return mesh
            case 16:
                let mesh = try MeshResource.generateRoundedCube(width: 0.2, height: 0.2, depth: 0.2, radius: 0.1, widthResolution: 20, heightResolution: 20, depthResolution: 20, splitFaces: false)
                return mesh
            case 17:
                let mesh = try MeshResource.generateCubeSphere(radius: 0.1, resolution: 20, splitFaces: false)
                return mesh
            default:
                return nil
            }
            
        } catch {
            print(error)
            return nil
        }
    }
    
    func generateShapeOfIndexAsync(_ index: Int) async -> RealityKit.MeshResource? {
        do {
            switch index {
            case 0:
                let mesh = try await MeshResource.generateCirclePlaneAsync(radius:0.1, angularResolution: 30, radialResolution: 5, circleUV: true)
                return mesh
            case 1:
                let mesh = try await MeshResource.generateArcPlaneAsync(innerRadius: 0.02, outerRadius: 0.1, startAngle: 0, endAngle: .pi, angularResolution: 30, radialResolution: 5, circleUV: true)
                return mesh
            case 2:
                let mesh = try await MeshResource.generateSquirclePlaneAsync(size: 0.2, p: 4, angularResolution: 30, radialResolution: 5, circleUV: true)
                return mesh
            case 3:
                let mesh = try await MeshResource.generateRoundedRectPlaneAsync(width: 0.2, height: 0.2, radius: 0.05, angularResolution: 10, edgeXResolution: 5, edgeYResolution: 5, radialResolution: 5, circleUV: true)
                return mesh
            case 4:
                let mesh = try await MeshResource.generateConeAsync(radius: 0.1, height: 0.15, angularResolution: 24, radialResolution: 2, verticalResolution: 3, splitFaces: true, circleUV: false)
                return mesh
            case 5:
                let mesh = try await MeshResource.generateCylinderAsync(radius: 0.05, height: 0.2, angularResolution: 24, radialResolution: 2, verticalResolution: 3, splitFaces: true, circleUV: false)
                return mesh
            case 6:
                let mesh = try await MeshResource.generateCapsuleAsync(radius: 0.05, height: 0.1, angularResolution: 24, radialResolution: 5, verticalResolution: 3, splitFaces: true)
                return mesh
            case 7:
                let mesh = try await MeshResource.generateTorusAsync(minorRadius: 0.02, majorRadius: 0.1)
                return mesh
            case 8:
                let mesh = try await MeshResource.generateLissajousCurveTorusAsync(minorRadius: 0.008, majorRadius: 0.1, height: 0.1, cycleTimes: 4, majorResolution: 96)
                return mesh
            case 9:
                let mesh = try await MeshResource.generateTetrahedronAsync(radius: 0.1, res: 0)
                return mesh
            case 10:
                let mesh = try MeshResource.generateHexahedron(radius: 0.1, res: 0)
                return mesh
            case 11:
                let mesh = try await MeshResource.generateOctahedronAsync(radius: 0.1, res: 0)
                return mesh
            case 12:
                let mesh = try await MeshResource.generateDodecahedronAsync(radius: 0.1, res: 0)
                return mesh
            case 13:
                let mesh = try await MeshResource.generateIcosahedronAsync(radius: 0.1, res: 0)
                return mesh
            case 14:
                let mesh = try await MeshResource.generateGeoSphereAsync(radius: 0.1, res: 3)
                return mesh
            case 15:
                let mesh = try await MeshResource.generateExtrudedRoundedRectPadAsync(width: 0.2, height: 0.2, depth: 0.1, radius: 0.05, splitFaces: false, circleUV: false)
                return mesh
            case 16:
                let mesh = try await MeshResource.generateRoundedCubeAsync(width: 0.2, height: 0.2, depth: 0.2, radius: 0.1, widthResolution: 20, heightResolution: 20, depthResolution: 20, splitFaces: false)
                return mesh
            case 17:
                let mesh = try await MeshResource.generateCubeSphereAsync(radius: 0.1, resolution: 20, splitFaces: false)
                return mesh
            default:
                return nil
            }
            
        } catch {
            print(error)
            return nil
        }
    }
    
}
