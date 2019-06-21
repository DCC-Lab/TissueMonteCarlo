//
//  BulkMaterial.swift
//  Photon
//
//  Created by Daniel Côté on 2015-02-20.
//  Copyright (c) 2015 Daniel Côté. All rights reserved.
//

import Foundation
import SceneKit

class BulkMaterial : SCNNode {
    var mu_s:CGFloat
    var mu_a:CGFloat
    var index:CGFloat
    let infiniteDistance:CGFloat = 1e4

    override var description: String {
        return super.description+" µs=\(mu_s) µa=\(mu_a) index=\(index)"
    }

    required init?(coder aDecoder: NSCoder) {
        self.mu_s = 0
        self.mu_a = 0
        self.index = 1
        super.init(coder: aDecoder)
    }
    
    init(mu_s:CGFloat, mu_a:CGFloat, index:CGFloat) {
        self.mu_s = mu_s
        self.mu_a = mu_a
        self.index = index
        super.init()
    }
    
    func albedo() -> CGFloat {
        let mu_t = self.mu_s + self.mu_a;
        
        if mu_t != 0 {
            return mu_a/mu_t
        } else {
            return 0
        }
    }

    class func randomFloat() -> CGFloat {
        return CGFloat(arc4random())/CGFloat(RAND_MAX)
    }
    
    func randomScatteringDistance() -> CGFloat {
        let mu_t = self.mu_s + self.mu_a;
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


