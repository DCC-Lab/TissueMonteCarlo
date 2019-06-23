//
//  SCNVectorExtension.swift
//  MonteCarlo3D
//
//  Created by Daniel Côté on 2015-03-23.
//  Copyright (c) 2015 Daniel Côté. All rights reserved.
//

import Foundation
import SceneKit
import simd

//typealias float = CGFloat
//typealias Vector = SCNVector3
//typealias float = Float
//typealias Vector = float3

//typealias Vector3D = Vector
//typealias v⃗ = Vector

let π = float(3.1415926535)
let xHat = Vector(x: 1, y: 0, z: 0)
let yHat = Vector(x: 0, y: 1, z: 0)
let zHat = Vector(x: 0, y: 0, z: 1)
let oHat = Vector(x: 0, y: 0, z: 0)

enum VectorError: LocalizedError {
    case UnexpectedNil
}

enum Axis:Int {
    case X=0,Y=1,Z=2
}

infix operator •: MultiplicationPrecedence
infix operator ⨉: MultiplicationPrecedence

extension SCNVector3 {
    init(_ x:CGFloat,_ y:CGFloat,_ z:CGFloat) {
        self.init(x:x, y:y, z:z)
    }
    
    public var description: String {
        return "(\(x),\(y),\(z))"
    }
    
    func norm() -> CGFloat {
        return x*x + y*y + z*z
    }
    
    func abs() -> CGFloat {
        return sqrt(x*x + y*y + z*z)
    }
    
    mutating func normalize() throws -> SCNVector3 {
        let value = sqrt(x*x + y*y + z*z)
        x = x / value
        y = y / value
        z = z / value
        return self
    }
    
    mutating func addScaledVector(_ theVector:SCNVector3, scale theScale:CGFloat) {
        x += theVector.x * theScale;
        y += theVector.y * theScale;
        z += theVector.z * theScale;
    }

    func dotProduct(_ theVector : SCNVector3 ) -> CGFloat {
        return x * theVector.x + y * theVector.y + z * theVector.z;
    }
    
    func normalizedDotProduct(_ theVector: SCNVector3 ) -> CGFloat {
        var prod = self.dotProduct(theVector)
        
        let norm_u = norm()
        let norm_v = theVector.norm()
        
        if norm_u != 0 && norm_v != 0 {
            prod /= sqrt(norm_u * norm_v);
        }
        
        if prod > 1 {
            return 1
        } else if prod < -1 {
            return -1
        }
        
        return prod;
    }
    
    func crossProduct(_ v: SCNVector3) -> SCNVector3 {
        return  SCNVector3(x:y * v.z - z * v.y,  y:z * v.x - x * v.z,  z: x * v.y - y * v.x)
    }
    
    func normalizedCrossProduct(_ v: SCNVector3) -> SCNVector3 {
        var t = self.crossProduct(v)
        
        let norm_u = self.norm()
        let norm_v = v.norm()
        
        if norm_u != 0 && norm_v != 0 {
            t /= sqrt(norm_u * norm_v);
        }
        
        let norm_t = t.norm()
        if norm_t > 1 {
            t /= sqrt(norm_t);
        }
        
        return t;
    }
    
    func tripleProduct(v : SCNVector3, w : SCNVector3) -> CGFloat {
        return crossProduct(v).dotProduct(w)
    }
    
    func orientedAngleWith(_ y:SCNVector3 , aroundAxis r:SCNVector3 ) -> CGFloat {
        let sinPhi = self.normalizedCrossProduct(y)
        
        var phi = asin(sinPhi.abs())
        
        if self.dotProduct(y) <= 0 {
            phi = .pi - phi
        }
        
        if sinPhi.dotProduct(r) <= 0 {
            phi *= -1
        }
        
        return phi;
    }
    
    func distanceToPlaneWithOrigin(origin v0: SCNVector3, normal vn:SCNVector3, alongVector vd:SCNVector3 )-> CGFloat {
        return -(vn.x * (x - v0.x) + vn.y * (y - v0.y) + vn.z * (z - v0.z) ) / (vn.x * vd.x + vn.y * vd.y + vn.z * vd.z)
    }
    
    func isParallelTo(_ v:SCNVector3 ) -> Bool {
        let dp = dotProduct(v)
        
        if Swift.abs(dp/self.abs()/v.abs() - 1) <= 1e-5  {
            return true
        }
        
        return false
    }
    
