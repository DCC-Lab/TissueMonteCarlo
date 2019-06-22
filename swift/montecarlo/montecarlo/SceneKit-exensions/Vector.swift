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

typealias float = CGFloat
typealias Vector = SCNVector3
typealias Vector3D = Vector
typealias v⃗ = Vector

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

extension Vector {
    init(_ x:float,_ y:float,_ z:float) {
        self.init(x:x, y:y, z:z)
    }
    
    public var description: String {
        return "(\(x),\(y),\(z))"
    }
    
    subscript(index: Axis) -> float {
        get {
            switch index {
            case .X:
                return x
            case .Y:
                return y
            case .Z:
                return z
            }
        }
    
        set(newValue) {
            switch index {
            case .X:
                x = newValue
            case .Y:
                y = newValue
            case .Z:
                z = newValue
            }
        }
    }
    
    func norm() -> float {
        return x*x + y*y + z*z
    }
    
    func abs() -> float {
        return sqrt(x*x + y*y + z*z)
    }
    
    mutating func normalize() throws -> Vector{
        let value = sqrt(x*x + y*y + z*z)

        if value != 0 {
            x = x / value
            y = y / value
            z = z / value
        } else {
            throw VectorError.UnexpectedNil
        }
        return self
    }
    
    mutating func addScaledVector(_ theVector:Vector, scale theScale:float) {
        x += theVector.x * theScale;
        y += theVector.y * theScale;
        z += theVector.z * theScale;
    }
    
    func dotProduct(_ theVector : Vector ) -> float {
        return x * theVector.x + y * theVector.y + z * theVector.z;
    }
    
