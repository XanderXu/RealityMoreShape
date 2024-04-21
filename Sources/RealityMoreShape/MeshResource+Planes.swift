//
//  MeshResource+Planes.swift
//  
//
//  Created by Xu on 2022/3/29.
//

import RealityKit

extension MeshResource {
    /// Creates a new plane mesh with the specified values. 
    /// - Parameters:
    ///   - width: Width of the output plane
    ///   - depth: Depth of the output plane
    ///   - vertices: Vertex count in the x and z axis
    /// - Returns: A plane mesh
    public static func generateDetailedPlane(
        width: Float, height: Float, vertices: (Int, Int)
    ) throws -> MeshResource {
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var textureMap: [SIMD2<Float>] = []
        for x_v in 0..<(vertices.0) {
            let vertexCounts = meshPositions.count
            for y_v in 0..<(vertices.1) {
                meshPositions.append([
                    (Float(x_v) / Float(vertices.0 - 1) - 0.5) * width,
                    0,
                    (0.5 - Float(y_v) / Float(vertices.1 - 1)) * height
                ])
                textureMap.append([Float(x_v) / Float(vertices.0 - 1), Float(y_v) / Float(vertices.1 - 1)])
                if x_v > 0 && y_v > 0 {
                    indices.append(
                        contentsOf: [
                            vertexCounts - vertices.1, vertexCounts, vertexCounts - vertices.1 + 1,
                            vertexCounts - vertices.1 + 1, vertexCounts, vertexCounts + 1
                        ].map { UInt32($0 + y_v - 1) })
                }
            }
        }
        descr.primitives = .triangles(indices)
        descr.positions = MeshBuffer(meshPositions)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        return try .generate(from: [descr])
    }
    public static func generateCirclePlane(radius: Float, angularResolution: Int = 24, radialResolution: Int = 1, circleUV: Bool = true) throws -> MeshResource {
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var textureMap: [SIMD2<Float>] = []
        
        let radial = radialResolution > 0 ? radialResolution : 1
        let angular = angularResolution > 2 ? angularResolution : 3;

        let radialf = Float(radial)
        let angularf = Float(angular)
        
        let radialInc = radius / radialf
        let angularInc = (2.0 * Float.pi) / angularf

        let perLoop = angular + 1

        for r in 0...radial {
            let rf = Float(r)
            let rad = rf * radialInc
            let rFactor = rf / radialf
            for a in 0...angular {
                let af = Float(a)
                let angle = af * angularInc
                let ca = cos(angle)
                let sa = sin(angle)

                meshPositions.append(SIMD3<Float>(rad * ca, 0, rad * sa))
                if circleUV {
                    textureMap.append(SIMD2<Float>(rFactor, 1 - af / angularf))
                } else {
                    textureMap.append(SIMD2<Float>((ca*rFactor)/2+0.5, 0.5-(sa*rFactor)/2))
                }
                
                if (r != radial && a != angular) {
                    let index = UInt32(a + r * perLoop)

                    let tl = index
                    let tr = tl + 1
                    let bl = index + UInt32(perLoop)
                    let br = bl + 1

                    indices.append(contentsOf: [tr,bl,tl,
                                                br,bl,tr])
                }
            }
        }
        
        descr.primitives = .triangles(indices)
        descr.positions = MeshBuffer(meshPositions)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        return try .generate(from: [descr])
    }
    public static func generateArcPlane(innerRadius: Float, outerRadius: Float, startAngle: Float, endAngle: Float, angularResolution: Int = 12, radialResolution: Int = 1, circleUV: Bool = true) throws -> MeshResource {
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var textureMap: [SIMD2<Float>] = []
        
        let radial = radialResolution > 0 ? radialResolution : 1
        let angular = angularResolution > 2 ? angularResolution : 3;

        let radialf = Float(radial)
        let angularf = Float(angular)
        
        let radialInc = (outerRadius - innerRadius) / radialf
        let angularInc = (endAngle - startAngle) / angularf

        let perArc = angular + 1
        
        for r in 0...radial {
            let rf = Float(r)
            let rad = innerRadius + rf * radialInc
            let rFactor = rad / outerRadius
            for a in 0...angular {
                let af = Float(a)
                let angle = startAngle + af * angularInc
                let ca = cos(angle)
                let sa = sin(angle)

                meshPositions.append(SIMD3<Float>(rad * ca, 0, rad * sa))
                if circleUV {
                    textureMap.append(SIMD2<Float>(rf / radialf, 1 - af / angularf))
                } else {
                    textureMap.append(SIMD2<Float>((ca*rFactor)/2+0.5, 0.5-(sa*rFactor)/2))
                }
                
                if (r != radial && a != angular) {
                    let index = UInt32(a + r * perArc)

                    let br = index
                    let bl = br + 1
                    let tr = br + UInt32(perArc)
                    let tl = bl + UInt32(perArc)

                    indices.append(contentsOf: [tr,br,bl,
                                                tl,tr,bl])
                }
            }
        }
        
        
        descr.primitives = .triangles(indices)
        descr.positions = MeshBuffer(meshPositions)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        return try .generate(from: [descr])
    }
    public static func generateSquirclePlane(size: Float, p: Float = 4, angularResolution: Int = 24, radialResolution: Int  = 1, circleUV: Bool = true) throws -> MeshResource {
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var textureMap: [SIMD2<Float>] = []
        
        let rad = size * 0.5
        let angular = angularResolution > 2 ? angularResolution : 3
        let radial = radialResolution > 1 ? radialResolution : 1

        let perLoop = angular + 1
        for r in 0...radial {
            let k = Float(r) / Float(radial)
            let radius = map(input: Float(r), inMin: 0, inMax: Float(radial), outMin: 0, outMax: rad)
            for a in 0...angular {
                let t = Float(a) / Float(angular)
                let theta = 2.0 * .pi * t

                let cost = cos(theta)
                let sint = sin(theta)

                let den = pow(abs(cost), p) + pow(abs(sint), p)
                let phi = 1.0 / pow(den, 1.0 / p)

                let x = radius * phi * cost
                let z = radius * phi * sint
                meshPositions.append(SIMD3<Float>(x, 0, z))
                if circleUV {
                    textureMap.append(SIMD2<Float>(t, k))
                } else {
                    textureMap.append(SIMD2<Float>(x/size+0.5, -z/size+0.5))
                }
                
                if (r != radial && a != angular) {
                    let index = UInt32(a + r * perLoop)

                    let tl = index
                    let tr = tl + 1
                    let bl = index + UInt32(perLoop)
                    let br = bl + 1

                    indices.append(contentsOf: [tr,bl,tl,
                                                br,bl,tr])
                }
            }
        }
        
        descr.primitives = .triangles(indices)
        descr.positions = MeshBuffer(meshPositions)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        return try .generate(from: [descr])
    }
    public static func map(input: Float, inMin: Float, inMax:Float, outMin:Float, outMax: Float) -> Float {
        return ((input - inMin) / (inMax - inMin) * (outMax - outMin)) + outMin;
    }
    public static func angle2(a:simd_float2) -> Float {
        var theta = atan2f(a.y, a.x);
        if (theta < 0) { theta += .pi * 2.0; }
        return theta;
    }
    public static func generateRoundedRectPlane(width: Float, height: Float, radius: Float, angularResolution: Int = 24, edgeXResolution: Int = 2, edgeYResolution: Int = 2, radialResolution: Int = 2, circleUV: Bool = true) throws -> MeshResource {
        var descr = MeshDescriptor()
        let datas = generateRoundedRectPlaneDatas(width: width, height: height, radius: radius, angularResolution: angularResolution, edgeXResolution: edgeXResolution, edgeYResolution: edgeYResolution, radialResolution: radialResolution, circleUV: circleUV)
        
        descr.primitives = .triangles(datas.indices)
        descr.positions = MeshBuffer(datas.meshPositions)
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(datas.textureMap)
        return try .generate(from: [descr])
    }
    public static func generateRoundedRectPlaneDatas(width: Float, height: Float, radius: Float, angularResolution: Int, edgeXResolution: Int, edgeYResolution: Int, radialResolution: Int, circleUV: Bool) -> (meshPositions: [SIMD3<Float>], indices: [UInt32], textureMap: [SIMD2<Float>]) {
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var textureMap: [SIMD2<Float>] = []
        
        let twoPi = Float.pi * 2.0
        let halfPi = Float.pi * 0.5

        let angular = angularResolution > 2 ? angularResolution : 3
        let angularMinusOne = angular - 1
        let angularMinusOnef = Float(angularMinusOne)
        
        let radial = radialResolution > 1 ? radialResolution : 2
        let radialf = Float(radial)
        let radialMinusOnef = radialf - 1.0
            
        let edgeX = edgeXResolution > 1 ? edgeXResolution : 2
        
        let edgeXMinusOne = edgeX - 1
        let edgeXMinusOnef = Float(edgeXMinusOne)
        
        let edgeY = edgeYResolution > 1 ? edgeYResolution : 2
        
        let edgeYMinusOne = edgeY - 1
        let edgeYMinusOnef = Float(edgeYMinusOne)

        let perLoop = (angular - 2) * 4 + (edgeX * 2) + (edgeY * 2) + (circleUV ? 2 : 0)

        let widthHalf = width * 0.5
        let heightHalf = height * 0.5

        let minDim = (widthHalf < heightHalf ? widthHalf : heightHalf)
        let radius = radius > minDim ? minDim : radius
        
        for j in 0..<radial {
            let n = Float(j) / radialMinusOnef
            
            // +X, -Y -> +Y
            var start = SIMD2<Float>(widthHalf, -heightHalf + radius)
            var end = SIMD2<Float>(widthHalf, heightHalf - radius)
            for i in 0..<edgeY {
                let t = Float(i) / edgeYMinusOnef
                let pos = simd_mix(start, end, SIMD2<Float>(t, t))
                meshPositions.append(SIMD3<Float>(pos.x, 0, pos.y) * n)
                
                if circleUV {
                    let angle = angle2(a: pos)
                    let uvx = angle / twoPi
                    let uvy = n
                    textureMap.append(SIMD2<Float>(uvx,uvy))
                    
                    if i == edgeY/2 - 1 {//start and end UVs are different, so add more points
                        let newPos = SIMD2<Float>(pos.x * n, 0)
                        meshPositions.append(SIMD3<Float>(newPos.x, 0, newPos.y))
                        textureMap.append(SIMD2<Float>(1,uvy))

                        meshPositions.append(SIMD3<Float>(newPos.x, 0, newPos.y))
                        textureMap.append(SIMD2<Float>(0,uvy))
                    }
                } else {
                    textureMap.append(SIMD2<Float>(pos.x * n / width + 0.5, -pos.y * n / height + 0.5))
                }
            }
            
            // corner 0
            for i in 1..<angularMinusOne {
                let t = Float(i) / angularMinusOnef
                let theta = t * halfPi
                let x = radius * cos(theta)
                let y = radius * sin(theta)
                let pos = SIMD2<Float>(widthHalf - radius + x, heightHalf - radius + y)
                meshPositions.append(SIMD3<Float>(pos.x, 0, pos.y) * n)
                
                if circleUV {
                    let angle = angle2(a: pos)
                    let uvx = angle / twoPi
                    let uvy = n
                    textureMap.append(SIMD2<Float>(uvx,uvy))
                } else {
                    textureMap.append(SIMD2<Float>(pos.x * n / width + 0.5, -pos.y * n / height + 0.5))
                }
            }
            
            // +Y, +X -> -X
            start = SIMD2<Float>(widthHalf - radius, heightHalf)
            end = SIMD2<Float>(-widthHalf + radius, heightHalf)
            for i in 0..<edgeX {
                let t = Float(i) / edgeXMinusOnef
                let pos = simd_mix(start, end, SIMD2<Float>(t, t))
                meshPositions.append(SIMD3<Float>(pos.x, 0, pos.y) * n)
                
                if circleUV {
                    let angle = angle2(a: pos)
                    let uvx = angle / twoPi
                    let uvy = n
                    textureMap.append(SIMD2<Float>(uvx,uvy))
                } else {
                    textureMap.append(SIMD2<Float>(pos.x * n / width + 0.5, -pos.y * n / height + 0.5))
                }
            }
            
            // corner 1
            for i in 1..<angularMinusOne {
                let t = Float(i) / angularMinusOnef
                let theta = t * halfPi + halfPi
                let x = radius * cos(theta)
                let y = radius * sin(theta)
                let pos = SIMD2<Float>(-widthHalf + radius + x, heightHalf - radius + y)
                meshPositions.append(SIMD3<Float>(pos.x, 0, pos.y) * n)
                
                if circleUV {
                    let angle = angle2(a: pos)
                    let uvx = angle / twoPi
                    let uvy = n
                    textureMap.append(SIMD2<Float>(uvx,uvy))
                } else {
                    textureMap.append(SIMD2<Float>(pos.x * n / width + 0.5, -pos.y * n / height + 0.5))
                }
            }
            
            // -X, +Y -> -Y
            start = SIMD2<Float>(-widthHalf, heightHalf - radius)
            end = SIMD2<Float>(-widthHalf, -heightHalf + radius)
            for i in 0..<edgeY {
                let t = Float(i) / edgeYMinusOnef
                let pos = simd_mix(start, end, SIMD2<Float>(t, t))
                meshPositions.append(SIMD3<Float>(pos.x, 0, pos.y) * n)
                
                if circleUV {
                    let angle = angle2(a: pos)
                    let uvx = angle / twoPi
                    let uvy = n
                    textureMap.append(SIMD2<Float>(uvx,uvy))
                } else {
                    textureMap.append(SIMD2<Float>(pos.x * n / width + 0.5, -pos.y * n / height + 0.5))
                }
            }
            
            // corner 2
            for i in 1..<angularMinusOne {
                let t = Float(i) / angularMinusOnef
                let theta = t * halfPi + .pi
                let x = radius * cos(theta)
                let y = radius * sin(theta)
                let pos = SIMD2<Float>(-widthHalf + radius + x, -heightHalf + radius + y)
                meshPositions.append(SIMD3<Float>(pos.x, 0, pos.y) * n)
                
                if circleUV {
                    let angle = angle2(a: pos)
                    let uvx = angle / twoPi
                    let uvy = n
                    textureMap.append(SIMD2<Float>(uvx,uvy))
                } else {
                    textureMap.append(SIMD2<Float>(pos.x * n / width + 0.5, -pos.y * n / height + 0.5))
                }
            }
            
            // -Y, -X -> +X
            start = SIMD2<Float>(-widthHalf + radius, -heightHalf)
            end = SIMD2<Float>(widthHalf - radius, -heightHalf)
            for i in 0..<edgeX {
                let t = Float(i) / edgeXMinusOnef
                let pos = simd_mix(start, end, SIMD2<Float>(t, t))
                meshPositions.append(SIMD3<Float>(pos.x, 0, pos.y) * n)
                
                if circleUV {
                    let angle = angle2(a: pos)
                    let uvx = angle / twoPi
                    let uvy = n
                    textureMap.append(SIMD2<Float>(uvx,uvy))
                } else {
                    textureMap.append(SIMD2<Float>(pos.x * n / width + 0.5, -pos.y * n / height + 0.5))
                }
            }
            
            // corner 3
            for i in 1..<angularMinusOne {
                let t = Float(i) / angularMinusOnef
                let theta = t * halfPi + 1.5 * .pi
                let x = radius * cos(theta)
                let y = radius * sin(theta)
                let pos = SIMD2<Float>(widthHalf - radius + x, -heightHalf + radius + y)
                meshPositions.append(SIMD3<Float>(pos.x, 0, pos.y) * n)
                
                if circleUV {
                    let angle = angle2(a: pos)
                    let uvx = angle / twoPi
                    let uvy = n
                    textureMap.append(SIMD2<Float>(uvx,uvy))
                } else {
                    textureMap.append(SIMD2<Float>(pos.x * n / width + 0.5, -pos.y * n / height + 0.5))
                }
            }
            
            for i in 0..<perLoop {
                if j + 1 != radial {
                    let currLoop = j * perLoop
                    let nextLoop = (j + 1) * perLoop
                    let next = (i + 1) % perLoop

                    let i0 = UInt32(currLoop + i)
                    let i1 = UInt32(currLoop + next)
                    let i2 = UInt32(nextLoop + i)
                    let i3 = UInt32(nextLoop + next)
                    
                    indices.append(contentsOf: [i3,i2,i0,
                                                i1,i3,i0
                    ])
                }
            }
        }
        
        return (meshPositions: meshPositions, indices: indices, textureMap: textureMap)
    }
}
