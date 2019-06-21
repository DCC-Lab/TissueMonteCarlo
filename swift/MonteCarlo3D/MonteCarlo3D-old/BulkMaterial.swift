//
//  BulkMaterial.swift
//  Photon
//
//  Created by Daniel Côté on 2015-02-20.
//  Copyright (c) 2015 Daniel Côté. All rights reserved.
//

import Foundation
import SceneKit

let infiniteDistance:CGFloat = 1e4
var randomTable = [CGFloat](repeating: 0, count: 65536)
var randomIndex:Int = 0

extension CGFloat {
    func isInfinite() -> Bool {
        return self > infiniteDistance
    }
}

class BulkMaterial  {
    var mu_s:CGFloat
    var mu_a:CGFloat
    var mu_t:CGFloat
    var index:CGFloat
    var albedo:CGFloat
    var description: String {
        return " µs=\(mu_s) µa=\(mu_a) index=\(index)"
    }
    
    init(mu_s:CGFloat, mu_a:CGFloat, index:CGFloat) {
        self.mu_s = mu_s
        self.mu_a = mu_a
        self.mu_t = mu_a + mu_s
        self.index = index
        self.albedo = 0
        if mu_t != 0 {
            self.albedo = mu_a/mu_t
        }
        for i in 0...65535 {
            randomTable[i] = CGFloat(Float.random(in:0...1))
        }
        randomIndex = Int.random(in: 0...65535)
    }
    
    func absorbEnergy(_ photon:Photon) -> CGFloat {
        return photon.weight * material.albedo
    }
    
    class func randomFloat() -> CGFloat {
        randomIndex += 1
        if randomIndex == 65536 {
            randomIndex = Int.random(in: 0...65535)
        }
        return randomTable[randomIndex]
    }
    
    func randomScatteringDistance() -> CGFloat {
        if mu_t == 0 {
            return infiniteDistance
        }
        
        let n = BulkMaterial.randomFloat()
        let d = -log(n) / mu_t

        return d
    }

    func randomScatteringAngles() -> (CGFloat, CGFloat) {
        return (0,0)
    }
}
