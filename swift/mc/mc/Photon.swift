//
//  Photon.swift
//  Photon
//
//  Created by Daniel Côté on 2015-02-19.
//  Copyright (c) 2015 Daniel Côté. All rights reserved.
//

import Foundation
import SceneKit

enum MonteCarloError: LocalizedError {
    case UnexpectedNil
}

class Photon {
    var position:Vector
    var direction:Vector
    var ePerp:Vector
    var weight:float
    let wavelength:float

    let originalPosition:Vector
    let originalDirection:Vector
    var keepingExtendedStatistics:Bool
    var statistics:[(Vector,float)]
    var distanceTraveled:float

    var description:String {
        return String(format: "P: ( %0.2f,%0.2f,%0.2f ) D:(%0.2f,%0.2f,%0.2f ) W:%0.2f",self.position.x,self.position.y,self.position.z,self.direction.x,self.direction.y,self.direction.z,self.weight )
    }
    

    init?(position:Vector, direction:Vector, wavelength:float) {
        self.position = position
        self.direction = direction
        self.weight = 1
        self.wavelength = wavelength

        self.originalPosition = position
        self.originalDirection = direction

        self.keepingExtendedStatistics = false
        self.distanceTraveled = 0
        self.statistics = []
        self.ePerp = oHat
        if self.direction == zHat {
            self.ePerp = xHat
        } else if (self.direction == xHat) {
            self.ePerp = yHat
        } else if (self.direction == yHat) {
            self.ePerp = zHat
        } else if self.direction == -zHat {
            self.ePerp = -xHat
        } else if (self.direction == -xHat) {
            self.ePerp = -yHat
        } else if (self.direction == -yHat) {
            self.ePerp = -zHat
        }

        if direction.norm() == 0 {
            return nil
        }

    }
    
    func reset() {
        self.position = self.originalPosition
        self.direction = self.originalDirection
        self.ePerp = xHat
        self.weight = 1
        self.keepingExtendedStatistics = false
        self.distanceTraveled = 0
        self.statistics = [(self.originalPosition,self.weight)]
    }
    
    func propagate(into material:BulkMaterial, for distance:float) throws {
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

    func moveBy(_ distance:float) {
        self.position.addScaledVector(self.direction, scale:distance)
        self.distanceTraveled += distance;
        //self.statistics.append((self.position, self.weight))
    }
    
    func decreaseWeightBy(_ delta:float) {
        self.weight -= delta
        if self.weight < 0 {
            self.weight = 0
        }
    }

    func multiplyWeightBy(scale:float) {
        self.weight *= scale
        if self.weight < 0 {
            self.weight = 0
        }
    }

    func isAlive() -> Bool {
        return weight > 0
    }
    
    func scatterBy(_ θ:float,_ φ:float ) {
        self.ePerp.rotateAroundAxis(self.direction, byAngle: φ)
        self.direction.rotateAroundAxis(self.ePerp, byAngle: θ)

        try! _ = self.ePerp.normalize()
        try! _ = self.direction.normalize()
    }

    
    func rotateReferenceFrameInFresnelPlaneWithNormal( theNormal:Vector ) {
        /* We always want the "s hat" vector in the same orientation
        compared to dir, regardless of the normal (i.e the normal
        could be pointing in or out) */
        var s = direction.normalizedCrossProduct(theNormal)
        
        if direction.normalizedDotProduct(theNormal) < 0  {
            s = s*(-1)
        }
        
        do {
            try _ = s.normalize()
            let phi = ePerp.orientedAngleWith(s, aroundAxis: direction)
            ePerp.rotateAroundAxis(direction, byAngle: phi)
            try _ = ePerp.normalize()
        } catch {
            
        }
    
        assert(ePerp.isPerpendicularTo(direction), "ePerp not perpendicular to direction")
        assert(ePerp.isPerpendicularTo(theNormal), "ePerp not perpendicular to normal")
    }
    
    func roulette() {
        let CHANCE:float = 0.1
        let WeightThreshold:float = 1e-4
        
        if self.weight <= WeightThreshold {
           let randomfloat = float.random(in:0...1)
            
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
//    func propagate(into material:BulkMaterial, for distance:float) throws {
//        while isAlive() {
//            let (θ, φ) = material.randomScatteringAngles()
//            let distance = Float(material.randomScatteringDistance())
//            if distance.isInfinite {
//                weight = 0
//            } else {
//                scatterBy(θ, φ)
//                moveBy(distance)
//                material.absorbEnergy(self)
//            }
//            roulette()
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
//    func scatterBy(_ θ:float,_ φ:float ) {
//        self.ePerp.rotateAroundAxis(self.direction, byAngle: φ)
//        self.direction.rotateAroundAxis(self.ePerp, byAngle: θ)
//        
//        try! _ = self.ePerp.normalize()
//        try! _ = self.direction.normalize()
//    }
//    
//    
//    func rotateReferenceFrameInFresnelPlaneWithNormal( theNormal:Vector ) {
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
//        let CHANCE:float = 0.1
//        let WeightThreshold:float = 1e-4
//        
//        if self.weight <= WeightThreshold {
//            let randomfloat = float.random(in:0...1)
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
