//
//  SCNVectorExtension.swift
//  MonteCarlo3D
//
//  Created by Daniel Côté on 2015-03-23.
//  Copyright (c) 2015 Daniel Côté. All rights reserved.
//

import Foundation
import SceneKit

typealias Float = CGFloat
typealias Vector = SCNVector3
typealias Vector3D = Vector

let π:Float = 3.1415926535
enum VectorError: LocalizedError {
    case UnexpectedNil
}

enum Axis:Int {
    case X=0,Y=1,Z=2
}

extension Vector {
    public var description: String {
        return "(\(x),\(y),\(z))"
    }
    
    subscript(index: Axis) -> Float {
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
    
    func norm() -> Float {
        return x*x + y*y + z*z
    }
    
    func abs() -> Float {
        return sqrt(x*x + y*y + z*z)
    }
    
    mutating func normalize() throws {
        let value = sqrt(x*x + y*y + z*z)

        if value != 0 {
            x = x / value
            y = y / value
            z = z / value
        } else {
            throw VectorError.UnexpectedNil
        }
    }
    
    mutating func addScaledVector(_ theVector:Vector, scale theScale:Float) {
        x += theVector.x * theScale;
        y += theVector.y * theScale;
        z += theVector.z * theScale;
    }
    
    func dotProduct(_ theVector : Vector ) -> Float {
        return x * theVector.x + y * theVector.y + z * theVector.z;
    }
    
    func normalizedDotProduct(_ theVector: Vector ) -> Float {
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
    
    func tripleProduct(v : Vector, w : Vector) -> Float {
        let cp = crossProduct(v)
        
        return cp.dotProduct(w)
    }
    
    func orientedAngleWith(_ y:Vector , aroundAxis r:Vector ) -> Float {
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
    
    func distanceToPlaneWithOrigin(origin v0: Vector, normal vn:Vector, alongVector vd:Vector )-> Float {
        return -(vn.x * (x - v0.x) + vn.y * (y - v0.y) + vn.z * (z - v0.z) ) / (vn.x * vd.x + vn.y * vd.y + vn.z * vd.z)
    }
    
    func isParallelTo(_ v:Vector ) -> Bool {
        let dp = self.dotProduct(v)
        
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
    
    mutating func rotateAroundX(_ inPhi: Float) {
        let c = cos(inPhi)
        let s = sin(inPhi)
        let tempY = y
        
        y = c * tempY - s * z
        z = s * tempY + c * z
    }
    
    mutating func rotateAroundY(_ inPhi: Float) {
        let c = cos(inPhi)
        let s = sin(inPhi)
        let tempZ = z
        
        z = c * tempZ - s * x
        x = s * tempZ + c * x
    }
    
    mutating func rotateAroundZ(_ inPhi: Float) {
        let c = cos(inPhi)
        let s = sin(inPhi)
        let tempX = x
        
        x = c * tempX - s * y
        y = s * tempX + c * y
    }
    
    mutating func  rotateAroundAxis(_ u:Vector, byAngle theta:Float) {
        //http://en.wikipedia.org/wiki/Rotation_matrix
        
        let cosTheta = cos(theta)
        let sinTheta = sin(theta)
        let oneMinusCosTheta = 1 - cosTheta
        
        let ux:Float = u.x
        let uy:Float = u.y
        let uz:Float = u.z
        
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
    
    static func * (left: Vector, scalar: Float) -> Vector {
        return Vector(x: left.x * scalar, y: left.y * scalar, z:left.z * scalar)
    }
    
    static func * (scalar: Float, left: Vector) -> Vector {
        return Vector(x: left.x * scalar, y: left.y * scalar, z:left.z * scalar)
    }
    
    static func / (left: Vector, scalar: Float) -> Vector {
        return Vector(x: left.x / scalar, y: left.y / scalar, z:left.z / scalar)
    }
    
//    static func × (left: Vector, right: Vector) -> Vector {
//        return left.crossProduct(right)
//    }
//    
//    static func • (left: Vector, right: Vector) -> Float {
//        return left.dotProduct(right)
//    }
//    
//    static func ⟂ (left: Vector, right: Vector) -> Bool {
//        return left.isPerpendicularTo(right)
//    }
//    
//    static func ‖ (left: Vector, right: Vector) -> Bool {
//        return left.isParallelTo(right)
//    }
//    
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
    
    static func *= ( left: inout Vector, scalar: Float) {
        left.x *= scalar
        left.y *= scalar
        left.z *= scalar
    }
    
    static func /= ( left: inout Vector, scalar: Float) {
        left.x /= scalar
        left.y /= scalar
        left.z /= scalar
    }

}
