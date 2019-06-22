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

typealias Vector = float4
typealias Matrix = float4x4

var v = Vector(1,1,1)
var u = Vector(1,2,3)
print(u•v)
var M1 = Matrix.rotate(radians: 0.1, axis: Vector.xHat)
var M2 = Matrix.rotate(radians: 0.1, axis: u)
var w = M2 * M1 * v
print(w)
//let p = Photon(position: Vector(0,0,0), direction: Vector(0,0,1), wavelength: 632)

//
//print(v.norm())
//print(v.abs())
//let w = v + u
//print(u)
//let r = float3x3.rotationMatrixAround(axis: u, angle: 0.5)
//print(r)
//print(r*u)

//typealias float = CGFloat
//typealias Vector = SCNVector3
//typealias float = Float
//typealias Vector = float4
//typealias Vector3D = Vector
//typealias v⃗ = Vector

//let N = 10000
//let start = Date()
//let material = BulkHenyeyGreenstein(mu_s: 30, mu_a: 0.5, index: 1.4, g: 0.8)
//let photon = Photon(position: Vector(0,0,0), direction: Vector(0,0,1), wavelength: 632)!
//for _ in 1...N {
//    photon.reset()
//    try photon.propagate(into: material, for: 0)
//}
//let duration = -start.timeIntervalSinceNow
//let rate = duration/TimeInterval(N)*1000000
//print(String(format: "Total %.1lf s, %.1lf µs per photon", duration, rate))


//var queue = OperationQueue()
//queue.maxConcurrentOperationCount = 10
//
//let N = 1000000
//let M = 10000
//let start = Date()
//for _ in 1...M {
//    //    queue.addOperation {
//    //        do {
//    let material = BulkHenyeyGreenstein(mu_s: 30, mu_a: 0.5, index: 1.4, g: 0.8)
//    let photon = Photon(position: v⃗(0,0,0), direction: v⃗(0,0,1), wavelength: 632)!
//    for _ in 1...N/M {
//        photon.reset()
//        try photon.propagate(into: material, for: 0)
//    }
//    //        } catch {
//    //
//    //        }
//    //    }
//}
//queue.waitUntilAllOperationsAreFinished()
//let duration = -start.timeIntervalSinceNow
//let rate = duration/TimeInterval(N)*1000000
//print(String(format: "Total %.1lf s, %.1lf µs per photon", duration, rate))
