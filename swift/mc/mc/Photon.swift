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

enum MonteCarloError: LocalizedError {
    case UnexpectedNil
}

class Photon<T, V, M:MatrixProtocol> where T == V.T, V == M.V  {
    var position:V
    var direction:V
    var ePerp:V
    var weight:T
    let wavelength:T
    
    let originalPosition:V
    let originalDirection:V
    var keepingExtendedStatistics:Bool
    var statistics:[(V,T)]
    var distanceTraveled:T

    init?(position:V, direction:V, wavelength:T) {
        self.position = position
        self.direction = direction
        self.weight = T(1.0)
        self.wavelength = wavelength

        self.originalPosition = position
        self.originalDirection = direction

        self.keepingExtendedStatistics = false
        self.distanceTraveled = 0
        self.statistics = []
        self.ePerp = V.xHat
//        if self.direction == zHat {
//            self.ePerp = xHat
//        } else if (self.direction == xHat) {
//            self.ePerp = yHat
//        } else if (self.direction == yHat) {
//            self.ePerp = zHat
//        } else if self.direction == -zHat {
//            self.ePerp = -xHat
//        } else if (self.direction == -xHat) {
//            self.ePerp = -yHat
//        } else if (self.direction == -yHat) {
//            self.ePerp = -zHat
//        }

        if direction.norm() == T(0.0) {
            return nil
        }

    }
    
    func reset() {
        self.position = self.originalPosition
        self.direction = self.originalDirection
        self.ePerp = V.xHat as! V
        self.weight = 1
        self.keepingExtendedStatistics = false
        self.distanceTraveled = 0
        self.statistics = [(self.originalPosition,self.weight)]
    }
    
    func propagate(into material:BulkMaterial<T,V,M>, for distance:T) throws {
        while isAlive() {
            let (θ, φ) = material.randomScatteringAngles()
            let distance = material.randomScatteringDistance()
            if distance.isInfinite {
                weight = 0
            } else {
                scatterBy(θ, φ)
                moveBy(distance)
//                material.absorbEnergy(self)
            }
            roulette()
        }
    }

    func moveBy(_ distance:T) {
        self.position.addScaledVector(self.direction, scale:distance)
        self.distanceTraveled += distance;
        //self.statistics.append((self.position, self.weight))
    }
    
    func decreaseWeightBy(_ delta:T) {
        self.weight -= delta
        if self.weight < 0 {
            self.weight = 0
        }
    }

    func multiplyWeightBy(scale:T) {
        self.weight *= scale
        if self.weight < 0 {
            self.weight = 0
        }
    }

    func isAlive() -> Bool {
        return weight > 0
    }
    
    func scatterBy(_ θ:T,_ φ:T ) {
        self.ePerp.rotateAroundAxis(self.direction, byAngle: φ)
        self.direction.rotateAroundAxis(self.ePerp, byAngle: θ)

        try! _ = self.ePerp.normalize()
        try! _ = self.direction.normalize()
    }

    
//    func rotateReferenceFrameInFresnelPlaneWithNormal( theNormal:V ) {
//        /* We always want the "s hat" vector in the same orientation
//        compared to dir, regardless of the normal (i.e the normal
//        could be pointing in or out) */
//        var s = direction.normalizedCrossProduct(theNormal)
//
//        if direction.normalizedDotProduct(theNormal) < 0  {
//            s = s*(-1)
//        }
//
//        do {
//            try _ = s.normalize()
//            let phi = ePerp.orientedAngleWith(s, aroundAxis: direction)
//            ePerp.rotateAroundAxis(direction, byAngle: phi)
//            try _ = ePerp.normalize()
//        } catch {
//
//        }
//    }
    
    func roulette() {
        let CHANCE:T = 0.1
        let WeightThreshold:T = 1e-4
        
        if self.weight <= WeightThreshold {
           let randomfloat = T(Double.random(in:0...1))
            
            if( randomfloat < CHANCE) {
                /* survived the roulette.*/
                self.multiplyWeightBy( scale: 1.0 / CHANCE );
            } else {
                self.weight = 0
            }
        }
    }
}

