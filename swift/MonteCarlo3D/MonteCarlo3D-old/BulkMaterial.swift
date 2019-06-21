//
//  BulkMaterial.swift
//  Photon
//
//  Created by Daniel Côté on 2015-02-20.
//  Copyright (c) 2015 Daniel Côté. All rights reserved.
//

import Foundation
import SceneKit

class BulkMaterial  {
    var mu_s:CGFloat
    var mu_a:CGFloat
    var mu_t:CGFloat
    var index:CGFloat
    let infiniteDistance:CGFloat = 1e4

    var description: String {
        return " µs=\(mu_s) µa=\(mu_a) index=\(index)"
    }
    
    init(mu_s:CGFloat, mu_a:CGFloat, index:CGFloat) {
        self.mu_s = mu_s
        self.mu_a = mu_a
        self.mu_t = mu_a + mu_s
        self.index = index
    }
    
    func absorbEnergy(_ photon:Photon) -> CGFloat {
        return photon.weight * material.albedo()
    }
    
    func albedo() -> CGFloat {
        if mu_t != 0 {
            return mu_a/mu_t
        } else {
            return 0
        }
    }

    class func randomFloat() -> CGFloat {
        return CGFloat(Float.random(in:0...1))
    }
    
    func randomScatteringDistance() -> CGFloat {
        if mu_t == 0 {
            return self.infiniteDistance
        }
        
        var l = 100
        var d:CGFloat = 0
        var n:CGFloat = 0
        repeat {
            repeat {
                n = BulkMaterial.randomFloat()
            } while ( n == 0.0)
            d = -log(n) / mu_t
            l -= 1
        } while ( l != 0 && d == 0 )
        
        return d
    }

    func randomScatteringAngles() -> (CGFloat, CGFloat) {
        return (0,0)
    }
}


