//
//  MeshResource+PlatonicSolids.swift
//  RealityGeometry
//
//  Created by CoderXu on 2022/4/5.
//

import RealityKit

extension MeshResource {
    /// 正四面体，radius 为外接球半径，res 三角面剖分次数
    public static func generateTetrahedron(radius: Float, res: Int = 0) throws -> MeshResource {
        let pointCount = 4
        var triangles = 4
        var vertices = pointCount * 3
        
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var normals: [SIMD3<Float>] = Array(repeating: .zero, count: vertices)
        var textureMap: [SIMD2<Float>] = []
        
        let a: Float = 4 * radius / sqrtf(6)//棱长
        let r = radius / 3 //内切球半径
        let bz = sqrtf(2) * 2 * r
        let points: [SIMD3<Float>] = [
            SIMD3<Float>(0, radius, 0),
            SIMD3<Float>(a/2, -r, -sqrtf(2)*r),
            SIMD3<Float>(0, -r, bz),
            SIMD3<Float>(-a/2, -r, -sqrtf(2)*r)
        ]
        meshPositions.append(contentsOf: points + points + points)
        
        let index: [UInt32] = [
            0, 2, 1,
            0, 3, 2,
            0, 1, 3,
            2, 3, 1
        ]
        var countDict: [UInt32:Int] = [:]
        for ind in index {
            let count = countDict[ind] ?? 0
            indices.append(ind + UInt32(pointCount * count))
            countDict[ind] = count + 1
        }
        
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
            
            let faceNormal = simd_normalize((v0 + v1 + v2) / 3)
            normals[Int(i0)] = faceNormal
            normals[Int(i1)] = faceNormal
            normals[Int(i2)] = faceNormal
        }
        
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
                
                let faceNormal = normals[Int(i0)]
                normals.append(contentsOf: [faceNormal, faceNormal, faceNormal])
                // a
                pos = (v0 + v1) * 0.5
                meshPositions.append(pos)

                // b
                pos = (v1 + v2) * 0.5
                meshPositions.append(pos)
                
                // c
                pos = (v2 + v0) * 0.5
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
            let n = p
          
