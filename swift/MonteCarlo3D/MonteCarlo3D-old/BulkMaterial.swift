//
//  BulkMaterial.swift
//  Photon
//
//  Created by Daniel Côté on 2015-02-20.
//  Copyright (c) 2015 Daniel Côté. All rights reserved.
//

import Foundation
import SceneKit

let infiniteDistance:float = 1e4
let TableSize:Int = 65536
extension float {
    func isInfinite() -> Bool {
        return self > infiniteDistance
    }
}

class BulkMaterial  {
    fileprivate var randomTable = [float](repeating: 0, count: TableSize)
    fileprivate var randomIndex:Int = 0

    var mu_s:float
    var mu_a:float
    var mu_t:float
    var index:float
    var albedo:float
    var description: String {
        return " µs=\(mu_s) µa=\(mu_a) index=\(index)"
    }
    
    init(mu_s:float, mu_a:float, index:float) {
        self.mu_s = mu_s
        self.mu_a = mu_a
        self.mu_t = mu_a + mu_s
        self.index = index
        self.albedo = 0
        if mu_t != 0 {
            self.albedo = mu_a/mu_t
        }
        for i in 0...65535 {
            randomTable[i] = float.random(in:0...1)
        }
        randomIndex = Int.random(in: 0...TableSize)
    }
    
    func absorbEnergy(_ photon:Photon) {
        let delta = photon.weight * albedo
        photon.decreaseWeightBy(delta)
    }
    
    func randomfloat() -> float {
        randomIndex += 1
        if randomIndex == TableSize {
            randomIndex = Int.random(in: 0...TableSize)
        }
        return randomTable[randomIndex]
    }
    
    func randomScatteringDistance() -> float {
        if mu_t == 0 {
            return infiniteDistance
        }
        
        let n = randomfloat()
        let d = -log(n) / mu_t

        return d
    }

    func randomScatteringAngles() -> (float, float) {
        return (0,0)
    }
}
