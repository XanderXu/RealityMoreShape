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
    
    public static func generateGeoSphereAsync(radius: Float, res: Int = 0) async throws -> MeshResource {
        let pointCount = 12
        var triangles = 20
        var vertices = pointCount
        
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
        
        // Create a single part for the geosphere
        var part = MeshResource.Part(id: "GeoSphere", materialIndex: 0)
        part.triangleIndices = .init(indices)
        part.textureCoordinates = .init(textureMap)
        part.normals = .init(normals)
        part.positions = .init(meshPositions)
        
        let model = MeshResource.Model(id: "GeoSphereModel", parts: [part])
        let instance = MeshResource.Instance(id: "GeoSphereModel-0", model: "GeoSphereModel")
        
        var contents = MeshResource.Contents()
        contents.instances = .init([instance])
        contents.models = .init([model])
        
        return try await MeshResource(from: contents)
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
    
    public static func generateCubeSphereAsync(radius: Float, resolution: Int = 10, splitFaces: Bool = false) async throws -> MeshResource {
        if splitFaces {
            // For splitFaces, we create separate parts for each pair of opposite faces
            // Part 0: X faces (+X and -X)
            var meshPositions0: [SIMD3<Float>] = []
            var indices0: [UInt32] = []
            var normals0: [SIMD3<Float>] = []
            var textureMap0: [SIMD2<Float>] = []
            
            // Part 1: Y faces (+Y and -Y)
            var meshPositions1: [SIMD3<Float>] = []
            var indices1: [UInt32] = []
            var normals1: [SIMD3<Float>] = []
            var textureMap1: [SIMD2<Float>] = []
            
            // Part 2: Z faces (+Z and -Z)
            var meshPositions2: [SIMD3<Float>] = []
            var indices2: [UInt32] = []
            var normals2: [SIMD3<Float>] = []
            var textureMap2: [SIMD2<Float>] = []
            
            let edge = resolution > 2 ? resolution : 3
            let edgeMinusOne = edge - 1
            let edgeMinusOnef = Float(edgeMinusOne)
            let edgeMinusOneSqr = edgeMinusOne * edgeMinusOne
            
            let edgeInc = 2 * radius / edgeMinusOnef
            let facePointCount = edge * edge
            
            // +X face (Part 0)
            for j in 0..<edge {
                let startY = radius
                let startZ = radius
                let jf = Float(j)
                let uvy = jf / edgeMinusOnef
                for i in 0..<edge {
                    let p = SIMD3<Float>(radius, startY - edgeInc * jf, startZ - edgeInc * Float(i))
                    meshPositions0.append(p)
                    
                    let uv = SIMD2<Float>(Float(i) / edgeMinusOnef, 1 - uvy)
                    textureMap0.append(uv)
                    
                    if j != edgeMinusOne && i != edgeMinusOne {
                        let index = UInt32(i + j * edge)
                        
                        let tl = index
                        let tr = tl + 1
                        let bl = index + UInt32(edge)
                        let br = bl + 1
                        
                        indices0.append(contentsOf: [tl,bl,tr,
                                                    tr,bl,br])
                    }
                }
            }
            
            // -X face (Part 0)
            for j in 0..<edge {
                let startY = radius
                let startZ = -radius
                let jf = Float(j)
                let uvy = jf / edgeMinusOnef
                for i in 0..<edge {
                    let p = SIMD3<Float>(-radius, startY - edgeInc * jf, startZ + edgeInc * Float(i))
                    meshPositions0.append(p)
                    
                    let uv = SIMD2<Float>(Float(i) / edgeMinusOnef, 1 - uvy)
                    textureMap0.append(uv)
                    
                    if j != edgeMinusOne && i != edgeMinusOne {
                        let index = UInt32(i + j * edge + facePointCount)
                        
                        let tl = index
                        let tr = tl + 1
                        let bl = index + UInt32(edge)
                        let br = bl + 1
                        
                        indices0.append(contentsOf: [tl,bl,tr,
                                                    tr,bl,br])
                    }
                }
            }
            
            // +Y face (Part 1)
            for j in 0..<edge {
                let startX = -radius
                let startZ = -radius
                let jf = Float(j)
                let uvy = jf / edgeMinusOnef
                for i in 0..<edge {
                    let p = SIMD3<Float>(startX + edgeInc * Float(i), radius, startZ + edgeInc * jf)
                    meshPositions1.append(p)
                    
                    let uv = SIMD2<Float>(Float(i) / edgeMinusOnef, 1 - uvy)
                    textureMap1.append(uv)
                    
                    if j != edgeMinusOne && i != edgeMinusOne {
                        let index = UInt32(i + j * edge)
                        
                        let tl = index
                        let tr = tl + 1
                        let bl = index + UInt32(edge)
                        let br = bl + 1
                        
                        indices1.append(contentsOf: [tl,bl,tr,
                                                    tr,bl,br])
                    }
                }
            }
            
            // -Y face (Part 1)
            for j in 0..<edge {
                let startX = radius
                let startZ = -radius
                let jf = Float(j)
                let uvy = jf / edgeMinusOnef
                for i in 0..<edge {
                    let p = SIMD3<Float>(startX - edgeInc * Float(i), -radius, startZ + edgeInc * jf)
                    meshPositions1.append(p)
                    
                    let uv = SIMD2<Float>(Float(i) / edgeMinusOnef, 1 - uvy)
                    textureMap1.append(uv)
                    
                    if j != edgeMinusOne && i != edgeMinusOne {
                        let index = UInt32(i + j * edge + facePointCount)
                        
                        let tl = index
                        let tr = tl + 1
                        let bl = index + UInt32(edge)
                        let br = bl + 1
                        
                        indices1.append(contentsOf: [tl,bl,tr,
                                                    tr,bl,br])
                    }
                }
            }
            
            // +Z face (Part 2)
            for j in 0..<edge {
                let startY = radius
                let startX = -radius
                let jf = Float(j)
                let uvy = jf / edgeMinusOnef
                for i in 0..<edge {
                    let p = SIMD3<Float>(startX + edgeInc * Float(i), startY - edgeInc * jf, radius)
                    meshPositions2.append(p)
                    
                    let uv = SIMD2<Float>(Float(i) / edgeMinusOnef, 1 - uvy)
                    textureMap2.append(uv)
                    
                    if j != edgeMinusOne && i != edgeMinusOne {
                        let index = UInt32(i + j * edge)
                        
                        let tl = index
                        let tr = tl + 1
                        let bl = index + UInt32(edge)
                        let br = bl + 1
                        
                        indices2.append(contentsOf: [tl,bl,tr,
                                                    tr,bl,br])
                    }
                }
            }
            
            // -Z face (Part 2)
            for j in 0..<edge {
                let startY = radius
                let startX = radius
                let jf = Float(j)
                let uvy = jf / edgeMinusOnef
                for i in 0..<edge {
                    let p = SIMD3<Float>(startX - edgeInc * Float(i), startY - edgeInc * jf, -radius)
                    meshPositions2.append(p)
                    
                    let uv = SIMD2<Float>(Float(i) / edgeMinusOnef, 1 - uvy)
                    textureMap2.append(uv)
                    
                    if j != edgeMinusOne && i != edgeMinusOne {
                        let index = UInt32(i + j * edge + facePointCount)
                        
                        let tl = index
                        let tr = tl + 1
                        let bl = index + UInt32(edge)
                        let br = bl + 1
                        
                        indices2.append(contentsOf: [tl,bl,tr,
                                                    tr,bl,br])
                    }
                }
            }
            
            // Calculate normals and rounded positions for all vertices
            var allMeshPositions: [SIMD3<Float>] = []
            allMeshPositions.append(contentsOf: meshPositions0)
            allMeshPositions.append(contentsOf: meshPositions1)
            allMeshPositions.append(contentsOf: meshPositions2)
            
            var roundPositions: [SIMD3<Float>] = []
            var normals: [SIMD3<Float>] = []
            for p in allMeshPositions {
                let n = simd_normalize(p)
                let n2 = n * n
                
                let x = n.x * sqrtf(1 - (n2.y + n2.z) / 2 + n2.y * n2.z / 3)
                let y = n.y * sqrtf(1 - (n2.x + n2.z) / 2 + n2.x * n2.z / 3)
                let z = n.z * sqrtf(1 - (n2.x + n2.y) / 2 + n2.x * n2.y / 3)
                
                let newN = simd_normalize(SIMD3<Float>(x, y, z))
                normals.append(newN)
                
                roundPositions.append(newN * radius)
            }
            
            // Split the rounded positions back to each part
            let xVertexCount = meshPositions0.count
            let yVertexCount = meshPositions1.count
            let zVertexCount = meshPositions2.count
            
            meshPositions0 = Array(roundPositions[0..<xVertexCount])
            meshPositions1 = Array(roundPositions[xVertexCount..<(xVertexCount+yVertexCount)])
            meshPositions2 = Array(roundPositions[(xVertexCount+yVertexCount)..<(xVertexCount+yVertexCount+zVertexCount)])
            
            // Split the normals back to each part
            normals0 = Array(normals[0..<xVertexCount])
            normals1 = Array(normals[xVertexCount..<(xVertexCount+yVertexCount)])
            normals2 = Array(normals[(xVertexCount+yVertexCount)..<(xVertexCount+yVertexCount+zVertexCount)])
            
            // Create parts with appropriate material indices
            var part0 = MeshResource.Part(id: "CubeSphereX", materialIndex: 0) // X faces
            part0.triangleIndices = .init(indices0)
            part0.textureCoordinates = .init(textureMap0)
            part0.normals = .init(normals0)
            part0.positions = .init(meshPositions0)
            
            var part1 = MeshResource.Part(id: "CubeSphereY", materialIndex: 1) // Y faces
            part1.triangleIndices = .init(indices1)
            part1.textureCoordinates = .init(textureMap1)
            part1.normals = .init(normals1)
            part1.positions = .init(meshPositions1)
            
            var part2 = MeshResource.Part(id: "CubeSphereZ", materialIndex: 2) // Z faces
            part2.triangleIndices = .init(indices2)
            part2.textureCoordinates = .init(textureMap2)
            part2.normals = .init(normals2)
            part2.positions = .init(meshPositions2)
            
            let parts = [part0, part1, part2]
            
            let model = MeshResource.Model(id: "CubeSphereModel", parts: parts)
            let instance = MeshResource.Instance(id: "CubeSphereModel-0", model: "CubeSphereModel")
            
            var contents = MeshResource.Contents()
            contents.instances = .init([instance])
            contents.models = .init([model])
            
            return try await MeshResource(from: contents)
        } else {
            // Non-splitFaces version - single part with all geometry
            var meshPositions: [SIMD3<Float>] = []
            var indices: [UInt32] = []
            var normals: [SIMD3<Float>] = []
            var textureMap: [SIMD2<Float>] = []
            
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
            
            // Create a single part for the cube sphere
            var part = MeshResource.Part(id: "CubeSphere", materialIndex: 0)
            part.triangleIndices = .init(indices)
            part.textureCoordinates = .init(textureMap)
            part.normals = .init(normals)
            part.positions = .init(meshPositions)
            
            let model = MeshResource.Model(id: "CubeSphereModel", parts: [part])
            let instance = MeshResource.Instance(id: "CubeSphereModel-0", model: "CubeSphereModel")
            
            var contents = MeshResource.Contents()
            contents.instances = .init([instance])
            contents.models = .init([model])
            
            return try await MeshResource(from: contents)
        }
    }
}
