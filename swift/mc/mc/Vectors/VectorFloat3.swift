//
//  VectorFloat3.swift
//  mc
//
//  Created by Daniel Côté on 2019-06-23.
//  Copyright © 2019 DCCLab. All rights reserved.
//

import Foundation
import simd

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
    
    mutating func normalize() -> float3 {
        self = simd.normalize(self)
        return self
    }
    
    mutating func add(_ theVector:float3, scaledBy theScale:Float) {
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

    mutating func rotateAround(_ u:float3, by theta:Float) {
        rotateAroundAxis(u, byAngle: theta)
    }

    mutating func rotateAroundAxis(_ u:float3, byAngle theta:Float) {
        self = float3x3.rotationMatrixAround(axis: u, angle: theta) * self
    }
    
    static func • (left: float3, right: float3 ) -> Float {
        return left.dotProduct(right)
    }
    
    static func ⨉ (left: float3, right: float3 ) -> float3 {
        return left.crossProduct(right)
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
