//
//  main.swift
//  mc
//
//  Created by Daniel Côté on 2019-06-21.
//  Copyright © 2019 DCCLab. All rights reserved.
//
import Foundation


var material = BulkHenyeyGreenstein(mu_s: 30, mu_a: 0.5, index: 1.4, g: 0.8)
var p = Photon(position: Vector3D(0,0,0), direction: Vector3D(0,0,1), wavelength: 632)
let start = Date()
let N = 1000
for i in 1...N {
    p!.reset()
    try p!.propagateInto(material: material, distance: 0)
    if i % 100 == 0 {
        print("\(i)")
    }
}
let duration = -start.timeIntervalSinceNow/TimeInterval(N)*1000
print(String(format: "%.1lf ms per photon", duration))
