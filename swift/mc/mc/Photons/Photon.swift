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

enum MonteCarloError: LocalizedError {
    case UnexpectedNil
}

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

    init?(position:Vector, direction:Vector, wavelength:Scalar) {
        r⃗ = position
        û = direction
        weight = 1
        λ = wavelength
        û.normalize()

        r⃗ₒ = position
        ûₒ = û

        keepingExtendedStatistics = false
        distanceTraveled = 0
        statistics = [(r⃗ₒ,weight)]
        êr = Vector(0,0,0)
        if let vector = defaultEPerpendicular(direction: û) {
            êr = vector
        } else {
            return nil
        }
    }

    func defaultEPerpendicular(direction û:Vector) -> Vector? {
        if û == ẑ {
            return x̂
        } else if û == x̂ {
            return ŷ
        } else if û == ŷ {
            return ẑ
        } else if û == -ẑ {
            return -x̂
        } else if û == -x̂ {
            return -ŷ
        } else if û == -ŷ {
            return -ẑ
        }
        return nil
    }
    
    func reset() {
        r⃗ = r⃗ₒ
        û = ûₒ
        êr = x̂
        weight = 1
        keepingExtendedStatistics = false
        distanceTraveled = 0
        statistics = [(r⃗ₒ,weight)]
    }
    
    func propagate(into material:BulkMaterial, for distance:Scalar = 0) throws {
        while isAlive() {
            let (θ, φ) = material.randomScatteringAngles()
            let distance = material.randomScatteringDistance()
            if distance.isInfinite {
                weight = 0
            } else {
                scatterBy(θ, φ)
                moveBy(distance)
                material.absorbEnergy(self)
            }
            roulette()
        }
    }

    func scatterBy(_ θ:Scalar,_ φ:Scalar ) {
        êr.rotateAround(û, by: φ)
        û.rotateAround(êr, by: θ)
        
        êr.normalize()
        û.normalize()
    }
    
    func moveBy(_ distance:Scalar) {
        r⃗.add(û, scaledBy:distance)
        distanceTraveled += distance;
        statistics.append((r⃗, weight))
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
    
    func rotateReferenceFrameInFresnelPlaneWithNormal( theNormal:Vector ) {
        /* We always want the "s hat" vector in the same orientation
        compared to dir, regardless of the normal (i.e the normal
        could be pointing in or out) */
        var s = û.normalizedCrossProduct(theNormal)
        
        if û.normalizedDotProduct(theNormal) < 0  {
            s = s*(-1)
        }
        
        s.normalize()
        let phi = êr.orientedAngleWith(s, aroundAxis: û)
        êr.rotateAroundAxis(û, byAngle: phi)
        êr.normalize()
    
        assert(êr.isPerpendicularTo(û), "êr not perpendicular to û")
        assert(êr.isPerpendicularTo(theNormal), "êr not perpendicular to normal")
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
