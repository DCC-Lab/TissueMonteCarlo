//
//  HenyeyGreenstein.swift
//  Photon
//
//  Created by Daniel Côté on 2015-02-20.
//  Copyright (c) 2015 Daniel Côté. All rights reserved.
//

import Foundation

class BulkHenyeyGreenstein : BulkMaterial {
    var g:Scalar
    override var description: String {
        return super.description+" g=\(g)"
    }

    init(mu_s: Scalar, mu_a: Scalar, index: Scalar, g:Scalar) {
        self.g = g
        super.init(mu_s:mu_s, mu_a:mu_a, index:index )
    }

    override func randomScatteringAngles(photon:Photon? = nil) -> (Scalar, Scalar) {
        let g = self.g
        var θ:Scalar!
        let ϕ = 2.0 * Scalar.pi * randomfloat()
        for _ in 1...100 {
            if g != 0 {
                let rand_frac = (1.0 - g*g) / (1.0 - g + 2.0 * randomfloat() * g)
                θ = acos( (1.0 + g*g - rand_frac*rand_frac) / (2.0*g) )
            } else {
                θ = acos(1.0 - 2.0 * randomfloat() )
            }
            if θ >= 0 && θ <= Scalar.pi {
                break
            }
        }
        
        return (θ, ϕ)
    }
    
}
