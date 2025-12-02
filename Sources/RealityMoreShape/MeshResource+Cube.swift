//
//  MeshResource+Cube.swift
//  RealityGeometry
//
//  Created by 许 on 2022/4/2.
//

import RealityKit

extension MeshResource {
    public static func generateExtrudedRoundedRectPad(width: Float, height: Float, depth: Float, radius: Float, angularResolution: Int = 6, edgeXResolution: Int = 2, edgeYResolution: Int = 2, depthResolution: Int = 2, radialResolution: Int = 2, splitFaces: Bool = false, circleUV: Bool = false) throws -> MeshResource {
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var normals: [SIMD3<Float>] = []
        var textureMap: [SIMD2<Float>] = []
        var materials: [UInt32] = []
        
        let halfDepth = depth * 0.5
        
        let datas = generateRoundedRectPlaneDatas(width: width, height: height, radius: radius, angularResolution: angularResolution, edgeXResolution: edgeXResolution, edgeYResolution: edgeYResolution, radialResolution: radialResolution, circleUV: circleUV)
        let planePositionsCount = datas.meshPositions.count
        
        let topMeshPositions = datas.meshPositions.map({ p in
            return p + SIMD3<Float>(0, halfDepth, 0)
        })
        meshPositions.append(contentsOf: topMeshPositions)
        let bottomMeshPositions = datas.meshPositions.map({ p in
            return p + SIMD3<Float>(0, -halfDepth, 0)
        })
        meshPositions.append(contentsOf: bottomMeshPositions)
        
        normals.append(contentsOf: Array(repeating: SIMD3<Float>(0, 1, 0), count: planePositionsCount))
        normals.append(contentsOf: Array(repeating: SIMD3<Float>(0, -1, 0), count: planePositionsCount))
        
        textureMap.append(contentsOf: datas.textureMap)
        textureMap.append(contentsOf: datas.textureMap.map({ uv in
            return uv * SIMD2<Float>(-1, 1) + SIMD2<Float>(1, 0)
        }))
        
        indices.append(contentsOf: datas.indices)
        var reverseIndices: [UInt32] = []
        let bottomTriangleCount = datas.indices.count / 3
        for i in 1...bottomTriangleCount {
            reverseIndices.append(contentsOf: [
                datas.indices[i*3-1] + UInt32(planePositionsCount),
                datas.indices[i*3-2] + UInt32(planePositionsCount),
                datas.indices[i*3-3] + UInt32(planePositionsCount)])
        }
        indices.append(contentsOf: reverseIndices)
        
        if splitFaces {
            materials.append(contentsOf: Array(repeating: 1, count: bottomTriangleCount * 2))
        }
        
        let angular = angularResolution > 2 ? angularResolution : 3
        let edgeX = edgeXResolution > 1 ? edgeXResolution : 2
        let edgeY = edgeYResolution > 1 ? edgeYResolution : 2
        let edgeDepth = depthResolution > 1 ? depthResolution : 2
        
        let widthHalf = width * 0.5
        let heightHalf = height * 0.5
        let minDim = (widthHalf < heightHalf ? widthHalf : heightHalf)
        let radius = radius > minDim ? minDim : radius
        let innerWidth = width - radius * 2
        let innerHeight = height - radius * 2
        
        // 强行在 x 轴正方向插入 2 个点，以使 UV 在此处发生突变
        let perLoop = (angular - 2) * 4 + (edgeX * 2) + (edgeY * 2) + 2
        let perimeter = innerWidth * 2 + innerHeight * 2 + .pi * radius * 2
        var bottomOutPositions = Array(bottomMeshPositions[(planePositionsCount - perLoop + (circleUV ? 0 : 2))...])
        if !circleUV {//start and end UVs are different, so add more points
            bottomOutPositions.insert(contentsOf: [SIMD3<Float>(widthHalf, -halfDepth, 0), SIMD3<Float>(widthHalf, -halfDepth, 0)], at: edgeY/2)
        }
        
        let depthInc = depth / Float(edgeDepth-1)
        let angularInc = .pi * radius * 0.5 / Float(angular - 1)
        let innerWidthHalf = widthHalf - radius
        let innerHeightHalf = heightHalf - radius
        
        // 计算关键点，即直线与圆弧连接处，共 8 个连接点
        let index1 = edgeY + 2
        let keyIndexes = [0,
                          index1 - 1,
                          index1 + angular - 2,
                          index1 + angular + edgeX - 3,
                          index1 + angular * 2 + edgeX - 4,
                          index1 + angular * 2 + edgeX + edgeY - 5,
                          index1 + angular * 3 + edgeX + edgeY - 6,
                          index1 + angular * 3 + edgeX * 2 + edgeY - 7
        ]
        // 关键点对应的周长
        let keyLengths = [0,
                          innerHeight,
                          innerHeight + .pi * radius * 0.5,
                          innerHeight + innerWidth + .pi * radius * 0.5,
                          innerHeight + innerWidth + .pi * radius,
                          innerHeight * 2 + innerWidth + .pi * radius,
                          innerHeight * 2 + innerWidth + .pi * radius * 1.5,
                          innerHeight * 2 + innerWidth * 2 + .pi * radius * 1.5,
        ]
        let topBottomPositionsCount = UInt32(planePositionsCount * 2)
        
        for j in 0..<edgeDepth {
            let jf = Float(j)
            let d = jf * depthInc
            let uvy = jf / Float(edgeDepth-1)
            let curLoop = j * perLoop
            let nextLoop = (j + 1) * perLoop
            
            for i in 0..<perLoop {
                let p = bottomOutPositions[i]
                meshPositions.append(p + SIMD3<Float>(0, d, 0))
                
                let inner = p.clamped(lowerBound: SIMD3<Float>(-innerWidthHalf, 0, -innerHeightHalf), upperBound: SIMD3<Float>(innerWidthHalf, 0, innerHeightHalf))
                let n = simd_normalize(p - inner)
                normals.append(n)
                
                var length: Float = -innerHeightHalf
                if i <= keyIndexes[1] {
                    if i <= edgeY/2 {
                        length += perimeter
                    }
                    length += keyLengths[0] + abs(p.z - bottomOutPositions[0].z)
                } else if i <= keyIndexes[2] {
                    length += keyLengths[1] + angularInc * Float(i - keyIndexes[1])
                } else if i <= keyIndexes[3] {
                    length += keyLengths[2] + abs(p.x - bottomOutPositions[keyIndexes[2]].x)
                } else if i <= keyIndexes[4] {
                    length += keyLengths[3] + angularInc * Float(i - keyIndexes[3])
                } else if i <= keyIndexes[5] {
                    length += keyLengths[4] + abs(p.z - bottomOutPositions[keyIndexes[4]].z)
                } else if i <= keyIndexes[6] {
                    length += keyLengths[5] + angularInc * Float(i - keyIndexes[5])
                } else if i <= keyIndexes[7] {
                    length += keyLengths[6] + abs(p.x - bottomOutPositions[keyIndexes[6]].x)
                } else {
                    length += keyLengths[7] + angularInc * Float(i - keyIndexes[7])
                }
                textureMap.append(SIMD2<Float>( 1 - length / perimeter, uvy))
                
                
                var prev = i - 1
                prev = prev < 0 ? (perLoop - 1) : prev
                let curr = i
                let next = (i + 1) % perLoop
                
                if j != edgeDepth - 1 {
                    let i0 = UInt32(curLoop + curr) + topBottomPositionsCount
                    let i1 = UInt32(curLoop + next) + topBottomPositionsCount
                    
                    let i2 = UInt32(nextLoop + curr) + topBottomPositionsCount
                    let i3 = UInt32(nextLoop + next) + topBottomPositionsCount
                    indices.append(contentsOf: [
                        i0, i2, i3,
                        i0, i3, i1
                    ])
                }
            }
        }
        
        if splitFaces {
            materials.append(contentsOf: Array(repeating: 0, count: edgeDepth * perLoop * 2))
        }
        
        descr.positions = MeshBuffers.Positions(meshPositions)
        descr.normals = MeshBuffers.Normals(normals)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        descr.primitives = .triangles(indices)
        if !materials.isEmpty {
            descr.materials = MeshDescriptor.Materials.perFace(materials)
        }
        return try .generate(from: [descr])
    }
    
