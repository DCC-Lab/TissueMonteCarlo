//
//  main.swift
//  mc
//
//  Created by Daniel Côté on 2019-06-21.
//  Copyright © 2019 DCCLab. All rights reserved.
//
import Foundation


var material = BulkHenyeyGreenstein(mu_s: 30, mu_a: 0.5, index: 1.4, g: 0.8)
var p = Photon(position: Vector3D(x:0,y:0,z:0), direction: Vector3D(x:0,y:0,z:1), wavelength: 632)
let start = Date()
let N = 10000
for i in 1...N {
    p!.reset()
    try p!.propagate(into: material, for: 0)
    if i % 100 == 0 {
        print("\(i)")
    }
}
let duration = -start.timeIntervalSinceNow/TimeInterval(N)*1000000
print(String(format: "%.1lf µs per photon", duration))
