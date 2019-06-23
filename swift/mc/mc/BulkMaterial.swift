//
//  BulkMaterial.swift
//  Photon
//
//  Created by Daniel Côté on 2015-02-20.
//  Copyright (c) 2015 Daniel Côté. All rights reserved.
//

import Foundation
import SceneKit

let TableSize:Int = 65536

class BulkMaterial  {
    fileprivate var randomTable = [Scalar](repeating: 0, count: TableSize)
    fileprivate var randomIndex:Int = 0
    let infiniteDistance:Scalar = 1e4

    var mu_s:Scalar
    var mu_a:Scalar
    var mu_t:Scalar
    var index:Scalar
    var albedo:Scalar
    var description: String {
        return " µs=\(mu_s) µa=\(mu_a) index=\(index)"
    }
    
    init(mu_s:Scalar, mu_a:Scalar, index:Scalar) {
        self.mu_s = mu_s
        self.mu_a = mu_a
        self.mu_t = mu_a + mu_s
        self.index = index
        self.albedo = 0
        if mu_t != 0 {
            self.albedo = mu_a/mu_t
        }
        for i in 0...65535 {
            randomTable[i] = Scalar.random(in:0...1)
        }
        randomIndex = Int.random(in: 0...TableSize)
    }
    
    func absorbEnergy(_ photon:Photon) {
        let delta = photon.weight * albedo
        photon.decreaseWeightBy(delta)
    }
    
    func randomfloat() -> Scalar {
        randomIndex += 1
        if randomIndex == TableSize {
            randomIndex = Int.random(in: 0...TableSize-1)
        }
        return randomTable[randomIndex]
    }
    
    func randomScatteringDistance() -> Scalar {
        if mu_t == 0 {
            return infiniteDistance
        }
        
        let n = randomfloat()
        let d = -log(n) / mu_t

        return d
    }

    func randomScatteringAngles() -> (Scalar, Scalar) {
        return (0,0)
    }
}

//class BulkMaterialSIMD4  {
//    fileprivate var randomTable = [Float](repeating: 0, count: TableSize)
//    fileprivate var randomIndex:Int = 0
//    let infiniteDistance:Float = 1e4
//
//    var mu_s:Float
//    var mu_a:Float
//    var mu_t:Float
//    var index:Float
//    var albedo:Float
//    var description: String {
//        return " µs=\(mu_s) µa=\(mu_a) index=\(index)"
//    }
//
//    init(mu_s:Float, mu_a:Float, index:Float) {
//        self.mu_s = mu_s
//        self.mu_a = mu_a
//        self.mu_t = mu_a + mu_s
//        self.index = index
//        self.albedo = 0
//        if mu_t != 0 {
//            self.albedo = mu_a/mu_t
//        }
//    }
//
//    func absorbEnergy(_ photon:PhotonSIMD4) {
//        let delta = photon.weight * albedo
//        photon.decreaseWeightBy(delta)
//    }
//
//    func randomFloat() -> Float {
//        randomIndex += 1
//        if randomIndex == TableSize {
//            randomIndex = Int.random(in: 0...TableSize)
//        }
//        return randomTable[randomIndex]
//    }
//
//    func randomScatteringDistance() -> Float {
//        if mu_t == 0 {
//            return infiniteDistance
//        }
//
//        let n = randomFloat()
//        let d = -log(n) / mu_t
//
//        return d
//    }
//
//    func randomScatteringAngles() -> (Float, Float) {
//        return (0,0)
//    }
//}
