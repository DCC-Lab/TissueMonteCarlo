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

class BulkMaterial<T, V, M:MatrixProtocol> where V.T == T, M.V == V, M.V.T == V.T {
    let infiniteDistance:T = T(10000)
    fileprivate var randomTable = [T](repeating: 0, count: TableSize)
    fileprivate var randomIndex:Int = 0

    var mu_s:T
    var mu_a:T
    var mu_t:T
    var index:T
    var albedo:T
    var description: String {
        return " µs=\(mu_s) µa=\(mu_a) index=\(index)"
    }
    
    init(mu_s:T, mu_a:T, index:T) {
        self.mu_s = mu_s
        self.mu_a = mu_a
        self.mu_t = mu_a + mu_s
        self.index = index
        self.albedo = 0
        if mu_t != 0 {
            self.albedo = mu_a/mu_t
        }
        for i in 0...65535 {
            randomTable[i] = T.random(in:0...1)
        }
        randomIndex = Int.random(in: 0...TableSize)
    }
    
    func absorbEnergy(_ photon:GenericPhoton<T,V,M>) {
        let delta = photon.weight * albedo
        photon.decreaseWeightBy(delta)
    }

    func randomfloat() -> T {
        randomIndex += 1
        if randomIndex == TableSize {
            randomIndex = Int.random(in: 0...TableSize)
        }
        return randomTable[randomIndex]
    }
    
    func randomScatteringDistance() -> T {
        if mu_t == 0 {
            return infiniteDistance
        }
        
        let n = randomfloat()
        let d = -T.my_log(n) / mu_t

        return d
    }

    func randomScatteringAngles() -> (T, T) {
        return (0,0)
    }
}