    public static func generateExtrudedRoundedRectPadAsync(width: Float, height: Float, depth: Float, radius: Float, angularResolution: Int = 6, edgeXResolution: Int = 2, edgeYResolution: Int = 2, depthResolution: Int = 2, radialResolution: Int = 2, splitFaces: Bool = false, circleUV: Bool = false) async throws -> MeshResource {
        // Create separate arrays for top/bottom faces and side faces to enable parallel processing
        var meshPositions0: [SIMD3<Float>] = []
        var indices0: [UInt32] = []
        var normals0: [SIMD3<Float>] = []
        var textureMap0: [SIMD2<Float>] = []
        
        var meshPositions1: [SIMD3<Float>] = []
        var indices1: [UInt32] = []
        var normals1: [SIMD3<Float>] = []
        var textureMap1: [SIMD2<Float>] = []
        
        var meshPositions2: [SIMD3<Float>] = []
        var indices2: [UInt32] = []
        var normals2: [SIMD3<Float>] = []
        var textureMap2: [SIMD2<Float>] = []
        
        let halfDepth = depth * 0.5
        
        // Generate rounded rectangle plane data for top and bottom faces
        let datas = generateRoundedRectPlaneDatas(width: width, height: height, radius: radius, angularResolution: angularResolution, edgeXResolution: edgeXResolution, edgeYResolution: edgeYResolution, radialResolution: radialResolution, circleUV: circleUV)
        let planePositionsCount = datas.meshPositions.count
        
        // Top face positions
        let topMeshPositions = datas.meshPositions.map({ p in
            return p + SIMD3<Float>(0, halfDepth, 0)
        })
        meshPositions0.append(contentsOf: topMeshPositions)
        
        // Bottom face positions
        let bottomMeshPositions = datas.meshPositions.map({ p in
            return p + SIMD3<Float>(0, -halfDepth, 0)
        })
        meshPositions1.append(contentsOf: bottomMeshPositions)
        
        // Top face normals (all pointing up)
        normals0.append(contentsOf: Array(repeating: SIMD3<Float>(0, 1, 0), count: planePositionsCount))
        
        // Bottom face normals (all pointing down)
        normals1.append(contentsOf: Array(repeating: SIMD3<Float>(0, -1, 0), count: planePositionsCount))
        
        // Texture coordinates for top face
        textureMap0.append(contentsOf: datas.textureMap)
        
        // Texture coordinates for bottom face (flipped U coordinate)
        textureMap1.append(contentsOf: datas.textureMap.map({ uv in
            return uv * SIMD2<Float>(-1, 1) + SIMD2<Float>(1, 0)
        }))
        
        // Top face indices
        indices0.append(contentsOf: datas.indices)
        
        // Bottom face indices (reversed winding order)
        var reverseIndices: [UInt32] = []
        let bottomTriangleCount = datas.indices.count / 3
        for i in 1...bottomTriangleCount {
            // In the async version, we don't need to add planePositionsCount offset
            // because indices0 refers to vertices in meshPositions0 array directly
            reverseIndices.append(contentsOf: [
                datas.indices[i*3-1],
                datas.indices[i*3-2],
                datas.indices[i*3-3]])
        }
        indices1.append(contentsOf: reverseIndices)
        
        // Side faces
        let angular = angularResolution > 2 ? angularResolution : 3
        let edgeX = edgeXResolution > 1 ? edgeXResolution : 2
        let edgeY = edgeYResolution > 1 ? edgeYResolution : 2
        let edgeDepth = depthResolution > 1 ? depthResolution : 2
        
        let widthHalf = width * 0.5
        let heightHalf = height * 0.5
        let minDim = (widthHalf < heightHalf ? widthHalf : heightHalf)
        let radiusValue = radius > minDim ? minDim : radius
        let innerWidth = width - radiusValue * 2
        let innerHeight = height - radiusValue * 2
        
        // 强行在 x 轴正方向插入 2 个点，以使 UV 在此处发生突变
        let perLoop = (angular - 2) * 4 + (edgeX * 2) + (edgeY * 2) + 2
        let perimeter = innerWidth * 2 + innerHeight * 2 + .pi * radiusValue * 2
        var bottomOutPositions = Array(bottomMeshPositions[(planePositionsCount - perLoop + (circleUV ? 0 : 2))...])
        if !circleUV {//start and end UVs are different, so add more points
            bottomOutPositions.insert(contentsOf: [SIMD3<Float>(widthHalf, -halfDepth, 0), SIMD3<Float>(widthHalf, -halfDepth, 0)], at: edgeY/2)
        }
        
        let depthInc = depth / Float(edgeDepth-1)
        let angularInc = .pi * radiusValue * 0.5 / Float(angular - 1)
        let innerWidthHalf = widthHalf - radiusValue
        let innerHeightHalf = heightHalf - radiusValue
        
        // 计算关键点，即直线与圆弧连接处，共 8 个连接点
        let index1 = edgeY + 2
        let keyIndexes = [0,
                          index1 - 1,
                          index1 + angular - 2,
                          index1 + angular + edgeX - 3,
                          index1 + angular * 2 + edgeX - 4,
                          index1 + angular * 2 + edgeX + edgeY - 5,
                          index1 + angular * 3 + edgeX + edgeY - 6,
                          index1 + angular * 3 + edgeX * 2 + edgeY - 7
        ]
        // 关键点对应的周长
        let keyLengths = [0,
                          innerHeight,
                          innerHeight + .pi * radiusValue * 0.5,
                          innerHeight + innerWidth + .pi * radiusValue * 0.5,
                          innerHeight + innerWidth + .pi * radiusValue,
                          innerHeight * 2 + innerWidth + .pi * radiusValue,
                          innerHeight * 2 + innerWidth + .pi * radiusValue * 1.5,
                          innerHeight * 2 + innerWidth * 2 + .pi * radiusValue * 1.5,
        ]
        // In the async version, we don't have top and bottom faces in the same array,
        // so we need to adjust the index calculation accordingly
        // For side faces, indices should reference vertices in meshPositions2 array directly
        // without adding topBottomPositionsCount offset
        
        for j in 0..<edgeDepth {
            let jf = Float(j)
            let d = jf * depthInc
            let uvy = jf / Float(edgeDepth-1)
            let curLoop = j * perLoop
            let nextLoop = (j + 1) * perLoop
            
            for i in 0..<perLoop {
                let p = bottomOutPositions[i]
                meshPositions2.append(p + SIMD3<Float>(0, d, 0))
                
                let inner = p.clamped(lowerBound: SIMD3<Float>(-innerWidthHalf, 0, -innerHeightHalf), upperBound: SIMD3<Float>(innerWidthHalf, 0, innerHeightHalf))
                let n = simd_normalize(p - inner)
                normals2.append(n)
                
                var length: Float = -innerHeightHalf
                if i <= keyIndexes[1] {
                    if i <= edgeY/2 {
                        length += perimeter
                    }
                    length += keyLengths[0] + abs(p.z - bottomOutPositions[0].z)
                } else if i <= keyIndexes[2] {
                    length += keyLengths[1] + angularInc * Float(i - keyIndexes[1])
                } else if i <= keyIndexes[3] {
                    length += keyLengths[2] + abs(p.x - bottomOutPositions[keyIndexes[2]].x)
                } else if i <= keyIndexes[4] {
                    length += keyLengths[3] + angularInc * Float(i - keyIndexes[3])
                } else if i <= keyIndexes[5] {
                    length += keyLengths[4] + abs(p.z - bottomOutPositions[keyIndexes[4]].z)
                } else if i <= keyIndexes[6] {
                    length += keyLengths[5] + angularInc * Float(i - keyIndexes[5])
                } else if i <= keyIndexes[7] {
                    length += keyLengths[6] + abs(p.x - bottomOutPositions[keyIndexes[6]].x)
                } else {
                    length += keyLengths[7] + angularInc * Float(i - keyIndexes[7])
                }
                textureMap2.append(SIMD2<Float>( 1 - length / perimeter, uvy))
                
                var prev = i - 1
                prev = prev < 0 ? (perLoop - 1) : prev
                let curr = i
                let next = (i + 1) % perLoop
                
                if j != edgeDepth - 1 {
                    let i0 = UInt32(curLoop + curr)
                    let i1 = UInt32(curLoop + next)
                    
                    let i2 = UInt32(nextLoop + curr)
                    let i3 = UInt32(nextLoop + next)
                    indices2.append(contentsOf: [
                        i0, i2, i3,
                        i0, i3, i1
                    ])
                }
            }
        }
        
        // Create parts for each section
        var parts: [MeshResource.Part] = []
        
        // Top face part
        var part0 = MeshResource.Part(id: "TopFace", materialIndex: splitFaces ? 1 : 0)
        part0.triangleIndices = .init(indices0)
        part0.textureCoordinates = .init(textureMap0)
        part0.normals = .init(normals0)
        part0.positions = .init(meshPositions0)
        
        // Bottom face part
        var part1 = MeshResource.Part(id: "BottomFace", materialIndex: splitFaces ? 1 : 0)
        part1.triangleIndices = .init(indices1)
        part1.textureCoordinates = .init(textureMap1)
        part1.normals = .init(normals1)
        part1.positions = .init(meshPositions1)
        
        // Side faces part
        var part2 = MeshResource.Part(id: "SideFaces", materialIndex: 0)
        part2.triangleIndices = .init(indices2)
        part2.textureCoordinates = .init(textureMap2)
        part2.normals = .init(normals2)
        part2.positions = .init(meshPositions2)
        
        if splitFaces {
            parts = [part2, part0, part1] // Side faces, top face, bottom face
        } else {
            // Merge all geometry for single material
            // Order of vertices in merged array: side faces -> top face -> bottom face
            var mergedPositions = meshPositions2 // Side faces first
            mergedPositions.append(contentsOf: meshPositions0) // Then top face
            mergedPositions.append(contentsOf: meshPositions1) // Then bottom face
            
            var mergedNormals = normals2
            mergedNormals.append(contentsOf: normals0)
            mergedNormals.append(contentsOf: normals1)
            
            var mergedTextureCoords = textureMap2
            mergedTextureCoords.append(contentsOf: textureMap0)
            mergedTextureCoords.append(contentsOf: textureMap1)
            
            // Adjust indices to account for vertex offsets in merged array
            // For side faces, indices are already correct as they reference the first set of vertices
            
            // For top face, adjust indices to account for side face vertices
            let topFaceVertexOffset = UInt32(meshPositions2.count)
            var adjustedTopIndices = indices0
            for i in 0..<adjustedTopIndices.count {
                adjustedTopIndices[i] += topFaceVertexOffset
            }
            
            // For bottom face, adjust indices to account for side face + top face vertices
            let bottomFaceVertexOffset = topFaceVertexOffset + UInt32(meshPositions0.count)
            var adjustedBottomIndices = indices1
            for i in 0..<adjustedBottomIndices.count {
                adjustedBottomIndices[i] += bottomFaceVertexOffset
            }
            
            // Combine all indices in the correct order: side faces -> top face -> bottom face
            var mergedIndices: [UInt32] = []
            mergedIndices.append(contentsOf: indices2) // Side faces indices first
            mergedIndices.append(contentsOf: adjustedTopIndices) // Then top face indices
            mergedIndices.append(contentsOf: adjustedBottomIndices) // Then bottom face indices
            
            // Create a single part with all merged data
            var singlePart = MeshResource.Part(id: "ExtrudedRoundedRectPad", materialIndex: 0)
            singlePart.triangleIndices = .init(mergedIndices)
            singlePart.textureCoordinates = .init(mergedTextureCoords)
            singlePart.normals = .init(mergedNormals)
            singlePart.positions = .init(mergedPositions)
            
            parts = [singlePart]
        }
        
        let model = MeshResource.Model(id: "ExtrudedRoundedRectPadModel", parts: parts)
        let instance = MeshResource.Instance(id: "ExtrudedRoundedRectPadModel-0", model: "ExtrudedRoundedRectPadModel")
        
        var contents = MeshResource.Contents()
        contents.instances = .init([instance])
        contents.models = .init([model])
        
        return try await MeshResource(from: contents)
    }
    
