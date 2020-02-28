//
//  Photon.swift
//  Photon
//
//  Created by Daniel Côté on 2015-02-19.
//  Copyright (c) 2015 Daniel Côté. All rights reserved.
//

import Foundation
import SceneKit
import Metal
import MetalPerformanceShaders

typealias Photon = PhotonBase

class PhotonBase {
    var r⃗:Vector
    var û:Vector
    var êr:Vector
    var êl:Vector {
        get { return êr.crossProduct(û) }
    }
    var weight:Scalar
    let λ:Scalar

    let r⃗ₒ:Vector
    let ûₒ:Vector
    var êrₒ:Vector
    var keepingExtendedStatistics:Bool
    var statistics:[(Vector,Scalar)]
    var distanceTraveled:Scalar

    var description:String {
        return String(format: "r⃗: ( %0.2f,%0.2f,%0.2f ) û:(%0.2f,%0.2f,%0.2f ) W:%0.2f",r⃗.x,r⃗.y,r⃗.z,û.x,û.y,û.z,weight )
    }
    
    var x̂:Vector {
        get { return Vector(1,0,0) }
    }
    var ŷ:Vector {
        get { return Vector(0,1,0) }
    }
    var ẑ:Vector {
        get { return Vector(0,0,1) }
    }
    var ô:Vector {
        get { return Vector(0,0,0) }
    }

    init?(position r⃗ᵢ:Vector, direction ûᵢ:Vector, wavelength:Scalar) {
        r⃗ = r⃗ᵢ
        û = ûᵢ
        û.normalize() // make sure normmalized
        weight = 1
        λ = wavelength

        r⃗ₒ = r⃗ᵢ
        ûₒ = û

        keepingExtendedStatistics = false
        distanceTraveled = 0
        statistics = [(r⃗ₒ,weight)]
        êr = Vector(0,0,0)
        êrₒ = Vector(0,0,0)
        if let vector = defaultEPerpendicular(direction: û) {
            êr = vector
        } else {
            return nil
        }
        êrₒ = êr
    }

    func defaultEPerpendicular(direction û:Vector) -> Vector? {
        if û.isParallelTo(ẑ) {
            return x̂
        } else if û.isParallelTo(x̂) {
            return ŷ
        } else if û.isParallelTo(ŷ) {
            return ẑ
        }
        return nil
    }
    
    func reset() {
        r⃗ = r⃗ₒ
        û = ûₒ
        êr = êrₒ
        weight = 1
        keepingExtendedStatistics = false
        distanceTraveled = 0
        statistics = [(r⃗ₒ,weight)]
    }
    
    func propagate(into material:BulkMaterial, for distance:Scalar = 0) throws {
        while isAlive() {
            let (θ, φ) = material.randomScatteringAngles()
            let distance = material.randomScatteringDistance()
            let albedo = material.albedo()
            
            scatterBy(θ, φ)
            moveBy(distance)
            decreaseWeightBy(albedo * weight)
            roulette()
        }
    }

    func scatterBy(_ θ:Scalar,_ φ:Scalar ) {
        êr.rotateAround(û, by: φ)
        êr.normalize()
        
        û.rotateAround(êr, by: θ)
        û.normalize()
    }
    
    func moveBy(_ distance:Scalar) {
        if distance.isInfinite {
            weight = 0
        } else {
            r⃗.add(û, scaledBy:distance)
            distanceTraveled += distance;
            statistics.append((r⃗, weight))
        }
    }
    
    func decreaseWeightBy(_ delta:Scalar) {
        weight -= delta
        if weight < 0 {
            weight = 0
        }
    }

    func multiplyWeightBy(scale:Scalar) {
        weight *= scale
        if weight < 0 {
            weight = 0
        }
    }

    func isAlive() -> Bool {
        return weight > 0
    }
    
    func rotateReferenceFrameInFresnelPlaneWithNormal(normal n̂:Vector ) {
        /* We always want the "s hat" vector in the same orientation
        compared to dir, regardless of the normal (i.e the normal
        could be pointing in or out) */
        var ŝ:Vector = û ⨉ n̂
        
        if û • n̂ < 0  {
            ŝ = -ŝ
        }
        
        ŝ.normalize()
        let ɸ = êr.orientedAngleWith(ŝ, aroundAxis: û)
        êr.rotateAround(û, by: ɸ)
        êr.normalize()
    
        assert(êr.isPerpendicularTo(û), "êr not perpendicular to û")
        assert(êr.isPerpendicularTo(n̂), "êr not perpendicular to normal")
    }
    
    func roulette() {
        let CHANCE:Scalar = 0.1
        let threshold:Scalar = 1e-4
        
        if weight <= threshold {
           let randomScalar = Scalar.random(in:0...1)
            if( randomScalar < CHANCE) {
                /* survived the roulette.*/
                multiplyWeightBy( scale: 1.0 / CHANCE );
            } else {
                weight = 0
            }
        }
    }
}