    func isPerpendicularTo(_ v:SCNVector3 ) -> Bool {
        let dp = self.dotProduct(v)
        
        if Swift.abs(dp)/self.abs()/v.abs() <= 1e-5 {
            return true
        }
        
        return false
    }
    
    mutating func rotateAroundX(_ inPhi: CGFloat) {
        let c = cos(inPhi)
        let s = sin(inPhi)
        let tempY = y
        
        y = c * tempY - s * z
        z = s * tempY + c * z
    }
    
    mutating func rotateAroundY(_ inPhi: CGFloat) {
        let c = cos(inPhi)
        let s = sin(inPhi)
        let tempZ = z
        
        z = c * tempZ - s * x
        x = s * tempZ + c * x
    }
    
    mutating func rotateAroundZ(_ inPhi: CGFloat) {
        let c = cos(inPhi)
        let s = sin(inPhi)
        let tempX = x
        
        x = c * tempX - s * y
        y = s * tempX + c * y
    }
    
    mutating func  rotateAroundAxis(_ u:SCNVector3, byAngle theta:CGFloat) {
        //http://en.wikipedia.org/wiki/Rotation_matrix
        
        let cosTheta = cos(theta)
        let sinTheta = sin(theta)
        let oneMinusCosTheta = 1 - cosTheta
        
        let ux:CGFloat = u.x
        let uy:CGFloat = u.y
        let uz:CGFloat = u.z
        
        let X = x
        let Y = y
        let Z = z
        
        x = (cosTheta + ux * ux * oneMinusCosTheta ) * X + (ux*uy * oneMinusCosTheta - uz * sinTheta) * Y
        x = x + (ux * uz * oneMinusCosTheta + uy * sinTheta ) * Z
        y = (uy*ux * oneMinusCosTheta + uz * sinTheta) * X + (cosTheta + uy * uy * oneMinusCosTheta ) * Y
        y = y + (uy * uz * oneMinusCosTheta - ux * sinTheta ) * Z
        z = (uz*ux * oneMinusCosTheta - uy * sinTheta) * X + (uz * uy * oneMinusCosTheta + ux * sinTheta) * Y
        z = z + (cosTheta + uz*uz * oneMinusCosTheta) * Z
    }

    static func ==(left: SCNVector3, right: SCNVector3) -> Bool {
        let diff = (left-right).abs()
        
        if diff < 1e-6 {
            return true
        }
        return false
    }
    
    static prefix func - (vector: SCNVector3) -> SCNVector3 {
        return SCNVector3(x: -vector.x, y: -vector.y, z:-vector.z)
    }
    
    static func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(x: left.x + right.x, y: left.y + right.y, z:left.z + right.z)
    }
    
    static func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(x: left.x - right.x, y: left.y - right.y, z:left.z - right.z)
    }
    
    static func * (left: SCNVector3, scalar: CGFloat) -> SCNVector3 {
        return SCNVector3(x: left.x * scalar, y: left.y * scalar, z:left.z * scalar)
    }
    
    static func * (scalar: CGFloat, left: SCNVector3) -> SCNVector3 {
        return SCNVector3(x: left.x * scalar, y: left.y * scalar, z:left.z * scalar)
    }
    
    static func / (left: SCNVector3, scalar: CGFloat) -> SCNVector3 {
        return SCNVector3(x: left.x / scalar, y: left.y / scalar, z:left.z / scalar)
    }
    
    static func += ( left: inout SCNVector3, right: SCNVector3) {
        left.x += right.x
        left.y += right.y
        left.z += right.z
    }
    
    static func -= ( left: inout SCNVector3, right: SCNVector3) {
        left.x -= right.x
        left.y -= right.y
        left.z -= right.z
    }
    
    static func *= ( left: inout SCNVector3, scalar: CGFloat) {
        left.x *= scalar
        left.y *= scalar
        left.z *= scalar
    }
    
    static func /= ( left: inout SCNVector3, scalar: CGFloat) {
        left.x /= scalar
        left.y /= scalar
        left.z /= scalar
    }

    static func • (left: SCNVector3, right: SCNVector3 ) -> CGFloat {
        return left.dotProduct(right)
    }

    static func ⨉ (left: SCNVector3, right: SCNVector3 ) -> CGFloat {
        return left.dotProduct(right)
    }
}

extension float3 {
    // https://developer.apple.com/documentation/accelerate/simd/working_with_vectors

    var x:Float {
        get {
            return self[0]
        }
    }

    var y:Float {
        get {
            return self[1]
        }
    }

