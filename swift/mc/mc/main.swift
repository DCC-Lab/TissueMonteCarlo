//
//  main.swift
//  mc
//
//  Created by Daniel Côté on 2019-06-21.
//  Copyright © 2019 DCCLab. All rights reserved.
//
import Foundation

var queue = OperationQueue()
queue.maxConcurrentOperationCount = 10

let N = 1000000
let M = 10
let start = Date()
for _ in 1...M {
    queue.addOperation {
        do {
            let material = BulkHenyeyGreenstein(mu_s: 30, mu_a: 0.5, index: 1.4, g: 0.8)
            let photon = Photon(position: v⃗(0,0,0), direction: v⃗(0,0,1), wavelength: 632)!
            for _ in 1...N/M {
                photon.reset()
                try photon.propagate(into: material, for: 0)
            }
        } catch {
        
        }
    }
}
queue.waitUntilAllOperationsAreFinished()
let duration = -start.timeIntervalSinceNow
let rate = duration/TimeInterval(N)*1000000
print(String(format: "Total %.1lf s, %.1lf µs per photon", duration, rate))
