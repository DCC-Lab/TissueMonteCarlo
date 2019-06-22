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

//public func * <T>(_ x: T, _ y:T) -> T where T: Mathable {
//    return x * y
//}
//
//public func cos<T>(_ x: T) -> T where T: Mathable {
//    return T.Math.cos(x)
//}
//
//public func sin<T>(_ x: T) -> T where T: Mathable {
//    return T.Math.sin(x)
//}
//
//public func log<T>(_ x: T) -> T where T: Mathable {
//    return T.Math.log(x)
//}

protocol VectorProtocol {
    associatedtype T:BinaryFloatingPoint
    associatedtype V:VectorProtocol where V.T == T
    var x:T {get set}
    var y:T {get set}
    var z:T {get set}
    var supportsTranslation:Bool {get}
    static var xHat:V {get}
    static var yHat:V {get}
    static var zHat:V {get}
    static var oHat:V {get}

    init(_ x:T,_ y:T,_ z:T)

    func norm() -> T
    func abs() -> T
    func dotProduct(_ theVector : V ) -> T
    func normalizedDotProduct(_ theVector: V ) -> T
    func crossProduct(_ v: V) -> V
    func normalizedCrossProduct(_ v: V) -> V

    func orientedAngleWith(_ y:V , aroundAxis r:V ) -> T
    func isParallelTo(_ v:V ) -> Bool
    func isPerpendicularTo(_ v:V ) -> Bool

    mutating func normalize() throws -> V
    mutating func addScaledVector(_ theVector:V, scale theScale:T)
    mutating func rotateAroundX(_ inPhi: T)
    mutating func rotateAroundY(_ inPhi: T)
    mutating func rotateAroundZ(_ inPhi: T)
    mutating func rotateAroundAxis(_ u:V, byAngle theta:T)

}

extension VectorProtocol {
    static var xHat:V {
        get { return V(1,0,0)}
    }
    static var yHat:V {
        get { return V(0,1,0)}
    }
    static var zHat:V {
        get { return V(0,0,1)}
    }
    static var oHat:V {
        get { return V(0,0,0)}
    }

    func normalizedDotProduct(_ theVector: V ) -> T {
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

}

protocol MatrixProtocol {
    associatedtype T
    associatedtype V:VectorProtocol where V.T == T
    associatedtype M:MatrixProtocol where M.T == T, M.V == V

    static func translate(tx: T, ty: T, tz: T) -> M
    static func translate(_ d:V) -> M
    static func rotationMatrixAround(axis:V, angle:T) -> M
    static func rotate(radians: T, axis: V) -> M
    static func rotateX(radians: T) -> M
    static func rotateY(radians: T) -> M
    static func rotateZ(radians: T) -> M
    static func scale(sx: T, sy: T, sz: T) -> M
}

enum VectorError: LocalizedError {
    case UnexpectedNil
}

infix operator •: MultiplicationPrecedence
infix operator ⨉: MultiplicationPrecedence

extension SCNVector3:VectorProtocol {
    init(_ x:CGFloat,_ y:CGFloat,_ z:CGFloat) {
        self.init(x:x, y:y, z:z)
    }

    var supportsTranslation:Bool {
        return false
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

extension float3:VectorProtocol {
    static var xHat: float3 {
        get { return float3(1,0,0) }
    }
    static var yHat: float3 {
        get { return float3(0,1,0) }
    }
    static var zHat: float3 {
        get { return float3(0,0,1) }
    }
    static var oHat: float3 {
        get { return float3(0,0,0) }
    }
    
    var supportsTranslation:Bool {
        return false
    }

    var x:Float {
        get { return self[0] }
    }

    var y:Float {
        get { return self[1] }
    }

    var z:Float {
        get { return self[2] }
    }

    func norm() -> Float {
        return simd.norm_one(self)-1
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

extension float4 : VectorProtocol {
    static var xHat: float4 {
        get { return float4(1,0,0,1) }
    }
    static var yHat: float4 {
        get { return float4(0,1,0,1) }
    }
    static var zHat: float4 {
        get { return float4(0,0,1,1) }
    }
    static var oHat: float4 {
        get { return float4(0,0,0,0) }
    }

    init(_ x:Float,_ y:Float, _ z:Float ) {
        self.init(x,y,z,1)
    }
    init(x:Float,y:Float, z:Float ) {
        self.init(x,y,z,1)
    }

    var supportsTranslation:Bool {
        return true
    }

    var x:Float {
        get { return self[0] }
    }
    
    var y:Float {
        get { return self[1] }
    }
    
    var z:Float {
        get { return self[2] }
    }

    var w:Float {
        get { return self[3] }
    }

    func norm() -> Float {
        return simd.norm_one(self) - 1
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
        return simd.dot(self,theVector) - 1
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
        
        let norm_u = simd.norm_one(self)
        let norm_v = simd.norm_one(theVector)
        
        if norm_u != 0 && norm_v != 0 {
            prod /= sqrt(norm_u * norm_v)
        }
        
        let norm_t = simd.norm_one(prod)
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

extension float3x3 : MatrixProtocol {
    static func translate(tx: Float, ty: Float, tz: Float) -> float3x3 {
        return float3x3(0)
    }
    
    static func translate(_ d: float3) -> float3x3 {
        return float3x3(0)
    }
    
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

extension float4x4 : MatrixProtocol {
    static func translate(tx: Float, ty: Float, tz: Float) -> float4x4 {
        return float4x4(
            float4( 1,  0,  0,  0),
            float4( 0,  1,  0,  0),
            float4( 0,  0,  1,  0),
            float4(tx, ty, tz,  1)
        )
    }

    static func translate(_ d:float4) -> float4x4 {
        return float4x4(
            float4( 1,  0,  0,  0),
            float4( 0,  1,  0,  0),
            float4( 0,  0,  1,  0),
            d
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