    func normalizedDotProduct(_ theVector: Vector ) -> float {
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
    
    func crossProduct(_ v: Vector) -> Vector {
        return  Vector(x:y * v.z - z * v.y,  y:z * v.x - x * v.z,  z: x * v.y - y * v.x)
    }
    
    func normalizedCrossProduct(_ v: Vector) -> Vector {
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
    
    func tripleProduct(v : Vector, w : Vector) -> float {
        let cp = crossProduct(v)
        
        return cp.dotProduct(w)
    }
    
    func orientedAngleWith(_ y:Vector , aroundAxis r:Vector ) -> float {
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
    
    func distanceToPlaneWithOrigin(origin v0: Vector, normal vn:Vector, alongVector vd:Vector )-> float {
        return -(vn.x * (x - v0.x) + vn.y * (y - v0.y) + vn.z * (z - v0.z) ) / (vn.x * vd.x + vn.y * vd.y + vn.z * vd.z)
    }
    
    func isParallelTo(_ v:Vector ) -> Bool {
        let dp = dotProduct(v)
        
        if Swift.abs(dp/self.abs()/v.abs() - 1) <= 1e-5  {
            return true
        }
        
        return false
    }
    
    func isPerpendicularTo(_ v:Vector ) -> Bool {
        let dp = self.dotProduct(v)
        
        if Swift.abs(dp)/self.abs()/v.abs() <= 1e-5 {
            return true
        }
        
        return false
    }
    
    mutating func rotateAroundX(_ inPhi: float) {
        let c = cos(inPhi)
        let s = sin(inPhi)
        let tempY = y
        
        y = c * tempY - s * z
        z = s * tempY + c * z
    }
    
    mutating func rotateAroundY(_ inPhi: float) {
        let c = cos(inPhi)
        let s = sin(inPhi)
        let tempZ = z
        
        z = c * tempZ - s * x
        x = s * tempZ + c * x
    }
    
    mutating func rotateAroundZ(_ inPhi: float) {
        let c = cos(inPhi)
        let s = sin(inPhi)
        let tempX = x
        
        x = c * tempX - s * y
        y = s * tempX + c * y
    }
    
    mutating func  rotateAroundAxis(_ u:Vector, byAngle theta:float) {
        //http://en.wikipedia.org/wiki/Rotation_matrix
        
        let cosTheta = cos(theta)
        let sinTheta = sin(theta)
        let oneMinusCosTheta = 1 - cosTheta
        
        let ux:float = u.x
        let uy:float = u.y
        let uz:float = u.z
        
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

    static func ==(left: Vector, right: Vector) -> Bool {
        let diff = (left-right).abs()
        
        if diff < 1e-6 {
            return true
        }
        return false
    }
    
    static prefix func - (vector: Vector) -> Vector {
        return Vector(x: -vector.x, y: -vector.y, z:-vector.z)
    }
    
    static func + (left: Vector, right: Vector) -> Vector {
        return Vector(x: left.x + right.x, y: left.y + right.y, z:left.z + right.z)
    }
    
    static func - (left: Vector, right: Vector) -> Vector {
        return Vector(x: left.x - right.x, y: left.y - right.y, z:left.z - right.z)
    }
    
    static func * (left: Vector, scalar: float) -> Vector {
        return Vector(x: left.x * scalar, y: left.y * scalar, z:left.z * scalar)
    }
    
    static func * (scalar: float, left: Vector) -> Vector {
        return Vector(x: left.x * scalar, y: left.y * scalar, z:left.z * scalar)
    }
    
    static func / (left: Vector, scalar: float) -> Vector {
        return Vector(x: left.x / scalar, y: left.y / scalar, z:left.z / scalar)
    }
    
    static func += ( left: inout Vector, right: Vector) {
        left.x += right.x
        left.y += right.y
        left.z += right.z
    }
    
    static func -= ( left: inout Vector, right: Vector) {
        left.x -= right.x
        left.y -= right.y
        left.z -= right.z
    }
    
    static func *= ( left: inout Vector, scalar: float) {
        left.x *= scalar
        left.y *= scalar
        left.z *= scalar
    }
    
    static func /= ( left: inout Vector, scalar: float) {
        left.x /= scalar
        left.y /= scalar
        left.z /= scalar
    }

}

extension float3 {
//    convenience init(_ x:Float,_ y:Float,_ z:Float) {
//        self.init(float3(x,y,z))
//    }

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

//    public var description: String {
//        return "(\(x),\(y),\(z))"
//    }
//
    func norm() -> Float {
        return simd.norm_one(self)
    }

    func abs() -> Float {
        return simd.length(self)
    }

    func normalize() throws -> float3 {
        return simd.normalize(self)
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

//
//    func tripleProduct(v : Vector, w : Vector) -> Float {
//        let cp = crossProduct(v)
//
//        return cp.dotProduct(w)
//    }
//
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
//
//    func distanceToPlaneWithOrigin(origin v0: Vector, normal vn:Vector, alongVector vd:Vector )-> Float {
//        return -(vn.x * (x - v0.x) + vn.y * (y - v0.y) + vn.z * (z - v0.z) ) / (vn.x * vd.x + vn.y * vd.y + vn.z * vd.z)
//    }
//
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

    mutating func rotateAroundAxis(_ u:float3, byAngle theta:Float) -> float3 {
        let rot = float3x3.rotationMatrixAround(axis: u, angle: theta)
        return rot * self
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

extension float3x3 {
    static func rotationMatrixAround(axis:float3, angle:Float) -> float3x3 {
        let normalizedAxis = try! axis.normalize()
        let ct = cosf(angle)
        let st = sinf(angle)
        let ci = 1 - ct
        let x = normalizedAxis.x, y = normalizedAxis.y, z = normalizedAxis.z
        
        // https://github.com/MetalKit/metal/blob/master/raytracing/Transforms.swift
        let rot = float3x3(
            float3(    ct + x * x * ci,  y * x * ci + z * st,  z * x * ci - y * st),
            float3(x * y * ci - z * st,      ct + y * y * ci,  z * y * ci + x * st),
            float3(x * z * ci + y * st,  y * z * ci - x * st,      ct + z * z * ci))
        return rot
    }
}