    var z:Float {
        get {
            return self[2]
        }
    }

    func norm() -> Float {
        return simd.length_squared(self)-1
    }

    func abs() -> Float {
        return simd.length(self)
    }

    mutating func normalize() throws -> float3 {
        self = simd.normalize(self)
        return self
    }

    mutating func addScaledVector(_ theVector:float3, scale theScale:Float) {
        self += theVector * theScale
    }

    func dotProduct(_ theVector : float3 ) -> Float {
        return simd.dot(self,theVector)
    }

    func normalizedDotProduct(_ theVector : float3 ) -> Float {
        var prod = simd.dot(self,theVector)

        let norm_u = self.norm()
        let norm_v = theVector.norm()

        if norm_u != 0 && norm_v != 0 {
            prod /= sqrt(norm_u * norm_v);
        }

        if prod > 1 {
            return 1
        } else if prod < -1 {
            return -1
        }

        return simd.dot(self,theVector)
    }

    func crossProduct(_ theVector: float3) -> float3 {
        return  simd.cross(self, theVector)
    }

    func normalizedCrossProduct(_ theVector: float3) -> float3 {
        var prod = simd.cross(self, theVector)
        
        let norm_u = simd.norm_one(self)
        let norm_v = simd.norm_one(theVector)

        if norm_u != 0 && norm_v != 0 {
            prod /= sqrt(norm_u * norm_v)
        }

        let norm_t = simd.norm_one(prod)
        if norm_t > 1 {
            prod /= sqrt(norm_t);
        }

        return float3(prod)
    }

    func tripleProduct(v : float3, w : float3) -> Float {
        let cp = self.crossProduct(v)
        return cp.dotProduct(w)
    }

    func orientedAngleWith(_ y:float3 , aroundAxis r:float3 ) -> Float {
        let sinPhi = self.normalizedCrossProduct(y)

        var phi = asin(sinPhi.abs())

        if self.dotProduct(y) <= 0 {
            phi = .pi - phi
        }

        if sinPhi.dotProduct(r) <= 0 {
            phi *= -1
        }

        return phi
    }

    func isParallelTo(_ v:float3 ) -> Bool {
        let dp = dotProduct(v)

        if Swift.abs(dp/self.abs()/v.abs() - 1) <= 1e-5  {
            return true
        }

        return false
    }

    func isPerpendicularTo(_ v:float3 ) -> Bool {
        let dp = self.dotProduct(v)

        if Swift.abs(dp)/self.abs()/v.abs() <= 1e-5 {
            return true
        }

        return false
    }

    mutating func rotateAroundX(_ phi: Float) {
        let c = cos(phi)
        let s = sin(phi)
        
        self = float3(self[0], c * self[1] - s * self[2], s * self[1] + c * self[2])
    }

    mutating func rotateAroundY(_ phi: Float) {
        let c = cos(phi)
        let s = sin(phi)
        
        self = float3(s * self[2] + c * self[0], self[1], s * self[2] - s * self[0])
    }

    mutating func rotateAroundZ(_ phi: Float) {
        let c = cos(phi)
        let s = sin(phi)

        self = float3(c * self[0] - s * self[1], s * self[0] + c * self[1], self[2])
    }

    mutating func rotateAroundAxis(_ u:float3, byAngle theta:Float) {
        self = float3x3.rotationMatrixAround(axis: u, angle: theta) * self
    }
    
    static func • (left: float3, right: float3 ) -> Float {
        return left.dotProduct(right)
    }
    
    static func ⨉ (left: float3, right: float3 ) -> Float {
        return left.dotProduct(right)
    }
}

extension float4 {
    init(_ x:Float,_ y:Float, _ z:Float ) {
        self.init(x,y,z,1)
    }
    init(x:Float,y:Float, z:Float ) {
        self.init(x,y,z,1)
    }

    var x:Float {
        get {
            return self[0]
        }
    }
    
    var y:Float {
        get {
            return self[1]
        }
    }
    
    var z:Float {
        get {
            return self[2]
        }
    }

    var w:Float {
        get {
            return self[3]
        }
    }

    func norm() -> Float {
        return simd.length_squared(self) - 1
    }
    
    func abs() -> Float {
        return simd.length(self)
    }
    
    mutating func normalize() throws -> float4 {
        self = simd.normalize(self)
        return self
    }
    
    mutating func addScaledVector(_ theVector:float4, scale theScale:Float) {
        self += theVector * theScale
    }
    
