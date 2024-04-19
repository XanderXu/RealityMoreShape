//
//  MeshResource+Cone.swift
//  
//
//  Created by Xu on 2022/3/29.
//

import RealityKit

extension MeshResource {
    public static func generateCone(radius: Float, height: Float, angularResolution: Int = 24, radialResolution: Int = 1, verticalResolution: Int = 1, splitFaces: Bool = false, circleUV: Bool = true) throws -> MeshResource {
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var normals: [SIMD3<Float>] = []
        var textureMap: [SIMD2<Float>] = []
        var materials: [UInt32] = []
        
        let vertical = verticalResolution > 0 ? verticalResolution : 1
        let angular = angularResolution > 2 ? angularResolution : 3
        let radial = radialResolution > 0 ? radialResolution : 1
        
        let verticalf = Float(vertical)
        let angularf = Float(angular)
        let radialf = Float(radial)
        
        let angularInc = (2.0 * .pi) / angularf
        let verticalInc = height / verticalf
        let radialInc = radius / radialf
        let radiusInc = radius / verticalf
        
        let yOffset = -0.5 * height
        let perLoop = angular + 1
        let verticesPerWall = perLoop * (vertical + 1)
        
        let hyp = sqrtf(radius * radius + height * height)
        let coneNormX = radius / hyp
        let coneNormY = height / hyp
        
        for v in 0...vertical {
            let vf = Float(v)
            let y = yOffset + vf * verticalInc
            let rad = radius - vf * radiusInc
            
            for a in 0...angular {
                let af = Float(a)
                let angle = af * angularInc
                
                let cosAngle = cos(angle)
                let sinAngle = sin(angle)
                
                let x = rad * cosAngle
                let z = rad * sinAngle
                
                let coneBottomNormal: SIMD3<Float> = [coneNormY * cosAngle, coneNormX, coneNormY * sinAngle]
                
                meshPositions.append(SIMD3<Float>(x, y, z))
                normals.append(normalize(coneBottomNormal))
                textureMap.append(SIMD2<Float>(1 - af / angularf, vf / verticalf))
                
                if (v != vertical && a != angular) {
                    let index = a + v * perLoop
                    
                    let tl = UInt32(index)
                    let tr = tl + 1
                    let bl = UInt32(index + perLoop)
                    let br = bl + 1
                    
                    indices.append(contentsOf: [tl, bl, tr,
                                                tr, bl, br
                                               ])
                }
            }
        }
        if splitFaces {
            materials.append(contentsOf: Array(repeating: 0, count: angular * vertical * 2))
        }
        
        for r in 0...radial {
            let rf = Float(r)
            let rad = rf * radialInc
            
            for a in 0...angular {
                let af = Float(a)
                let angle = af * angularInc
                let x = rad * cos(angle)
                let y = rad * sin(angle)
                
                meshPositions.append(SIMD3<Float>(x, -height * 0.5, y))
                normals.append(SIMD3<Float>(0, -1, 0))
                if circleUV {
                    textureMap.append(SIMD2<Float>(af / angularf, 1 - rf / radialf))
                } else {
                    textureMap.append(SIMD2<Float>(x/radius/2+0.5, y/radius/2+0.5))
                }
                
                if (r != radial && a != angular) {
                    let index = verticesPerWall + a + r * perLoop;
                    
                    let tl = UInt32(index)
                    let tr = tl + 1
                    let bl = UInt32(index + perLoop)
                    let br = bl + 1
                    
                    indices.append(contentsOf: [tl, bl, tr,
                                                tr, bl, br
                                               ])
                }
            }
        }
        if splitFaces {
            materials.append(contentsOf: Array(repeating: 1, count: angular * radial * 2))
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