            textureMap.append(SIMD2<Float>(abs(atan2(n.x, n.z)) / .pi, 1 - acos(n.y/radius) / .pi))
        }
        descr.positions = MeshBuffers.Positions(meshPositions)
        descr.normals = MeshBuffers.Normals(normals)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        descr.primitives = .triangles(indices)
        return try MeshResource.generate(from: [descr])
    }
    /// 正六面体（立方体），radius 为外接球半径，res 四边形平面剖分次数
    public static func generateHexahedron(radius: Float, res: Int = 0) throws -> MeshResource {
        let pointCount = 8
        var quads = 6
        var vertices = pointCount * 3
        
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var normals: [SIMD3<Float>] = Array(repeating: .zero, count: vertices)
        var textureMap: [SIMD2<Float>] = []
        
        let a: Float = 2 * radius / sqrtf(3)//棱长
        let r = a / 2 //内切球半径
        let points: [SIMD3<Float>] = [
            SIMD3<Float>(r, r, r),
            SIMD3<Float>(-r, r, r),
            SIMD3<Float>(-r, r, -r),
            SIMD3<Float>(r, r, -r),
            
            SIMD3<Float>(r, -r, r),
            SIMD3<Float>(-r, -r, r),
            SIMD3<Float>(-r, -r, -r),
            SIMD3<Float>(r, -r, -r),
        ]
        meshPositions.append(contentsOf: points + points + points)
        
        let index: [UInt32] = [
            3, 2, 1, 0,
            4, 5, 6, 7,
            
            3, 0, 4, 7,
            1, 2, 6, 5,
            
            0, 1, 5, 4,
            2, 3, 7, 6
        ]
        var countDict: [UInt32:Int] = [:]
        for ind in index {
            let count = countDict[ind] ?? 0
            indices.append(ind + UInt32(pointCount * count))
            countDict[ind] = count + 1
        }
        
        for i in 0..<quads {
            let ai = 4 * i
            let bi = 4 * i + 1
            let ci = 4 * i + 2
            let di = 4 * i + 3
            
            let i0 = indices[ai]
            let i1 = indices[bi]
            let i2 = indices[ci]
            let i3 = indices[di]
            
            let v0 = meshPositions[Int(i0)]
            let v1 = meshPositions[Int(i1)]
            let v2 = meshPositions[Int(i2)]
            let v3 = meshPositions[Int(i3)]
            
            let faceNormal = simd_normalize((v0 + v1 + v2 + v3) / 4)
            normals[Int(i0)] = faceNormal
            normals[Int(i1)] = faceNormal
            normals[Int(i2)] = faceNormal
            normals[Int(i3)] = faceNormal
        }
        
        for _ in 0..<res {
            let newQuads = quads * 4
            let newVertices = vertices + quads * 5
            
            var newIndices: [UInt32] = []
            var pos: SIMD3<Float>
            
            for i in 0..<quads {
                let ai = 4 * i
                let bi = 4 * i + 1
                let ci = 4 * i + 2
                let di = 4 * i + 3
                
                let i0 = indices[ai]
                let i1 = indices[bi]
                let i2 = indices[ci]
                let i3 = indices[di]
                
                let v0 = meshPositions[Int(i0)]
                let v1 = meshPositions[Int(i1)]
                let v2 = meshPositions[Int(i2)]
                let v3 = meshPositions[Int(i3)]
                
                let faceNormal = normals[Int(i0)]
                normals.append(contentsOf: [faceNormal, faceNormal, faceNormal, faceNormal, faceNormal])
                
                pos = (v0 + v1) / 2
                meshPositions.append(pos)
                
                pos = (v1 + v2) / 2
                meshPositions.append(pos)
                
                pos = (v2 + v3) / 2
                meshPositions.append(pos)
                
                pos = (v0 + v3) / 2
                meshPositions.append(pos)
                
                pos = (v0 + v1 + v2 + v3) / 4
                meshPositions.append(pos)

                
                let a = UInt32(5 * i + vertices)
                let b = UInt32(5 * i + 1 + vertices)
                let c = UInt32(5 * i + 2 + vertices)
                let d = UInt32(5 * i + 3 + vertices)
                let center = UInt32(5 * i + 4 + vertices)
                newIndices.append(contentsOf: [
                    i0, a, center, d,
                    a, i1, b, center,
                    center, b, i2, c,
                    d, center, c, i3
                ])
            }
            
            indices = newIndices
            quads = newQuads
            vertices = newVertices
        }
        
        for i in 0..<meshPositions.count {
            let p = meshPositions[i]
            let n = p
          
            textureMap.append(SIMD2<Float>(abs(atan2(n.x, n.z)) / .pi, 1 - acos(n.y/radius) / .pi))
        }
        descr.positions = MeshBuffers.Positions(meshPositions)
        descr.normals = MeshBuffers.Normals(normals)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        descr.primitives = .trianglesAndQuads(triangles: [], quads: indices)
        return try MeshResource.generate(from: [descr])
    }
    /// 正八面体，radius 为外接球半径，res 三角面剖分次数
    public static func generateOctahedron(radius: Float, res: Int = 0) throws -> MeshResource {
        let pointCount = 6
        var triangles = 8
        var vertices = pointCount * 4
        
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var normals: [SIMD3<Float>] = Array(repeating: .zero, count: vertices)
        var textureMap: [SIMD2<Float>] = []
        
        let a: Float = radius * sqrtf(2)//棱长
        let rm = a / 2 // 中交球半径(过棱中点)
        let points: [SIMD3<Float>] = [
            SIMD3<Float>(0, radius, 0),
            SIMD3<Float>(rm, 0, rm),
            SIMD3<Float>(-rm, 0, rm),
            SIMD3<Float>(-rm, 0, -rm),
            SIMD3<Float>(rm, 0, -rm),
            SIMD3<Float>(0, -radius, 0)
        ]
        meshPositions.append(contentsOf: points + points + points + points)
        
        let index: [UInt32] = [
            0, 2, 1,
            0, 3, 2,
            0, 4, 3,
            0, 1, 4,
            
            5, 1, 2,
            5, 2, 3,
            5, 3, 4,
            5, 4, 1
        ]
        var countDict: [UInt32:Int] = [:]
        for ind in index {
            let count = countDict[ind] ?? 0
            indices.append(ind + UInt32(pointCount * count))
            countDict[ind] = count + 1
        }
        
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
            
            let faceNormal = simd_normalize((v0 + v1 + v2) / 3)
            normals[Int(i0)] = faceNormal
            normals[Int(i1)] = faceNormal
            normals[Int(i2)] = faceNormal
        }
        
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
                
                let faceNormal = normals[Int(i0)]
                normals.append(contentsOf: [faceNormal, faceNormal, faceNormal])
                // a
                pos = (v0 + v1) * 0.5
                meshPositions.append(pos)

                // b
                pos = (v1 + v2) * 0.5
                meshPositions.append(pos)
                
                // c
                pos = (v2 + v0) * 0.5
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
            let n = p
          
            textureMap.append(SIMD2<Float>(abs(atan2(n.x, n.z)) / .pi, 1 - acos(n.y/radius) / .pi))
        }
        descr.positions = MeshBuffers.Positions(meshPositions)
        descr.normals = MeshBuffers.Normals(normals)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        descr.primitives = .triangles(indices)
        return try MeshResource.generate(from: [descr])
    }
    /// 正十二面体，radius 为外接球半径，res 五边形面剖分次数
    public static func generateDodecahedron(radius: Float, res: Int = 0) throws -> MeshResource {
        let pointCount = 20
        let pentagons = 12
        var vertices = pointCount * 3
        
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var normals: [SIMD3<Float>] = Array(repeating: .zero, count: vertices)
        var textureMap: [SIMD2<Float>] = []
        
        let phi = (1.0 + sqrtf(5)) * 0.5
        let a = (sqrtf(5) - 1) / sqrtf(3) * radius //棱长
        let h =  phi / sqrtf(3) * radius //中交球半径
        let w = a / 2
        let v = radius / sqrtf(3)

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
            SIMD3<Float>(w, 0.0, h),
            
            SIMD3<Float>(v, v, v),//12
            SIMD3<Float>(-v, v, v),
            SIMD3<Float>(-v, v, -v),
            SIMD3<Float>(v, v, -v),
            
            SIMD3<Float>(v, -v, v),//16
            SIMD3<Float>(-v, -v, v),
            SIMD3<Float>(-v, -v, -v),
            SIMD3<Float>(v, -v, -v),
        ]
        meshPositions.append(contentsOf: points + points + points)
        
        let index: [UInt32] = [
            0, 1, 14, 7, 13,
            1, 0, 12, 5, 15,
            3, 2, 17, 6, 18,
            2, 3, 16, 4, 19,
            
            4, 5, 12, 11, 16,
            5, 4, 19, 9, 15,
            7, 6, 17, 10, 13,
            6, 7, 14, 8, 18,
            
            8, 9, 19, 3, 18,
            9, 8, 14, 1, 15,
            11, 10, 17, 2, 16,
            10, 11, 12, 0, 13
        ]
        var countDict: [UInt32:Int] = [:]
        for ind in index {
            let count = countDict[ind] ?? 0
            indices.append(ind + UInt32(pointCount * count))
            countDict[ind] = count + 1
        }
        
        var newIndices1: [UInt32] = []
        for i in 0..<pentagons {
            let ai = 5 * i
            let bi = 5 * i + 1
            let ci = 5 * i + 2
            let di = 5 * i + 3
            let ei = 5 * i + 4
            
            let i0 = indices[ai]
            let i1 = indices[bi]
            let i2 = indices[ci]
            let i3 = indices[di]
            let i4 = indices[ei]
            
            let v0 = meshPositions[Int(i0)]
            let v1 = meshPositions[Int(i1)]
            let v2 = meshPositions[Int(i2)]
            let v3 = meshPositions[Int(i3)]
            let v4 = meshPositions[Int(i4)]
            
            let faceCenter = (v0 + v1 + v2 + v3 + v4) / 5
            let faceNormal = simd_normalize(faceCenter)
            normals[Int(i0)] = faceNormal
            normals[Int(i1)] = faceNormal
            normals[Int(i2)] = faceNormal
            normals[Int(i3)] = faceNormal
            normals[Int(i4)] = faceNormal
            
            if res > 0 {
                meshPositions.append(faceCenter)
                normals.append(faceNormal)
                
                let center = UInt32(vertices + i)
                newIndices1.append(contentsOf: [
                    i0, i1, center,
                    i1, i2, center,
                    i2, i3, center,
                    i3, i4, center,
                    i4, i0, center
                ])
            }
        }
        
        if res > 0 {
            vertices += pentagons
            indices = newIndices1
        }
        if res > 1 {
            var triangles = pentagons * 5
            for _ in 1..<res {
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
                    
                    let faceNormal = normals[Int(i0)]
                    normals.append(contentsOf: [faceNormal, faceNormal, faceNormal])
                    // a
                    pos = (v0 + v1) * 0.5
                    meshPositions.append(pos)
                    
                    // b
                    pos = (v1 + v2) * 0.5
                    meshPositions.append(pos)
                    
                    // c
                    pos = (v2 + v0) * 0.5
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
        }
        
        for i in 0..<meshPositions.count {
            let p = meshPositions[i]
            let n = p
          
            textureMap.append(SIMD2<Float>(abs(atan2(n.x, n.z)) / .pi, 1 - acos(n.y/radius) / .pi))
        }
        
        descr.positions = MeshBuffers.Positions(meshPositions)
        descr.normals = MeshBuffers.Normals(normals)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        if res == 0 {
            descr.primitives = .polygons(Array(repeating: 5, count: pentagons), indices)
        } else {
            descr.primitives = .triangles(indices)
        }
        return try MeshResource.generate(from: [descr])
    }
    /// 正二十面体，，radius 为外接球半径，res 三角形面剖分次数
    public static func generateIcosahedron(radius: Float, res: Int = 0) throws -> MeshResource {
        let pointCount = 12
        var triangles = 20
        var vertices = pointCount * 5
        
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var normals: [SIMD3<Float>] = Array(repeating: .zero, count: vertices)
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
        meshPositions.append(contentsOf: points + points + points + points + points)
        
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
        var countDict: [UInt32:Int] = [:]
        for ind in index {
            let count = countDict[ind] ?? 0
            indices.append(ind + UInt32(pointCount * count))
            countDict[ind] = count + 1
        }
        
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
            
            let faceNormal = simd_normalize((v0 + v1 + v2) / 3)
            normals[Int(i0)] = faceNormal
            normals[Int(i1)] = faceNormal
            normals[Int(i2)] = faceNormal
        }
        
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
                
                let faceNormal = normals[Int(i0)]
                normals.append(contentsOf: [faceNormal, faceNormal, faceNormal])
                // a
                pos = (v0 + v1) * 0.5
                meshPositions.append(pos)

                // b
                pos = (v1 + v2) * 0.5
                meshPositions.append(pos)
                
                // c
                pos = (v2 + v0) * 0.5
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
            let n = p
          
            textureMap.append(SIMD2<Float>(abs(atan2(n.x, n.z)) / .pi, 1 - acos(n.y/radius) / .pi))
        }
        
        descr.positions = MeshBuffers.Positions(meshPositions)
        descr.normals = MeshBuffers.Normals(normals)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        descr.primitives = .triangles(indices)
        return try MeshResource.generate(from: [descr])
    }
}
