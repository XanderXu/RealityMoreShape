//
//  MeshResource+Capsule.swift
//  RealityGeometry
//
//  Created by 许 on 2022/3/29.
//

import RealityKit
extension MeshResource {
    public static func generateCapsule(radius: Float, height: Float, angularResolution: Int = 24, radialResolution: Int = 1, verticalResolution: Int = 1, splitFaces: Bool = false) throws -> MeshResource {
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var normals: [SIMD3<Float>] = []
        var textureMap: [SIMD2<Float>] = []
        var materials: [UInt32] = []
        
        let phi = angularResolution > 2 ? angularResolution : 3;
        let theta = radialResolution > 0 ? radialResolution : 1;
        let slices = verticalResolution > 0 ? verticalResolution : 1;
        
        let phif = Float(phi)
        let thetaf = Float(theta)
        let slicesf = Float(slices)
        
        let phiMax = Float.pi * 2.0
        let thetaMax = Float.pi * 0.5
        
        let phiInc = phiMax / phif
        let thetaInc = thetaMax / thetaf
        let heightInc = height / slicesf
        
        let halfHeight = height * 0.5
        let totalSurfaceLength = height + .pi * radius
        let vPerCap = thetaMax * radius / totalSurfaceLength
        let vPerCyl = height / totalSurfaceLength
        
        let perLoop = phi + 1
        let verticesPerCap = perLoop * (theta + 1)
        
        // top cap
        var textureOutMin: Float = vPerCap + vPerCyl
        var textureOutMax: Float = 1
        if splitFaces {
            textureOutMin = 0
        }
        for t in 0...theta {
            let tf = Float(t)
            let thetaAngle = tf * thetaInc
            let cosTheta = cos(thetaAngle)
            let sinTheta = sin(thetaAngle)
            
            for p in 0...phi {
                let pf = Float(p)
                let phiAngle = pf * phiInc
                let cosPhi = cos(phiAngle)
                let sinPhi = sin(phiAngle)
                
                let x = cosPhi * sinTheta
                let z = sinPhi * sinTheta
                let y = cosTheta
                
                
                meshPositions.append(SIMD3<Float>(radius * x, radius * y + halfHeight, radius * z))
                normals.append(SIMD3<Float>(x, y, z))
                textureMap.append(SIMD2<Float>(1 - pf / phif, map(input: thetaMax - thetaAngle, inMin: 0.0, inMax: thetaMax, outMin: textureOutMin, outMax: textureOutMax)))
                
                if(p != phi && t != theta) {
                    let index = p + t * perLoop
                    
                    let tl = UInt32(index)
                    let tr = tl + 1
                    let bl = UInt32(index + perLoop)
                    let br = bl + 1
                    
                    indices.append(contentsOf: [
                        tl, tr, br,
                        tl, br, bl
                    ])
                }
            }
        }
        
        // bottom cap
        if splitFaces {//reverse at bottom
            textureOutMin = 1
            textureOutMax = 0
        } else {
            textureOutMin = 0
            textureOutMax = vPerCap
        }
        for t in 0...theta {
            let tf = Float(t)
            let thetaAngle = tf * thetaInc
            let cosTheta = cos(thetaAngle)
            let sinTheta = sin(thetaAngle)
            
            for p in 0...phi {
                let pf = Float(p)
                let phiAngle = pf * phiInc
                let cosPhi = cos(phiAngle)
                let sinPhi = sin(phiAngle)
                
                let x = cosPhi * sinTheta
                let z = sinPhi * sinTheta
                let y = -cosTheta
                
                
                meshPositions.append(SIMD3<Float>(radius * x, radius * y - halfHeight, radius * z))
                normals.append(SIMD3<Float>(x, y, z))
                textureMap.append(SIMD2<Float>(splitFaces ? pf / phif : 1 - pf / phif, map(input: thetaAngle - thetaMax, inMin: -thetaMax, inMax: 0, outMin: textureOutMin, outMax: textureOutMax)))
                
                if(p != phi && t != theta) {
                    let index = verticesPerCap + p + t * perLoop
                    
                    let tl = UInt32(index)
                    let tr = tl + 1
                    let bl = UInt32(index + perLoop)
                    let br = bl + 1
                    
                    indices.append(contentsOf: [
                        tl, bl, tr,
                        tr, bl, br
                    ])
                }
            }
        }
        if splitFaces {
            materials.append(contentsOf: Array(repeating: 1, count: theta * phi * 4))
        }
        
        if splitFaces {
            textureOutMin = 0
            textureOutMax = 1
        } else {
            textureOutMin = vPerCap
            textureOutMax = vPerCap + vPerCyl
        }
        for s in 0...slices {
            let sf = Float(s)
            let y = sf * heightInc
            
            for p in 0...phi {
                let pf = Float(p)
                let phiAngle = pf * phiInc
                let cosPhi = cos(phiAngle)
                let sinPhi = sin(phiAngle)
                
                let x = cosPhi
                let z = sinPhi
                
                meshPositions.append(SIMD3<Float>(radius * x, y - halfHeight, radius * z))
                normals.append(SIMD3<Float>(x, 0, z))
                textureMap.append(SIMD2<Float>(1 - pf / phif, map(input: sf, inMin: 0, inMax: slicesf, outMin: textureOutMin, outMax: textureOutMax)))
                
                if(p != phi && s != slices) {
                    let index = verticesPerCap * 2 + p + s * perLoop
                    
                    let tl = UInt32(index)
                    let tr = tl + 1
                    let bl = UInt32(index + perLoop)
                    let br = bl + 1
                    
                    indices.append(contentsOf: [
                        tl, bl, tr,
                        tr, bl, br
                    ])
                }
            }
        }
        if splitFaces {
            materials.append(contentsOf: Array(repeating: 0, count: slices * phi * 2))
        }
        
        
        descr.positions = MeshBuffers.Positions(meshPositions)
        descr.normals = MeshBuffers.Normals(normals)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        descr.primitives = .triangles(indices)
        if !materials.isEmpty {
            descr.materials = MeshDescriptor.Materials.perFace(materials)
        }
        return try MeshResource.generate(from: [descr])
    }
}
