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
    
    public static func generateCylinderAsync(radius: Float, height: Float, angularResolution: Int = 24, radialResolution: Int = 1, verticalResolution: Int = 1, splitFaces: Bool = false, circleUV: Bool = true) async throws -> MeshResource {
        // Create separate arrays for side wall and caps to enable parallel processing
        var meshPositions0: [SIMD3<Float>] = [] // Side wall positions
        var indices0: [UInt32] = [] // Side wall indices
        var normals0: [SIMD3<Float>] = [] // Side wall normals
        var textureMap0: [SIMD2<Float>] = [] // Side wall texture coordinates
        
        var meshPositions1: [SIMD3<Float>] = [] // Cap positions
        var indices1: [UInt32] = [] // Cap indices
        var normals1: [SIMD3<Float>] = [] // Cap normals
        var textureMap1: [SIMD2<Float>] = [] // Cap texture coordinates
        
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
        
        // Generate side wall geometry
        for v in 0...vertical {
            let vf = Float(v)
            let y = yOffset + vf * verticalInc
            for a in 0...angular {
                let af = Float(a)
                let angle = af * angularInc
                let x = cos(angle)
                let z = sin(angle)
                
                meshPositions0.append(SIMD3<Float>(radius * x, y, radius * z))
                normals0.append(SIMD3<Float>(x, 0.0, z))
                textureMap0.append(SIMD2<Float>(1.0 - af / angularf, vf / verticalf))
                
                if (v != vertical && a != angular) {
                    let index = a + v * perLoop

                    let tl = UInt32(index)
                    let tr = tl + 1
                    let bl = UInt32(index + perLoop)
                    let br = bl + 1

                    indices0.append(contentsOf: [
                        tl, bl, tr,
                        tr, bl, br
                    ])
                }
            }
        }
        
        // Generate cap geometry
        var flip = true
        var direction: Float = 1.0
        var vertexOffset = 0
        for _ in 0..<2 {
            for r in 0...radial {
                let rf = Float(r)
                let rad = rf * radialInc
                for a in 0...angular {
                    let af = Float(a)
                    let angle = af * angularInc
                    let x = rad * cos(angle)
                    let y = rad * sin(angle)
                    
                    meshPositions1.append(SIMD3<Float>(x, direction * height * 0.5, y))
                    normals1.append(SIMD3<Float>(0.0, direction, 0.0))
                    if circleUV {
                        textureMap1.append(SIMD2<Float>(flip ? af / angularf : 1.0 - af / angularf, rf / radialf))
                    } else {
                        textureMap1.append(SIMD2<Float>(-direction * x/radius/2+0.5, y/radius/2+0.5))
                    }
                    if (r != radial && a != angular) {
                        let index = vertexOffset + a + r * perLoop;

                        let tl = UInt32(index)
                        let tr = tl + 1
                        let bl = UInt32(index + perLoop)
                        let br = bl + 1

                        if (flip) {
                            indices1.append(contentsOf: [
                                tl, tr, bl,
                                tr, br, bl
                            ])
                        } else {
                            indices1.append(contentsOf: [
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
        
        // Create parts for each section
        var parts: [MeshResource.Part] = []
        
        // Side wall part
        var part0 = MeshResource.Part(id: "CylinderWall", materialIndex: 0)
        part0.triangleIndices = .init(indices0)
        part0.textureCoordinates = .init(textureMap0)
        part0.normals = .init(normals0)
        part0.positions = .init(meshPositions0)
        
        // Caps part
        var part1 = MeshResource.Part(id: "CylinderCaps", materialIndex: splitFaces ? 1 : 0)
        part1.triangleIndices = .init(indices1)
        part1.textureCoordinates = .init(textureMap1)
        part1.normals = .init(normals1)
        part1.positions = .init(meshPositions1)
        
        if splitFaces {
            parts = [part0, part1]
        } else {
            // Merge all geometry for single material
            var mergedPositions = meshPositions0
            mergedPositions.append(contentsOf: meshPositions1)
            
            var mergedNormals = normals0
            mergedNormals.append(contentsOf: normals1)
            
            var mergedTextureCoords = textureMap0
            mergedTextureCoords.append(contentsOf: textureMap1)
            
            // Adjust indices for the caps to account for vertex offset
            let offset = UInt32(meshPositions0.count)
            var adjustedIndices1 = indices1
            for i in 0..<adjustedIndices1.count {
                adjustedIndices1[i] += offset
            }
            
            var mergedIndices = indices0
            mergedIndices.append(contentsOf: adjustedIndices1)
            
            var singlePart = MeshResource.Part(id: "Cylinder", materialIndex: 0)
            singlePart.triangleIndices = .init(mergedIndices)
            singlePart.textureCoordinates = .init(mergedTextureCoords)
            singlePart.normals = .init(mergedNormals)
            singlePart.positions = .init(mergedPositions)
            
            parts = [singlePart]
        }
        
        let model = MeshResource.Model(id: "CylinderModel", parts: parts)
        let instance = MeshResource.Instance(id: "CylinderModel-0", model: "CylinderModel")
        
        var contents = MeshResource.Contents()
        contents.instances = .init([instance])
        contents.models = .init([model])
        
        return try await MeshResource(from: contents)
    }
}