    func dotProduct(_ theVector : float4 ) -> Float {
        return simd.dot(self,theVector)
    }
    
    func normalizedDotProduct(_ theVector : float4 ) -> Float {
        var prod = simd.dot(self,theVector)
        
        let norm_u = self.norm()
        let norm_v = theVector.norm()
        
        if norm_u != 0 && norm_v != 0 {
            prod /= sqrt(norm_u * norm_v);
        }
        
        if prod > 1 {
            return 1
        } else if prod < -1 {
            return -1
        }
        
        return simd.dot(self,theVector)
    }
    
    func crossProduct(_ theVector: float4) -> float4 {
        let u = float3(self[0],self[1],self[2])
        let v = float3(theVector[0],theVector[1],theVector[2])
        let w = u.crossProduct(v)
        
        return  float4(w[0],w[1],w[2],1)
    }
    
    func normalizedCrossProduct(_ theVector: float4) -> float4 {
        var prod = crossProduct(theVector)
        
        let norm_u = simd.length_squared(self)
        let norm_v = simd.length_squared(theVector)
        
        if norm_u != 0 && norm_v != 0 {
            prod /= sqrt(norm_u * norm_v)
        }
        
        let norm_t = simd.length_squared(prod)
        if norm_t > 1 {
            prod /= sqrt(norm_t);
        }
        
        return prod
    }
    
    func tripleProduct(v : float4, w : float4) -> Float {
        let cp = self.crossProduct(v)
        return cp.dotProduct(w)
    }
    
    func orientedAngleWith(_ y:float4 , aroundAxis r:float4 ) -> Float {
        let sinPhi = self.normalizedCrossProduct(y)
        
        var phi = asin(sinPhi.abs())
        
        if self.dotProduct(y) <= 0 {
            phi = .pi - phi
        }
        
        if sinPhi.dotProduct(r) <= 0 {
            phi *= -1
        }
        
        return phi
    }
    
    func isParallelTo(_ v:float4 ) -> Bool {
        let dp = dotProduct(v)
        
        if Swift.abs(dp/self.abs()/v.abs() - 1) <= 1e-5  {
            return true
        }
        
        return false
    }
    
    func isPerpendicularTo(_ v:float4 ) -> Bool {
        let dp = self.dotProduct(v)
        
        if Swift.abs(dp)/self.abs()/v.abs() <= 1e-5 {
            return true
        }
        
        return false
    }
    
    mutating func rotateAroundX(_ phi: Float) {
        let c = cos(phi)
        let s = sin(phi)
        
        self = float4(arrayLiteral: self[0], c * self[1] - s * self[2], s * self[1] + c * self[2], 1)
    }
    
    mutating func rotateAroundY(_ phi: Float) {
        let c = cos(phi)
        let s = sin(phi)
        
        self = float4(s * self[2] + c * self[0], self[1], s * self[2] - s * self[0], 1)
    }
    
    mutating func rotateAroundZ(_ phi: Float) {
        let c = cos(phi)
        let s = sin(phi)
        
        self = float4(c * self[0] - s * self[1], s * self[0] + c * self[1], self[2], 1)
    }
    
    mutating func rotateAroundAxis(_ u:float4, byAngle theta:Float) {
        self = float4x4.rotationMatrixAround(axis: u, angle: theta) * self
    }
    
    static func • (left: float4, right: float4 ) -> Float {
        return left.dotProduct(right)
    }
    
    static func ⨉ (left: float4, right: float4 ) -> Float {
        return left.dotProduct(right)
    }
}

extension float3x3 {
    static func rotationMatrixAround(axis:float3, angle:Float) -> float3x3 {
        return rotate(radians: angle, axis: axis)
    }
    
    static func scale(sx: Float, sy: Float, sz: Float) -> float3x3 {
        // https://github.com/MetalKit/metal/blob/master/raytracing/Transforms.swift
        return float3x3(
            float3(sx,   0,   0),
            float3( 0,  sy,   0),
            float3( 0,   0,  sz)
        )
    }

    static func rotate(radians: Float, axis: float3) -> float3x3 {
        let normalizedAxis = normalize(axis)
        let x = normalizedAxis.x, y = normalizedAxis.y, z = normalizedAxis.z
        let ct = cosf(radians)
        let st = sinf(radians)
        let ci = 1 - ct
        
        return float3x3(
            float3(    ct + x * x * ci,  y * x * ci + z * st,  z * x * ci - y * st),
            float3(x * y * ci - z * st,      ct + y * y * ci,  z * y * ci + x * st),
            float3(x * z * ci + y * st,  y * z * ci - x * st,      ct + z * z * ci)
        )
    }
    
