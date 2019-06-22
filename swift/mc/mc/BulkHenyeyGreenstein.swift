//
//  HenyeyGreenstein.swift
//  Photon
//
//  Created by Daniel Côté on 2015-02-20.
//  Copyright (c) 2015 Daniel Côté. All rights reserved.
//

import Foundation

class BulkHenyeyGreenstein<T, V, M:MatrixProtocol> : BulkMaterial<T, V, M> where V.T == T, M.V == V, M.V.T == V.T {
    var g:T
    override var description: String {
        return super.description+" g=\(g)"
    }

    init(mu_s: T, mu_a: T, index: T, g:T) {
        self.g = g
        super.init(mu_s:mu_s, mu_a:mu_a, index:index )
    }

    override func randomScatteringAngles() -> (T, T) {
        let g = self.g
        var θ:T!
        let ϕ:T = 2.0 * T.pi * randomfloat()
        for _ in 1...100 {
            if g != 0 {
                let num = Float(1.0 - g*g)
                let den = Float(1.0 - g + 2.0 * randomfloat() * g)
                let rand_frac =  num / den
                θ = T(acos( Float((1.0 + g*g - rand_frac*rand_frac) / (2.0*g) )))
            } else {
                θ = acos(Float(1.0 - 2.0 * randomfloat() ))
            }
            if θ >= 0 && θ <= T.pi {
                break
            }
        }
        
        return (θ, ϕ)
    }
    
}
