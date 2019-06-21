//
//  BulkMaterial.swift
//  Photon
//
//  Created by Daniel Côté on 2015-02-20.
//  Copyright (c) 2015 Daniel Côté. All rights reserved.
//

import Foundation
import SceneKit

let q = DispatchQueue(label: "com.randomGeneration.queue")

class BulkMaterial  {
    var mu_s:CGFloat
    var mu_a:CGFloat
    var mu_t:CGFloat
    var index:CGFloat
    let infiniteDistance:CGFloat = 1e4

    fileprivate var cache = [CGFloat]()
    let semaphore:DispatchSemaphore
    
    var description: String {
        return " µs=\(mu_s) µa=\(mu_a) index=\(index)"
    }
    
    init(mu_s:CGFloat, mu_a:CGFloat, index:CGFloat) {
        self.mu_s = mu_s
        self.mu_a = mu_a
        self.mu_t = mu_a + mu_s
        self.index = index
        for _ in 1...200000 {
            self.cache.append(CGFloat(Float.random(in:0...1)))
        }
        semaphore = DispatchSemaphore(value: 1)
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
    
    func retrieveRandomNumber() -> CGFloat {
//        if cache.count == 0 {
//            q.async {
//                for _ in 1...100 {
//                    self.semaphore.wait()
//                    self.cache.append(CGFloat(Float.random(in:0...1)))
//                    self.semaphore.signal()
//                }
//            }
//        }
//        print(cache.count)
//        semaphore.wait()
//        defer {
//            semaphore.signal()
//        }
//        print(cache.count)
        return cache.popLast()!
    }
    
    func randomScatteringDistance() -> CGFloat {
        if mu_t == 0 {
            return self.infiniteDistance
        }
        
        var l = 100
        var d:CGFloat = 0
        var n:CGFloat = 0
//        print("Entering")
//        repeat {
//            repeat {
//                print("Loop")
//                n = retrieveRandomNumber()
//            } while ( n == 0.0)
//            d = -log(n) / mu_t
//            l -= 1
//        } while ( l != 0 && d == 0 )
        n = retrieveRandomNumber()
        d = -log(n) / mu_t
        l -= 1

        return d
    }

    func randomScatteringAngles() -> (CGFloat, CGFloat) {
        return (0,0)
    }
}


class RandomGeneration : Operation {
    var cache = [CGFloat]()
    let lock = NSConditionLock(condition: 0)
    let semaphore = DispatchSemaphore(value: 1)
    
    override init() {
        while cache.count < 20000 {
            let value = CGFloat(Float.random(in:0...1))
            cache.append(value)
        }
    }
    override func main() {
        while !self.isCancelled {
            semaphore.wait()
            while cache.count < 100 {
                cache.append(CGFloat(Float.random(in:0...1)))
            }
            semaphore.signal()
        }
    }
    
    func retrieveRandomNumber() -> CGFloat {
        while lock.condition == 0 {
            usleep(1)
        }
        semaphore.wait()
        defer {
            semaphore.signal()
        }
        return cache.popLast()!
    }
    
}
