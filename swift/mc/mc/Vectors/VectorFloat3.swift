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
    
    @discardableResult
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

extension Array where Element == float3 {
    // https://developer.apple.com/documentation/accelerate/simd/working_with_vectors
    
    init(vector:float3, count:Int) {
        self.init(repeating: vector, count: count)
    }
    func norm() -> [Float] {
        var results = [Float](repeating: 0, count: self.count)
        for (i,v) in self.enumerated() {
            results[i] = v.norm()
        }
        return results
    }
    
    func abs() -> [Float] {
        var results = [Float](repeating: 0, count: self.count)
        for (i,v) in self.enumerated() {
            results[i] = v.abs()
        }
        return results
    }
    
    @discardableResult
    mutating func normalize() -> [float3] {
        for (i,v) in self.enumerated() {
            self[i] /= v.abs()
        }
        return self
    }
    
//    mutating func addScaledVector(_ theVector:float4, scale theScale:Float) {
//        self += theVector * theScale
//    }
    
    func dotProduct(_ vectors : [float3] ) -> [Float] {
        var results = [Float](repeating: 0, count: self.count)
        for (i,v) in self.enumerated() {
            results[i] = v•vectors[i]
        }
        return results
    }
    
    func normalizedDotProduct(_ vectors : [float3] ) -> [Float] {
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
    
    func crossProduct(_ vectors: [float3]) -> [float3] {
        var results:[float3] = [float3](repeating: float3(0,0,0), count: self.count)

        for (i,u) in self.enumerated() {
            results[i] = u.crossProduct(vectors[i])
        }
        return results
    }
    
    func normalizedCrossProduct(_ vectors: [float3]) -> [float3] {
        var results:[float3] = [float3](repeating: float3(0,0,0), count: self.count)

        for (i,u) in self.enumerated() {
            let v = vectors[i]
            var prod = u.crossProduct(v)
            let norm_u = u.norm()
            let norm_v = v.norm()

            if norm_u != 0 && norm_v != 0 {
                prod /= sqrt(norm_u * norm_v)
            }
            
            let norm_t = prod.norm()
            if norm_t > 1 {
                prod /= sqrt(norm_t);
            }

            results[i] = prod
        }
        return results
    }

    func tripleProduct(v : [float3], w : [float3]) -> [Float] {
        var results = [Float](repeating: 0, count: self.count)
        for (i,u) in self.enumerated() {
            let cp = u.crossProduct(v[i])
            results[i] = cp.dotProduct(w[i])
        }
        return results
    }

    func orientedAngleWith(_ y:[float3] , aroundAxis r:[float3] ) -> [Float] {
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

    static func * (left: [float3], scalar: [Float]) -> [float3] {
        var results = [float3](repeating: float3(0,0,0), count: left.count)
        for (i,u) in left.enumerated() {
            results[i] = u * scalar[i]
        }
        return results
    }
    
    static func * (scalar: [Float], left: [float3]) -> [float3] {
        var results = [float3](repeating: float3(0,0,0), count: left.count)
        for (i,u) in left.enumerated() {
            results[i] = u * scalar[i]
        }
        return results
    }

    static func += ( left: inout [float3], right: [float3]) {
        for (i,u) in right.enumerated() {
            left[i] += u
        }
    }

    mutating func  rotateAroundAxis(_ u:[float3], byAngle theta:[Float]) {
        for (i,_) in self.enumerated() {
            self[i].rotateAround(u[i], by: theta[i])
        }
    }
}

extension Array where Element == Float {
    static func random(in range:ClosedRange<Float>, count:Int) -> [Float]{
        var results = [Float]()
        for _ in 0..<count {
            results.append(Float.random(in: range))
        }
        return results
    }
    
    func sum() -> Float {
        var sum:Float = 0
        for value in self {
            sum += value
        }
        return sum
    }

    static func + (left: [Float], right: [Float]) -> [Float] {
        var results = [Float](repeating: Float(0), count: left.count)
        for (i,u) in left.enumerated() {
            results[i] = u + right[i]
        }
        return results
    }

    static func - (left: [Float], right: [Float]) -> [Float] {
        var results = [Float](repeating: Float(0), count: left.count)
        for (i,u) in left.enumerated() {
            results[i] = u - right[i]
        }
        return results
    }

    static func * (left: [Float], right: [Float]) -> [Float] {
        var results = [Float](repeating: Float(0), count: left.count)
        for (i,u) in left.enumerated() {
            results[i] = u * right[i]
        }
        return results
    }

    static func * (left: [Float], scalar: Float) -> [Float] {
        var results = [Float](repeating: Float(0), count: left.count)
        for (i,u) in left.enumerated() {
            results[i] = u * scalar
        }
        return results
    }
    static func * (scalar: Float, left: [Float]) -> [Float] {
        var results = [Float](repeating: Float(0), count: left.count)
        for (i,u) in left.enumerated() {
            results[i] = u * scalar
        }
        return results
    }

    static func > (left: [Float], scalar: Float) -> [Float] {
        var results = [Float](repeating: 0, count: left.count)
        for (i,_) in left.enumerated() {
            if left[i] > scalar {
                results[i] = 1.0
            }
        }
        return results
    }

    static func < (left: [Float], scalar: Float) -> [Float] {
        var results = [Float](repeating: 0, count: left.count)
        for (i,_) in left.enumerated() {
            if left[i] < scalar {
                results[i] = 1.0
            }
        }
        return results
    }

}

