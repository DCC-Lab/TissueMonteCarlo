//
//  main.swift
//  mc
//
//  Created by Daniel Côté on 2019-06-21.
//  Copyright © 2019 DCCLab. All rights reserved.
//
import Foundation
import simd
import SceneKit

public typealias float3 = SIMD3<Float>
public typealias float4 = SIMD4<Float>

public typealias Scalar = CGFloat
public typealias Vector = SCNVector3

//public typealias Scalar = Float
//public typealias Vector = float3
//public typealias Scalar = Float
//public typealias Vector = float4
public typealias v⃗ = Vector

public typealias Scalars = [Scalar]
public typealias Vectors = [Vector]


let N = 100000
var start = Date()
var material = BulkHenyeyGreenstein(mu_s: 30, mu_a: 0.5, index: 1.4, g: 0.8)
let photon = Photon(position: v⃗(0,0,0), direction: v⃗(0,0,1), wavelength: 632)!
for i in 1...N {
    photon.reset()
    try photon.propagate(into: material)
    if i % 1000 == 0 {
        print("\(i) photons done")
    }
}
var duration = -start.timeIntervalSinceNow
var rate = duration/TimeInterval(N)*1000000
print(String(format: "Total %.1lf s, %.1lf µs per photon", duration, rate))


var queue = OperationQueue()
queue.maxConcurrentOperationCount = 10

let M = 6 // number of cores
queue.maxConcurrentOperationCount = M
let P = N/M
start = Date()
for _ in 1...N/P {
    queue.addOperation {
        do {
            let material = BulkHenyeyGreenstein(mu_s: 30, mu_a: 0.5, index: 1.4, g: 0.8)
            let photon = Photon(position: v⃗(0,0,0), direction: v⃗(0,0,1), wavelength: 632)!
            for _ in 1...P {
                photon.reset()
                try photon.propagate(into: material)
            }
        } catch {

        }
    }
}
queue.waitUntilAllOperationsAreFinished()
duration = -start.timeIntervalSinceNow
rate = duration/TimeInterval(N)*1000000
print(String(format: "Total %.1lf s, %.1lf µs per photon", duration, rate))

start = Date()
material = BulkHenyeyGreenstein(mu_s: 30, mu_a: 0.5, index: 1.4, g: 0.8)
let photons = Photons(position: v⃗(0,0,0), direction: v⃗(0,0,1), wavelength: 632, N:N)!
try photons.propagate(into: material)

duration = -start.timeIntervalSinceNow
rate = duration/TimeInterval(N)*1000000
print(String(format: "Total %.1lf s, %.1lf µs per photon", duration, rate))
