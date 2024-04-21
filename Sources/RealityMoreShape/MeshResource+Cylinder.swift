//
//  MeshResource+Cylinder.swift
//  
//
//  Created by Xu on 2022/3/29.
//

import RealityKit

extension MeshResource {
    public static func generateCylinder(radius: Float, height: Float, angularResolution: Int = 24, radialResolution: Int = 1, verticalResolution: Int = 1, splitFaces: Bool = false, circleUV: Bool = true) throws -> MeshResource {
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var normals: [SIMD3<Float>] = []
        var textureMap: [SIMD2<Float>] = []
        var materials: [UInt32] = []
        
        
        let radial = radialResolution > 0 ? radialResolution : 1
        let angular = angularResolution > 2 ? angularResolution : 3
        let vertical = verticalResolution > 0 ? verticalResolution : 1

        let radialf = Float(radial)
        let angularf = Float(angular)
        let verticalf = Float(vertical)

        let radialInc = radius / radialf
        let angularInc = (2.0 * .pi) / angularf
        let verticalInc = height / verticalf

        let perLoop = angular + 1
        let verticesPerCircle = perLoop * (radial + 1)
        let yOffset = -0.5 * height
        
        for v in 0...vertical {
            let vf = Float(v)
            let y = yOffset + vf * verticalInc
            for a in 0...angular {
                let af = Float(a)
                let angle = af * angularInc
                let x = cos(angle)
                let z = sin(angle)
                
                meshPositions.append(SIMD3<Float>(radius * x, y, radius * z))
                normals.append(SIMD3<Float>(x, 0.0, z))
                textureMap.append(SIMD2<Float>(1.0 - af / angularf, vf / verticalf))
                
                if (v != vertical && a != angular) {
                    let index = a + v * perLoop

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
            materials.append(contentsOf: Array(repeating: 0, count: angular * vertical * 2))
        }
        
        var flip = true
        var direction: Float = 1.0
        var vertexOffset = meshPositions.count
        for _ in 0..<2 {
            for r in 0...radial {
                let rf = Float(r)
                let rad = rf * radialInc
                for a in 0...angular {
                    let af = Float(a)
                    let angle = af * angularInc
                    let x = rad * cos(angle)
                    let y = rad * sin(angle)
                    
                    meshPositions.append(SIMD3<Float>(x, direction * height * 0.5, y))
                    normals.append(SIMD3<Float>(0.0, direction, 0.0))
                    if circleUV {
                        textureMap.append(SIMD2<Float>(flip ? af / angularf : 1.0 - af / angularf, rf / radialf))
                    } else {
                        textureMap.append(SIMD2<Float>(-direction * x/radius/2+0.5, y/radius/2+0.5))
                    }
                    if (r != radial && a != angular) {
                        let index = vertexOffset + a + r * perLoop;

                        let tl = UInt32(index)
                        let tr = tl + 1
                        let bl = UInt32(index + perLoop)
                        let br = bl + 1

                        if (flip) {
                            indices.append(contentsOf: [
                                tl, tr, bl,
                                tr, br, bl
                            ])
                        } else {
                            indices.append(contentsOf: [
                                tl, bl, tr,
                                tr, bl, br
                            ])
                        }
                    }
                }
            }
            vertexOffset += verticesPerCircle
            direction *= -1.0
            flip = !flip
        }
        if splitFaces {
            materials.append(contentsOf: Array(repeating: 1, count: angular * radial * 4))
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