    static func rotateX(radians: Float) -> float3x3 {
        return rotate(radians: radians, axis: float3(1,0,0))
    }
    
    static func rotateY(radians: Float) -> float3x3 {
        return rotate(radians: radians, axis: float3(0,1,0))
    }
    
    static func rotateZ(radians: Float) -> float3x3 {
        return rotate(radians: radians, axis: float3(0,0,1))
    }
}

extension float4x4 {
    static func translate(tx: Float, ty: Float, tz: Float) -> float4x4 {
        return float4x4(
            float4( 1,  0,  0,  0),
            float4( 0,  1,  0,  0),
            float4( 0,  0,  1,  0),
            float4(tx, ty, tz,  1)
        )
    }

    static func rotationMatrixAround(axis:float4, angle:Float) -> float4x4 {
        return rotate(radians: angle, axis: axis)
    }

    static func rotate(radians: Float, axis: float4) -> float4x4 {
        let normalizedAxis = normalize(axis)
        let ct = cosf(radians)
        let st = sinf(radians)
        let ci = 1 - ct
        let x = normalizedAxis.x, y = normalizedAxis.y, z = normalizedAxis.z
        
        return float4x4(
            float4(    ct + x * x * ci,  y * x * ci + z * st,  z * x * ci - y * st,  0),
            float4(x * y * ci - z * st,      ct + y * y * ci,  z * y * ci + x * st,  0),
            float4(x * z * ci + y * st,  y * z * ci - x * st,      ct + z * z * ci,  0),
            float4(                  0,                    0,                    0,  1)
        )
    }

    static func rotateX(radians: Float) -> float4x4 {
        return rotate(radians: radians, axis: float4(1,0,0,1))
    }

    static func rotateY(radians: Float) -> float4x4 {
        return rotate(radians: radians, axis: float4(0,1,0,1))
    }

    static func rotateZ(radians: Float) -> float4x4 {
        return rotate(radians: radians, axis: float4(0,0,1,1))
    }

    static func scale(sx: Float, sy: Float, sz: Float) -> float4x4 {
        return float4x4(
            float4(sx,   0,   0,  0),
            float4( 0,  sy,   0,  0),
            float4( 0,   0,  sz,  0),
            float4( 0,   0,   0,  1)
        )
    }
}

struct Matrix {
    var m:[float]
    
    init(array:[float]? = nil) {
        if array != nil {
            m = array!
        } else {
            m = [float](repeating: 0, count: 9)
        }
    }
    
    static func matIndex(row:Int, col:Int) -> Int {
        return col + 3*row
    }
    
    static func * (left: Matrix, right: Matrix) -> Matrix {
        // Symbolically: p(i,j) = Sum_u Sum_v left(u,j) * right(i,v)
        var product = Matrix()
        for j in 0...3 {
            for i in 0...3 {
                let p = matIndex(row:i,col:j)
                for v in 0...3 {
                    let r = matIndex(row:i,col:v)
                    for u in 0...3 {
                        let l = matIndex(row:u,col:j)
                        product.m[p] += left.m[l] * right.m[r]
                    }
                }
            }
        }
        return product
    }
    
    static func + (left: Matrix, right: Matrix) -> Matrix {
        // Symbolically: p(i,j) = left(i,j) + right(i,j)
        var sum = Matrix()
        for j in 0...3 {
            for i in 0...3 {
                let s = matIndex(row:i,col:j)
                sum.m[s] += left.m[s] * right.m[s]
            }
        }
        return sum
    }
    
}

extension Array where Element == float4 {
    // https://developer.apple.com/documentation/accelerate/simd/working_with_vectors
    
    func norm() -> [Float] {
        var results = [Float](repeating: 0, count: self.count)
        for (i,v) in self.enumerated() {
            results[i] = simd.length_squared(v)
        }
        return results
    }
    
    func abs() -> [Float] {
        var results = [Float](repeating: 0, count: self.count)
        for (i,v) in self.enumerated() {
            results[i] = simd.length(v)
        }
        return results
    }
    
    mutating func normalize() throws -> [float4] {
        for (i,v) in self.enumerated() {
            self[i] = simd.normalize(v)
        }
        return self
    }
    
//    mutating func addScaledVector(_ theVector:float4, scale theScale:Float) {
//        self += theVector * theScale
//    }
    