//class PhotonSIMD4 {
//    var position:float4
//    var direction:float4
//    var ePerp:float4
//    var weight:Float
//    let wavelength:Float
//
//    let originalPosition:float4
//    let originalDirection:float4
//    var keepingExtendedStatistics:Bool
//    var statistics:[(float4,Float)]
//    var distanceTraveled:Float
//
//    let xHat = float4(1,0,0,1)
//    let yHat = float4(0,1,0,1)
//    let zHat = float4(0,0,1,1)
//    let oHat = float4(0,0,0,0)
//
//    var description:String {
//        return String(format: "P: ( %0.2f,%0.2f,%0.2f ) D:(%0.2f,%0.2f,%0.2f ) W:%0.2f",self.position.x,self.position.y,self.position.z,self.direction.x,self.direction.y,self.direction.z,self.weight )
//    }
//
//
//    init?(position:float4, direction:float4, wavelength:Float) {
//        self.position = position
//        self.direction = direction
//        self.weight = 1
//        self.wavelength = wavelength
//
//        self.originalPosition = position
//        self.originalDirection = direction
//
//        self.keepingExtendedStatistics = false
//        self.distanceTraveled = 0
//        self.statistics = []
//        self.ePerp = oHat
//        if self.direction == zHat {
//            self.ePerp = xHat
//        } else if (self.direction == xHat) {
//            self.ePerp = yHat
//        } else if (self.direction == yHat) {
//            self.ePerp = zHat
//        } else if self.direction == -zHat {
//            self.ePerp = -xHat
//        } else if (self.direction == -xHat) {
//            self.ePerp = -yHat
//        } else if (self.direction == -yHat) {
//            self.ePerp = -zHat
//        }
//
//        if direction.norm() == 0 {
//            return nil
//        }
//
//    }
//
//    func reset() {
//        self.position = self.originalPosition
//        self.direction = self.originalDirection
//        self.ePerp = xHat
//        self.weight = 1
//        self.keepingExtendedStatistics = false
//        self.distanceTraveled = 0
//        self.statistics = [(self.originalPosition,self.weight)]
//    }
//
//    func propagate(into material:BulkMaterial, for distance:T) throws {
//        while isAlive() {
//            let (θ, φ) = material.randomScatteringAngles()
//            let distance = Float(material.randomScatteringDistance())
//            let d⃗  = direction * distance
//            let T  = float4x4.translate(d⃗)
//            let mφ = float4x4.rotate(radians: Float(φ), axis: direction)
//            let mθ = float4x4.rotate(radians: Float(θ), axis: ePerp)
//            position = mθ * mφ * T * position
//            //            material.absorbEnergy(self)
////            roulette()
//        }
//    }
//
//    func moveBy(_ distance:Float) {
//        self.position.addScaledVector(self.direction, scale:distance)
//        self.distanceTraveled += distance;
//        //self.statistics.append((self.position, self.weight))
//    }
//
//    func decreaseWeightBy(_ delta:Float) {
//        self.weight -= delta
//        if self.weight < 0 {
//            self.weight = 0
//        }
//    }
//
//    func multiplyWeightBy(scale:Float) {
//        self.weight *= scale
//        if self.weight < 0 {
//            self.weight = 0
//        }
//    }
//
//    func isAlive() -> Bool {
//        return weight > 0
//    }
//
//    func scatterBy(_ θ:T,_ φ:T ) {
//        self.ePerp.rotateAroundAxis(self.direction, byAngle: φ)
//        self.direction.rotateAroundAxis(self.ePerp, byAngle: θ)
//
//        try! _ = self.ePerp.normalize()
//        try! _ = self.direction.normalize()
//    }
//
//
//    func rotateReferenceFrameInFresnelPlaneWithNormal( theNormal:V ) {
//        /* We always want the "s hat" vector in the same orientation
//         compared to dir, regardless of the normal (i.e the normal
//         could be pointing in or out) */
//        var s = direction.normalizedCrossProduct(theNormal)
//
//        if direction.normalizedDotProduct(theNormal) < 0  {
//            s = s*(-1)
//        }
//
//        do {
//            try _ = s.normalize()
//            let phi = ePerp.orientedAngleWith(s, aroundAxis: direction)
//            ePerp.rotateAroundAxis(direction, byAngle: phi)
//            try _ = ePerp.normalize()
//        } catch {
//
//        }
//
//        assert(ePerp.isPerpendicularTo(direction), "ePerp not perpendicular to direction")
//        assert(ePerp.isPerpendicularTo(theNormal), "ePerp not perpendicular to normal")
//    }
//
//    func roulette() {
//        let CHANCE:T = 0.1
//        let WeightThreshold:T = 1e-4
//
//        if self.weight <= WeightThreshold {
//            let randomfloat = T.random(in:0...1)
//
//            if( randomfloat < CHANCE) {
//                /* survived the roulette.*/
//                self.multiplyWeightBy( scale: 1.0 / CHANCE );
//            } else {
//                self.weight = 0
//            }
//        }
//    }
//}
