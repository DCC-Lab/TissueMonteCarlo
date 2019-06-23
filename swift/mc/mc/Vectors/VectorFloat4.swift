//
//  VectorFloat4.swift
//  mc
//
//  Created by Daniel Côté on 2019-06-23.
//  Copyright © 2019 DCCLab. All rights reserved.
//

import Foundation
import simd

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
    
    mutating func normalize() -> float4 {
        self = simd.normalize(self)
        return self
    }
    
    mutating func add(_ theVector:float4, scaledBy theScale:Float) {
        // TODO: Check SCN for fatser version? test
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
    
    mutating func  rotateAround(_ u:float4, by theta:Float) {
        rotateAroundAxis(u, byAngle: theta)
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