    func dotProduct(_ vectors : [float4] ) -> [Float] {
        var results = [Float](repeating: 0, count: self.count)
        for (i,v) in self.enumerated() {
            results[i] = simd.dot(v,vectors[i])
        }
        return results
    }
    
    func normalizedDotProduct(_ vectors : [float4] ) -> [Float] {
        var results = [Float](repeating: 0, count: self.count)
        for (i,u) in self.enumerated() {
            let v = vectors[i]
            var prod = u.dotProduct(v)
            let norm_u = u.norm()
            let norm_v = v.norm()
            if norm_u != 0 && norm_v != 0 {
                prod /= sqrt(norm_u * norm_v);
            }
            if prod > 1 {
                prod = 1
            } else if prod < -1 {
                prod = -1
            }
            results[i] = prod
        }
        return results
    }
    
    func crossProduct(_ vectors: [float4]) -> [float4] {
        var results:[float4] = [float4](repeating: float4(0,0,0), count: self.count)

        for (i,u) in self.enumerated() {
            results[i] = u.crossProduct(vectors[i])
        }
        return results
    }
    
    func normalizedCrossProduct(_ vectors: [float4]) -> [float4] {
        var results:[float4] = [float4](repeating: float4(0,0,0), count: self.count)

        for (i,u) in self.enumerated() {
            let v = vectors[i]
            var prod = u.crossProduct(v)
            let norm_u = simd.length_squared(u)
            let norm_v = simd.length_squared(v)

            if norm_u != 0 && norm_v != 0 {
                prod /= sqrt(norm_u * norm_v)
            }
            
            let norm_t = simd.norm_one(prod)
            if norm_t > 1 {
                prod /= sqrt(norm_t);
            }

            results[i] = prod
        }
        return results
    }

    func tripleProduct(v : [float4], w : [float4]) -> [Float] {
        var results = [Float](repeating: 0, count: self.count)
        for (i,u) in self.enumerated() {
            let cp = u.crossProduct(v[i])
            results[i] = cp.dotProduct(w[i])
        }
        return results
    }

    func orientedAngleWith(_ y:[float4] , aroundAxis r:[float4] ) -> [Float] {
        var results = [Float](repeating: 0, count: self.count)
        let sinɸ̂ = self.normalizedCrossProduct(y)
        let sinɸ̂Dotr = sinɸ̂.dotProduct(r)
        let uDoty = self.dotProduct(y)
        for (i,_) in self.enumerated() {
            var ɸ = asin(sinɸ̂[i].abs())

            if uDoty[i] <= 0 {
                ɸ = .pi - ɸ
            }

            if sinɸ̂Dotr[i] <= 0 {
                ɸ = -ɸ
            }
            results[i] = ɸ
        }
        
        return results
    }
//
//    func isParallelTo(_ v:float3 ) -> Bool {
//        let dp = dotProduct(v)
//
//        if Swift.abs(dp/self.abs()/v.abs() - 1) <= 1e-5  {
//            return true
//        }
//
//        return false
//    }
//
//    func isPerpendicularTo(_ v:float3 ) -> Bool {
//        let dp = self.dotProduct(v)
//
//        if Swift.abs(dp)/self.abs()/v.abs() <= 1e-5 {
//            return true
//        }
//
//        return false
//    }
//
//    mutating func rotateAroundX(_ phi: Float) {
//        let c = cos(phi)
//        let s = sin(phi)
//
//        self = float3(self[0], c * self[1] - s * self[2], s * self[1] + c * self[2])
//    }
//
//    mutating func rotateAroundY(_ phi: Float) {
//        let c = cos(phi)
//        let s = sin(phi)
//
//        self = float3(s * self[2] + c * self[0], self[1], s * self[2] - s * self[0])
//    }
//
//    mutating func rotateAroundZ(_ phi: Float) {
//        let c = cos(phi)
//        let s = sin(phi)
//
//        self = float3(c * self[0] - s * self[1], s * self[0] + c * self[1], self[2])
//    }
//
//    mutating func rotateAroundAxis(_ u:float3, byAngle theta:Float) {
//        self = float3x3.rotationMatrixAround(axis: u, angle: theta) * self
//    }
//
//    static func • (left: float3, right: float3 ) -> Float {
//        return left.dotProduct(right)
//    }
//
//    static func ⨉ (left: float3, right: float3 ) -> Float {
//        return left.dotProduct(right)
//    }

}

