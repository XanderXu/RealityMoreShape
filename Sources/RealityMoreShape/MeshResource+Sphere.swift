//
//  MeshResource+Sphere.swift
//  RealityGeometry
//
//  Created by 许 on 2022/4/8.
//

import RealityKit

extension MeshResource {
    public static func generateGeoSphere(radius: Float, res: Int = 0) throws -> MeshResource {
        let pointCount = 12
        var triangles = 20
        var vertices = pointCount
        
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var normals: [SIMD3<Float>] = []
        var textureMap: [SIMD2<Float>] = []
        
        let phi = (1.0 + sqrtf(5)) * 0.5
        let r2 = radius * radius
        let den = (1.0 + (1.0 / pow(phi, 2.0)))
        let h = sqrt(r2 / (den))
        let w = h / phi

        let points = [
            SIMD3<Float>(0.0, h, w),
            SIMD3<Float>(0.0, h, -w),
            SIMD3<Float>(0.0, -h, w),
            SIMD3<Float>(0.0, -h, -w),

            SIMD3<Float>(h, -w, 0.0),
            SIMD3<Float>(h, w, 0.0),
            SIMD3<Float>(-h, -w, 0.0),
            SIMD3<Float>(-h, w, 0.0),

            SIMD3<Float>(-w, 0.0, -h),
            SIMD3<Float>(w, 0.0, -h),
            SIMD3<Float>(-w, 0.0, h),
            SIMD3<Float>(w, 0.0, h)
        ]
        meshPositions.append(contentsOf: points)
        
        let index: [UInt32] = [
            0, 11, 5,
            0, 5, 1,
            0, 1, 7,
            0, 7, 10,
            0, 10, 11,

            1, 5, 9,
            5, 11, 4,
            11, 10, 2,
            10, 7, 6,
            7, 1, 8,

            3, 9, 4,
            3, 4, 2,
            3, 2, 6,
            3, 6, 8,
            3, 8, 9,

            4, 9, 5,
            2, 4, 11,
            6, 2, 10,
            8, 6, 7,
            9, 8, 1
        ]
        
        indices.append(contentsOf: index)
        
        for _ in 0..<res {
            let newTriangles = triangles * 4
            let newVertices = vertices + triangles * 3
            
            var newIndices: [UInt32] = []
            var pos: SIMD3<Float>
            
            for i in 0..<triangles {
                let ai = 3 * i
                let bi = 3 * i + 1
                let ci = 3 * i + 2
                
                let i0 = indices[ai]
                let i1 = indices[bi]
                let i2 = indices[ci]
                
                let v0 = meshPositions[Int(i0)]
                let v1 = meshPositions[Int(i1)]
                let v2 = meshPositions[Int(i2)]
                
                // a
                pos = (v0 + v1) * 0.5
                pos = simd_normalize(pos) * radius
                meshPositions.append(pos)

                // b
                pos = (v1 + v2) * 0.5
                pos = simd_normalize(pos) * radius
                meshPositions.append(pos)
                
                // c
                pos = (v2 + v0) * 0.5
                pos = simd_normalize(pos) * radius
                meshPositions.append(pos)
                
                
                let a = UInt32(ai + vertices)
                let b = UInt32(bi + vertices)
                let c = UInt32(ci + vertices)
                newIndices.append(contentsOf: [
                    i0, a, c,
                    a, i1, b,
                    a, b, c,
                    c, b, i2
                ])
            }
            
            indices = newIndices
            triangles = newTriangles
            vertices = newVertices
        }
        
        for i in 0..<meshPositions.count {
            let p = meshPositions[i]
            let n = simd_normalize(p)
            normals.append(n)
            textureMap.append(SIMD2<Float>(abs(atan2(n.x, n.z)) / .pi, 1 - acos(n.y) / .pi))
        }
        
        descr.positions = MeshBuffers.Positions(meshPositions)
        descr.normals = MeshBuffers.Normals(normals)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        descr.primitives = .triangles(indices)
        return try MeshResource.generate(from: [descr])
    }
    