    public static func generateRoundedCube(width: Float, height: Float, depth: Float, radius: Float, widthResolution: Int = 10, heightResolution: Int = 10, depthResolution: Int = 10, splitFaces: Bool = false) throws -> MeshResource {
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var normals: [SIMD3<Float>] = []
        var textureMap: [SIMD2<Float>] = []
        var materials: [UInt32] = []
        
        let widthHalf = width * 0.5
        let heightHalf = height * 0.5
        let depthHalf = depth * 0.5
        let minDim = min(widthHalf, min(heightHalf, depthHalf))
        let radius = radius > minDim ? minDim : radius
        
        let edgeWidth = widthResolution > 1 ? widthResolution : 2
        let edgeHeight = heightResolution > 1 ? heightResolution : 2
        let edgeDepth = depthResolution > 1 ? depthResolution : 2
        
        let widthInc = width / Float(edgeWidth - 1)
        let heightInc = height / Float(edgeHeight - 1)
        let depthInc = depth / Float(edgeDepth - 1)
        
        let xPointCount = edgeDepth * edgeHeight
        let yPointCount = edgeWidth * edgeHeight
        let zPointCount = edgeDepth * edgeWidth
        // +X
        for j in 0..<edgeDepth {
            let startY = depthHalf
            let startZ = heightHalf
            let jf = Float(j)
            let uvy = jf / Float(edgeDepth - 1)
            for i in 0..<edgeHeight {
                let p = SIMD3<Float>(widthHalf, startY - depthInc * jf, startZ - heightInc * Float(i))
                meshPositions.append(p)
                
                let uv = SIMD2<Float>(Float(i) / Float(edgeHeight - 1), 1 - uvy)
                textureMap.append(uv)
                
                if j != edgeDepth - 1 && i != edgeHeight - 1 {
                    let index = UInt32(i + j * edgeHeight)

                    let tl = index
                    let tr = tl + 1
                    let bl = index + UInt32(edgeHeight)
                    let br = bl + 1

                    indices.append(contentsOf: [tl,bl,tr,
                                                tr,bl,br])
                }
            }
        }
        // -X
        for j in 0..<edgeDepth {
            let startY = depthHalf
            let startZ = -heightHalf
            let jf = Float(j)
            let uvy = jf / Float(edgeDepth - 1)
            for i in 0..<edgeHeight {
                let p = SIMD3<Float>(-widthHalf, startY - depthInc * jf, startZ + heightInc * Float(i))
                meshPositions.append(p)

                let uv = SIMD2<Float>(Float(i) / Float(edgeHeight - 1), 1 - uvy)
                textureMap.append(uv)
                
                if j != edgeDepth - 1 && i != edgeHeight - 1 {
                    let index = UInt32(i + j * edgeHeight + xPointCount)
                    
                    let tl = index
                    let tr = tl + 1
                    let bl = index + UInt32(edgeHeight)
                    let br = bl + 1
                    
                    indices.append(contentsOf: [tl,bl,tr,
                                                tr,bl,br])
                }
            }
        }
        if splitFaces {
            let count = (edgeDepth - 1) * (edgeHeight - 1)
            materials.append(contentsOf: Array(repeating: 0, count: count * 4))
        }
        
        // +Y
        for j in 0..<edgeHeight {
            let startX = -widthHalf
            let startZ = -heightHalf
            let jf = Float(j)
            let uvy = jf / Float(edgeHeight - 1)
            for i in 0..<edgeWidth {
                let p = SIMD3<Float>(startX + widthInc * Float(i), depthHalf, startZ + heightInc * jf)
                meshPositions.append(p)

                let uv = SIMD2<Float>(Float(i) / Float(edgeWidth - 1), 1 - uvy)
                textureMap.append(uv)
                
                if j != edgeHeight - 1 && i != edgeWidth - 1 {
                    let index = UInt32(i + j * edgeWidth + xPointCount * 2)

                    let tl = index
                    let tr = tl + 1
                    let bl = index + UInt32(edgeWidth)
                    let br = bl + 1

                    indices.append(contentsOf: [tl,bl,tr,
                                                tr,bl,br])
                }
            }
        }
        // -Y
        for j in 0..<edgeHeight {
            let startX = widthHalf
            let startZ = -heightHalf
            let jf = Float(j)
            let uvy = jf / Float(edgeHeight - 1)
            for i in 0..<edgeWidth {
                let p = SIMD3<Float>(startX - widthInc * Float(i), -depthHalf, startZ + heightInc * jf)
                meshPositions.append(p)
                
                let uv = SIMD2<Float>(Float(i) / Float(edgeWidth - 1), 1 - uvy)
                textureMap.append(uv)
                
                if j != edgeHeight - 1 && i != edgeWidth - 1 {
                    let index = UInt32(i + j * edgeWidth + xPointCount * 2 + yPointCount)
                    
                    let tl = index
                    let tr = tl + 1
                    let bl = index + UInt32(edgeWidth)
                    let br = bl + 1
                    
                    indices.append(contentsOf: [tl,bl,tr,
                                                tr,bl,br])
                }
            }
        }
        if splitFaces {
            let count = (edgeWidth - 1) * (edgeHeight - 1)
            materials.append(contentsOf: Array(repeating: 1, count: count * 4))
        }
        
        // +Z
        for j in 0..<edgeDepth {
            let startY = depthHalf
            let startX = -widthHalf
            let jf = Float(j)
            let uvy = jf / Float(edgeDepth - 1)
            for i in 0..<edgeWidth {
                let p = SIMD3<Float>(startX + widthInc * Float(i), startY - depthInc * jf, heightHalf)
                meshPositions.append(p)
                
                let uv = SIMD2<Float>(Float(i) / Float(edgeWidth - 1), 1 - uvy)
                textureMap.append(uv)
                
                if j != edgeDepth - 1 && i != edgeWidth - 1 {
                    let index = UInt32(i + j * edgeWidth + xPointCount * 2 + yPointCount * 2)

                    let tl = index
                    let tr = tl + 1
                    let bl = index + UInt32(edgeWidth)
                    let br = bl + 1

                    indices.append(contentsOf: [tl,bl,tr,
                                                tr,bl,br])
                }
            }
        }
        // -Z
        for j in 0..<edgeDepth {
            let startY = depthHalf
            let startX = widthHalf
            let jf = Float(j)
            let uvy = jf / Float(edgeDepth - 1)
            for i in 0..<edgeWidth {
                let p = SIMD3<Float>(startX - widthInc * Float(i), startY - depthInc * jf, -heightHalf)
                meshPositions.append(p)
                
                let uv = SIMD2<Float>(Float(i) / Float(edgeWidth - 1), 1 - uvy)
                textureMap.append(uv)
                
                if j != edgeDepth - 1 && i != edgeWidth - 1 {
                    let index = UInt32(i + j * edgeWidth + xPointCount * 2 + yPointCount * 2 + zPointCount)
                    
                    let tl = index
                    let tr = tl + 1
                    let bl = index + UInt32(edgeWidth)
                    let br = bl + 1
                    
                    indices.append(contentsOf: [tl,bl,tr,
                                                tr,bl,br])
                }
            }
        }
        if splitFaces {
            let count = (edgeWidth - 1) * (edgeDepth - 1)
            materials.append(contentsOf: Array(repeating: 2, count: count * 4))
        }
        
        let innerWidth = width - radius * 2
        let innerHeight = height - radius * 2
        let innerDepth = depth - radius * 2
        let lower = SIMD3<Float>(-innerWidth * 0.5, -innerHeight * 0.5, -innerDepth * 0.5)
        let upper = SIMD3<Float>(innerWidth * 0.5, innerHeight * 0.5, innerDepth * 0.5)
        
        var roundPositions: [SIMD3<Float>] = []
        for p in meshPositions {
            let inner = p.clamped(lowerBound: lower, upperBound: upper)
            let n = simd_normalize(p - inner)
            normals.append(n)
            
            roundPositions.append(inner + n * radius)
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
    
    public static func generateRoundedCubeAsync(width: Float, height: Float, depth: Float, radius: Float, widthResolution: Int = 10, heightResolution: Int = 10, depthResolution: Int = 10, splitFaces: Bool = false) async throws -> MeshResource {
        // Create separate arrays for each face to enable parallel processing
        var meshPositions0: [SIMD3<Float>] = []
        var indices0: [UInt32] = []
        var textureMap0: [SIMD2<Float>] = []
        
        var meshPositions1: [SIMD3<Float>] = []
        var indices1: [UInt32] = []
        var textureMap1: [SIMD2<Float>] = []
        
        var meshPositions2: [SIMD3<Float>] = []
        var indices2: [UInt32] = []
        var textureMap2: [SIMD2<Float>] = []
        
        var meshPositions3: [SIMD3<Float>] = []
        var indices3: [UInt32] = []
        var textureMap3: [SIMD2<Float>] = []
        
        var meshPositions4: [SIMD3<Float>] = []
        var indices4: [UInt32] = []
        var textureMap4: [SIMD2<Float>] = []
        
        var meshPositions5: [SIMD3<Float>] = []
        var indices5: [UInt32] = []
        var textureMap5: [SIMD2<Float>] = []
        
        var normals0: [SIMD3<Float>] = []
        var normals1: [SIMD3<Float>] = []
        var normals2: [SIMD3<Float>] = []
        var normals3: [SIMD3<Float>] = []
        var normals4: [SIMD3<Float>] = []
        var normals5: [SIMD3<Float>] = []
        
        let widthHalf = width * 0.5
        let heightHalf = height * 0.5
        let depthHalf = depth * 0.5
        let minDim = min(widthHalf, min(heightHalf, depthHalf))
        let radius = radius > minDim ? minDim : radius
        
        let edgeWidth = widthResolution > 1 ? widthResolution : 2
        let edgeHeight = heightResolution > 1 ? heightResolution : 2
        let edgeDepth = depthResolution > 1 ? depthResolution : 2
        
        let widthInc = width / Float(edgeWidth - 1)
        let heightInc = height / Float(edgeHeight - 1)
        let depthInc = depth / Float(edgeDepth - 1)
        
        let xPointCount = edgeDepth * edgeHeight
        let yPointCount = edgeWidth * edgeHeight
        let zPointCount = edgeDepth * edgeWidth
        
        // +X face
        for j in 0..<edgeDepth {
            let startY = depthHalf
            let startZ = heightHalf
            let jf = Float(j)
            let uvy = jf / Float(edgeDepth - 1)
            for i in 0..<edgeHeight {
                let p = SIMD3<Float>(widthHalf, startY - depthInc * jf, startZ - heightInc * Float(i))
                meshPositions0.append(p)
                
                let uv = SIMD2<Float>(Float(i) / Float(edgeHeight - 1), 1 - uvy)
                textureMap0.append(uv)
                
                if j != edgeDepth - 1 && i != edgeHeight - 1 {
                    let index = UInt32(i + j * edgeHeight)
                    
                    let tl = index
                    let tr = tl + 1
                    let bl = index + UInt32(edgeHeight)
                    let br = bl + 1
                    
                    indices0.append(contentsOf: [tl,bl,tr,
                                                tr,bl,br])
                }
            }
        }
        
        // -X face
        for j in 0..<edgeDepth {
            let startY = depthHalf
            let startZ = -heightHalf
            let jf = Float(j)
            let uvy = jf / Float(edgeDepth - 1)
            for i in 0..<edgeHeight {
                let p = SIMD3<Float>(-widthHalf, startY - depthInc * jf, startZ + heightInc * Float(i))
                meshPositions1.append(p)
                
                let uv = SIMD2<Float>(Float(i) / Float(edgeHeight - 1), 1 - uvy)
                textureMap1.append(uv)
                
                if j != edgeDepth - 1 && i != edgeHeight - 1 {
                    let index = UInt32(i + j * edgeHeight)
                    
                    let tl = index
                    let tr = tl + 1
                    let bl = index + UInt32(edgeHeight)
                    let br = bl + 1
                    
                    indices1.append(contentsOf: [tl,bl,tr,
                                                tr,bl,br])
                }
            }
        }
        
        // +Y face
        for j in 0..<edgeHeight {
            let startX = -widthHalf
            let startZ = -heightHalf
            let jf = Float(j)
            let uvy = jf / Float(edgeHeight - 1)
            for i in 0..<edgeWidth {
                let p = SIMD3<Float>(startX + widthInc * Float(i), depthHalf, startZ + heightInc * jf)
                meshPositions2.append(p)
                
                let uv = SIMD2<Float>(Float(i) / Float(edgeWidth - 1), 1 - uvy)
                textureMap2.append(uv)
                
                if j != edgeHeight - 1 && i != edgeWidth - 1 {
                    let index = UInt32(i + j * edgeWidth)
                    
                    let tl = index
                    let tr = tl + 1
                    let bl = index + UInt32(edgeWidth)
                    let br = bl + 1
                    
                    indices2.append(contentsOf: [tl,bl,tr,
                                                tr,bl,br])
                }
            }
        }
        
        // -Y face
        for j in 0..<edgeHeight {
            let startX = widthHalf
            let startZ = -heightHalf
            let jf = Float(j)
            let uvy = jf / Float(edgeHeight - 1)
            for i in 0..<edgeWidth {
                let p = SIMD3<Float>(startX - widthInc * Float(i), -depthHalf, startZ + heightInc * jf)
                meshPositions3.append(p)
                
                let uv = SIMD2<Float>(Float(i) / Float(edgeWidth - 1), 1 - uvy)
                textureMap3.append(uv)
                
                if j != edgeHeight - 1 && i != edgeWidth - 1 {
                    let index = UInt32(i + j * edgeWidth)
                    
                    let tl = index
                    let tr = tl + 1
                    let bl = index + UInt32(edgeWidth)
                    let br = bl + 1
                    
                    indices3.append(contentsOf: [tl,bl,tr,
                                                tr,bl,br])
                }
            }
        }
        
        // +Z face
        for j in 0..<edgeDepth {
            let startY = depthHalf
            let startX = -widthHalf
            let jf = Float(j)
            let uvy = jf / Float(edgeDepth - 1)
            for i in 0..<edgeWidth {
                let p = SIMD3<Float>(startX + widthInc * Float(i), startY - depthInc * jf, heightHalf)
                meshPositions4.append(p)
                
                let uv = SIMD2<Float>(Float(i) / Float(edgeWidth - 1), 1 - uvy)
                textureMap4.append(uv)
                
                if j != edgeDepth - 1 && i != edgeWidth - 1 {
                    let index = UInt32(i + j * edgeWidth)
                    
                    let tl = index
                    let tr = tl + 1
                    let bl = index + UInt32(edgeWidth)
                    let br = bl + 1
                    
                    indices4.append(contentsOf: [tl,bl,tr,
                                                tr,bl,br])
                }
            }
        }
        
        // -Z face
        for j in 0..<edgeDepth {
            let startY = depthHalf
            let startX = widthHalf
            let jf = Float(j)
            let uvy = jf / Float(edgeDepth - 1)
            for i in 0..<edgeWidth {
                let p = SIMD3<Float>(startX - widthInc * Float(i), startY - depthInc * jf, -heightHalf)
                meshPositions5.append(p)
                
                let uv = SIMD2<Float>(Float(i) / Float(edgeWidth - 1), 1 - uvy)
                textureMap5.append(uv)
                
                if j != edgeDepth - 1 && i != edgeWidth - 1 {
                    let index = UInt32(i + j * edgeWidth)
                    
                    let tl = index
                    let tr = tl + 1
                    let bl = index + UInt32(edgeWidth)
                    let br = bl + 1
                    
                    indices5.append(contentsOf: [tl,bl,tr,
                                                tr,bl,br])
                }
            }
        }
        
        // Calculate normals for all faces
        let innerWidth = width - radius * 2
        let innerHeight = height - radius * 2
        let innerDepth = depth - radius * 2
        let lower = SIMD3<Float>(-innerWidth * 0.5, -innerHeight * 0.5, -innerDepth * 0.5)
        let upper = SIMD3<Float>(innerWidth * 0.5, innerHeight * 0.5, innerDepth * 0.5)
        
        // Helper function to calculate normals and rounded positions for positions
        func calculateNormalsAndRoundedPositions(for positions: [SIMD3<Float>]) -> ([SIMD3<Float>], [SIMD3<Float>]) {
            var normals: [SIMD3<Float>] = []
            var roundedPositions: [SIMD3<Float>] = []
            for p in positions {
                let inner = p.clamped(lowerBound: lower, upperBound: upper)
                let n = simd_normalize(p - inner)
                normals.append(n)
                roundedPositions.append(inner + n * radius)
            }
            return (normals, roundedPositions)
        }
        
        // Calculate normals and rounded positions for each face
        let (normalsAndRounded0, roundedPositions0) = calculateNormalsAndRoundedPositions(for: meshPositions0)
        normals0 = normalsAndRounded0
        meshPositions0 = roundedPositions0
        
        let (normalsAndRounded1, roundedPositions1) = calculateNormalsAndRoundedPositions(for: meshPositions1)
        normals1 = normalsAndRounded1
        meshPositions1 = roundedPositions1
        
        let (normalsAndRounded2, roundedPositions2) = calculateNormalsAndRoundedPositions(for: meshPositions2)
        normals2 = normalsAndRounded2
        meshPositions2 = roundedPositions2
        
        let (normalsAndRounded3, roundedPositions3) = calculateNormalsAndRoundedPositions(for: meshPositions3)
        normals3 = normalsAndRounded3
        meshPositions3 = roundedPositions3
        
        let (normalsAndRounded4, roundedPositions4) = calculateNormalsAndRoundedPositions(for: meshPositions4)
        normals4 = normalsAndRounded4
        meshPositions4 = roundedPositions4
        
        let (normalsAndRounded5, roundedPositions5) = calculateNormalsAndRoundedPositions(for: meshPositions5)
        normals5 = normalsAndRounded5
        meshPositions5 = roundedPositions5
        
        // Create parts for each face
        var parts: [MeshResource.Part] = []
        
        // +X and -X faces part (material index 0)
        var part0 = MeshResource.Part(id: "CubeX", materialIndex: splitFaces ? 0 : 0)
        part0.triangleIndices = .init(indices0)
        part0.textureCoordinates = .init(textureMap0)
        part0.normals = .init(normals0)
        part0.positions = .init(meshPositions0)
        
        var part1 = MeshResource.Part(id: "Cube-X", materialIndex: splitFaces ? 0 : 0)
        part1.triangleIndices = .init(indices1)
        part1.textureCoordinates = .init(textureMap1)
        part1.normals = .init(normals1)
        part1.positions = .init(meshPositions1)
        
        // +Y and -Y faces part (material index 1)
        var part2 = MeshResource.Part(id: "CubeY", materialIndex: splitFaces ? 1 : 0)
        part2.triangleIndices = .init(indices2)
        part2.textureCoordinates = .init(textureMap2)
        part2.normals = .init(normals2)
        part2.positions = .init(meshPositions2)
        
        var part3 = MeshResource.Part(id: "Cube-Y", materialIndex: splitFaces ? 1 : 0)
        part3.triangleIndices = .init(indices3)
        part3.textureCoordinates = .init(textureMap3)
        part3.normals = .init(normals3)
        part3.positions = .init(meshPositions3)
        
        // +Z and -Z faces part (material index 2)
        var part4 = MeshResource.Part(id: "CubeZ", materialIndex: splitFaces ? 2 : 0)
        part4.triangleIndices = .init(indices4)
        part4.textureCoordinates = .init(textureMap4)
        part4.normals = .init(normals4)
        part4.positions = .init(meshPositions4)
        
        var part5 = MeshResource.Part(id: "Cube-Z", materialIndex: splitFaces ? 2 : 0)
        part5.triangleIndices = .init(indices5)
        part5.textureCoordinates = .init(textureMap5)
        part5.normals = .init(normals5)
        part5.positions = .init(meshPositions5)
        
        if splitFaces {
            parts = [part0, part1, part2, part3, part4, part5]
        } else {
            // Merge all geometry for single material
            var mergedPositions = meshPositions0
            mergedPositions.append(contentsOf: meshPositions1)
            mergedPositions.append(contentsOf: meshPositions2)
            mergedPositions.append(contentsOf: meshPositions3)
            mergedPositions.append(contentsOf: meshPositions4)
            mergedPositions.append(contentsOf: meshPositions5)
            
            var mergedNormals = normals0
            mergedNormals.append(contentsOf: normals1)
            mergedNormals.append(contentsOf: normals2)
            mergedNormals.append(contentsOf: normals3)
            mergedNormals.append(contentsOf: normals4)
            mergedNormals.append(contentsOf: normals5)
            
            var mergedTextureCoords = textureMap0
            mergedTextureCoords.append(contentsOf: textureMap1)
            mergedTextureCoords.append(contentsOf: textureMap2)
            mergedTextureCoords.append(contentsOf: textureMap3)
            mergedTextureCoords.append(contentsOf: textureMap4)
            mergedTextureCoords.append(contentsOf: textureMap5)
            
            // Adjust indices for each subsequent part
            let offset1 = UInt32(meshPositions0.count)
            var adjustedIndices1 = indices1
            for i in 0..<adjustedIndices1.count {
                adjustedIndices1[i] += offset1
            }
            
            let offset2 = offset1 + UInt32(meshPositions1.count)
            var adjustedIndices2 = indices2
            for i in 0..<adjustedIndices2.count {
                adjustedIndices2[i] += offset2
            }
            
            let offset3 = offset2 + UInt32(meshPositions2.count)
            var adjustedIndices3 = indices3
            for i in 0..<adjustedIndices3.count {
                adjustedIndices3[i] += offset3
            }
            
            let offset4 = offset3 + UInt32(meshPositions3.count)
            var adjustedIndices4 = indices4
            for i in 0..<adjustedIndices4.count {
                adjustedIndices4[i] += offset4
            }
            
            let offset5 = offset4 + UInt32(meshPositions4.count)
            var adjustedIndices5 = indices5
            for i in 0..<adjustedIndices5.count {
                adjustedIndices5[i] += offset5
            }
            
            var mergedIndices = indices0
            mergedIndices.append(contentsOf: adjustedIndices1)
            mergedIndices.append(contentsOf: adjustedIndices2)
            mergedIndices.append(contentsOf: adjustedIndices3)
            mergedIndices.append(contentsOf: adjustedIndices4)
            mergedIndices.append(contentsOf: adjustedIndices5)
            
            var singlePart = MeshResource.Part(id: "Cube", materialIndex: 0)
            singlePart.triangleIndices = .init(mergedIndices)
            singlePart.textureCoordinates = .init(mergedTextureCoords)
            singlePart.normals = .init(mergedNormals)
            singlePart.positions = .init(mergedPositions)
            
            parts = [singlePart]
        }
        
        let model = MeshResource.Model(id: "RoundedCubeModel", parts: parts)
        let instance = MeshResource.Instance(id: "RoundedCubeModel-0", model: "RoundedCubeModel")
        
        var contents = MeshResource.Contents()
        contents.instances = .init([instance])
        contents.models = .init([model])
        
        return try await MeshResource(from: contents)
    }
}
