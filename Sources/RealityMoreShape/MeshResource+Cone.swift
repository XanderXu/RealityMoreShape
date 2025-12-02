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
    
    public static func generateConeAsync(radius: Float, height: Float, angularResolution: Int = 24, radialResolution: Int = 1, verticalResolution: Int = 1, splitFaces: Bool = false, circleUV: Bool = true) async throws -> MeshResource {
        var meshPositions0: [SIMD3<Float>] = []
        var indices0: [UInt32] = []
        var normals0: [SIMD3<Float>] = []
        var textureMap0: [SIMD2<Float>] = []
        
        var meshPositions1: [SIMD3<Float>] = []
        var indices1: [UInt32] = []
        var normals1: [SIMD3<Float>] = []
        var textureMap1: [SIMD2<Float>] = []
        
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
        
        // Wall part
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
                
                meshPositions0.append(SIMD3<Float>(x, y, z))
                normals0.append(normalize(coneBottomNormal))
                textureMap0.append(SIMD2<Float>(1 - af / angularf, vf / verticalf))
                
                if (v != vertical && a != angular) {
                    let index = a + v * perLoop
                    
                    let tl = UInt32(index)
                    let tr = tl + 1
                    let bl = UInt32(index + perLoop)
                    let br = bl + 1
                    
                    indices0.append(contentsOf: [tl, bl, tr,
                                                tr, bl, br
                                               ])
                }
            }
        }
        
        // Bottom cap part
        for r in 0...radial {
            let rf = Float(r)
            let rad = rf * radialInc
            
            for a in 0...angular {
                let af = Float(a)
                let angle = af * angularInc
                let x = rad * cos(angle)
                let y = rad * sin(angle)
                
                meshPositions1.append(SIMD3<Float>(x, -height * 0.5, y))
                normals1.append(SIMD3<Float>(0, -1, 0))
                if circleUV {
                    textureMap1.append(SIMD2<Float>(af / angularf, 1 - rf / radialf))
                } else {
                    textureMap1.append(SIMD2<Float>(x/radius/2+0.5, y/radius/2+0.5))
                }
                
                if (r != radial && a != angular) {
                    let index = a + r * perLoop;
                    
                    let tl = UInt32(index)
                    let tr = tl + 1
                    let bl = UInt32(index + perLoop)
                    let br = bl + 1
                    
                    indices1.append(contentsOf: [tl, bl, tr,
                                                tr, bl, br
                                               ])
                }
            }
        }
        
        var parts: [MeshResource.Part] = []
        var part0 = MeshResource.Part(id: "ConeWall", materialIndex: 0)
        part0.triangleIndices = .init(indices0)
        part0.textureCoordinates = .init(textureMap0)
        part0.normals = .init(normals0)
        part0.positions = .init(meshPositions0)
        
        var part1 = MeshResource.Part(id: "ConeBottom", materialIndex: splitFaces ? 1 : 0)
        part1.triangleIndices = .init(indices1)
        part1.textureCoordinates = .init(textureMap1)
        part1.normals = .init(normals1)
        part1.positions = .init(meshPositions1)
        
        if splitFaces {
            parts = [part0, part1]
        } else {
            // Merge the geometry for single material
            var mergedPositions = meshPositions0
            mergedPositions.append(contentsOf: meshPositions1)
            
            var mergedNormals = normals0
            mergedNormals.append(contentsOf: normals1)
            
            var mergedTextureCoords = textureMap0
            mergedTextureCoords.append(contentsOf: textureMap1)
            
            // Adjust indices for the second part
            let offset = UInt32(meshPositions0.count)
            var adjustedIndices1 = indices1
            for i in 0..<adjustedIndices1.count {
                adjustedIndices1[i] += offset
            }
            
            var mergedIndices = indices0
            mergedIndices.append(contentsOf: adjustedIndices1)
            
            var singlePart = MeshResource.Part(id: "Cone", materialIndex: 0)
            singlePart.triangleIndices = .init(mergedIndices)
            singlePart.textureCoordinates = .init(mergedTextureCoords)
            singlePart.normals = .init(mergedNormals)
            singlePart.positions = .init(mergedPositions)
            
            parts = [singlePart]
        }
        
        let model = MeshResource.Model(id: "ConeModel", parts: parts)
        let instance = MeshResource.Instance(id: "ConeModel-0", model: "ConeModel")
        
        var contents = MeshResource.Contents()
        contents.instances = .init([instance])
        contents.models = .init([model])
        
        return try await MeshResource(from: contents)
    }
}