    public static func generateCubeSphere(radius: Float, resolution: Int = 10, splitFaces: Bool = false) throws -> MeshResource {
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var normals: [SIMD3<Float>] = []
        var textureMap: [SIMD2<Float>] = []
        var materials: [UInt32] = []
        
        
        let edge = resolution > 2 ? resolution : 3
        let edgeMinusOne = edge - 1
        let edgeMinusOnef = Float(edgeMinusOne)
        let edgeMinusOneSqr = edgeMinusOne * edgeMinusOne
        
        let edgeInc = 2 * radius / edgeMinusOnef
        let facePointCount = edge * edge
        
        // +X
        for j in 0..<edge {
            let startY = radius
            let startZ = radius
            let jf = Float(j)
            let uvy = jf / edgeMinusOnef
            for i in 0..<edge {
                let p = SIMD3<Float>(radius, startY - edgeInc * jf, startZ - edgeInc * Float(i))
                meshPositions.append(p)
                
                let uv = SIMD2<Float>(Float(i) / edgeMinusOnef, 1 - uvy)
                textureMap.append(uv)
                
                if j != edgeMinusOne && i != edgeMinusOne {
                    let index = UInt32(i + j * edge)

                    let tl = index
                    let tr = tl + 1
                    let bl = index + UInt32(edge)
                    let br = bl + 1

                    indices.append(contentsOf: [tl,bl,tr,
                                                tr,bl,br])
                }
            }
        }
        // -X
        for j in 0..<edge {
            let startY = radius
            let startZ = -radius
            let jf = Float(j)
            let uvy = jf / edgeMinusOnef
            for i in 0..<edge {
                let p = SIMD3<Float>(-radius, startY - edgeInc * jf, startZ + edgeInc * Float(i))
                meshPositions.append(p)

                let uv = SIMD2<Float>(Float(i) / edgeMinusOnef, 1 - uvy)
                textureMap.append(uv)
                
                if j != edgeMinusOne && i != edgeMinusOne {
                    let index = UInt32(i + j * edge + facePointCount)
                    
                    let tl = index
                    let tr = tl + 1
                    let bl = index + UInt32(edge)
                    let br = bl + 1
                    
                    indices.append(contentsOf: [tl,bl,tr,
                                                tr,bl,br])
                }
            }
        }
        if splitFaces {
            materials.append(contentsOf: Array(repeating: 0, count: edgeMinusOneSqr * 4))
        }
        
        // +Y
        for j in 0..<edge {
            let startX = -radius
            let startZ = -radius
            let jf = Float(j)
            let uvy = jf / edgeMinusOnef
            for i in 0..<edge {
                let p = SIMD3<Float>(startX + edgeInc * Float(i), radius, startZ + edgeInc * jf)
                meshPositions.append(p)

                let uv = SIMD2<Float>(Float(i) / edgeMinusOnef, 1 - uvy)
                textureMap.append(uv)
                
                if j != edgeMinusOne && i != edgeMinusOne {
                    let index = UInt32(i + j * edge + facePointCount * 2)

                    let tl = index
                    let tr = tl + 1
                    let bl = index + UInt32(edge)
                    let br = bl + 1

                    indices.append(contentsOf: [tl,bl,tr,
                                                tr,bl,br])
                }
            }
        }
        // -Y
        for j in 0..<edge {
            let startX = radius
            let startZ = -radius
            let jf = Float(j)
            let uvy = jf / edgeMinusOnef
            for i in 0..<edge {
                let p = SIMD3<Float>(startX - edgeInc * Float(i), -radius, startZ + edgeInc * jf)
                meshPositions.append(p)
                
                let uv = SIMD2<Float>(Float(i) / edgeMinusOnef, 1 - uvy)
                textureMap.append(uv)
                
                if j != edgeMinusOne && i != edgeMinusOne {
                    let index = UInt32(i + j * edge + facePointCount * 3)
                    
                    let tl = index
                    let tr = tl + 1
                    let bl = index + UInt32(edge)
                    let br = bl + 1
                    
                    indices.append(contentsOf: [tl,bl,tr,
                                                tr,bl,br])
                }
            }
        }
        if splitFaces {
            materials.append(contentsOf: Array(repeating: 1, count: edgeMinusOneSqr * 4))
        }
        
        // +Z
        for j in 0..<edge {
            let startY = radius
            let startX = -radius
            let jf = Float(j)
            let uvy = jf / edgeMinusOnef
            for i in 0..<edge {
                let p = SIMD3<Float>(startX + edgeInc * Float(i), startY - edgeInc * jf, radius)
                meshPositions.append(p)
                
                let uv = SIMD2<Float>(Float(i) / edgeMinusOnef, 1 - uvy)
                textureMap.append(uv)
                
                if j != edgeMinusOne && i != edgeMinusOne {
                    let index = UInt32(i + j * edge + facePointCount * 4)

                    let tl = index
                    let tr = tl + 1
                    let bl = index + UInt32(edge)
                    let br = bl + 1

                    indices.append(contentsOf: [tl,bl,tr,
                                                tr,bl,br])
                }
            }
        }
        // -Z
        for j in 0..<edge {
            let startY = radius
            let startX = radius
            let jf = Float(j)
            let uvy = jf / edgeMinusOnef
            for i in 0..<edge {
                let p = SIMD3<Float>(startX - edgeInc * Float(i), startY - edgeInc * jf, -radius)
                meshPositions.append(p)
                
                let uv = SIMD2<Float>(Float(i) / edgeMinusOnef, 1 - uvy)
                textureMap.append(uv)
                
                if j != edgeMinusOne && i != edgeMinusOne {
                    let index = UInt32(i + j * edge + facePointCount * 5)
                    
                    let tl = index
                    let tr = tl + 1
                    let bl = index + UInt32(edge)
                    let br = bl + 1
                    
                    indices.append(contentsOf: [tl,bl,tr,
                                                tr,bl,br])
                }
            }
        }
        if splitFaces {
            materials.append(contentsOf: Array(repeating: 2, count: edgeMinusOneSqr * 4))
        }
        
        var roundPositions: [SIMD3<Float>] = []
        for p in meshPositions {
            let n = simd_normalize(p)
            let n2 = n * n
            
            let x = n.x * sqrtf(1 - (n2.y + n2.z) / 2 + n2.y * n2.z / 3)
            let y = n.y * sqrtf(1 - (n2.x + n2.z) / 2 + n2.x * n2.z / 3)
            let z = n.z * sqrtf(1 - (n2.x + n2.y) / 2 + n2.x * n2.y / 3)
            
            let newN = simd_normalize(SIMD3<Float>(x, y, z))
            normals.append(newN)
            
            roundPositions.append(newN * radius)
        }
        meshPositions = roundPositions
        
        descr.positions = MeshBuffers.Positions(meshPositions)
        descr.normals = MeshBuffers.Normals(normals)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        descr.primitives = .triangles(indices)
        if !materials.isEmpty {
            descr.materials = MeshDescriptor.Materials.perFace(materials)
        }
        return try .generate(from: [descr])
    }
}
