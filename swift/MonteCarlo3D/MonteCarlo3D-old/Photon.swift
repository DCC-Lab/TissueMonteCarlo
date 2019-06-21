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

let xHat = Vector(x: 1, y: 0, z: 0)
let yHat = Vector(x: 0, y: 1, z: 0)
let zHat = Vector(x: 0, y: 0, z: 1)
let oHat = Vector(x: 0, y: 0, z: 0)

class Photon {
    var position:Vector
    var direction:Vector
    var ePerp:Vector
    var weight:Float

    let originalPosition:Vector
    let originalDirection:Vector
    let wavelength:Float
    var keepingExtendedStatistics:Bool
    var statistics:[(Vector,Float)]
    var distanceTraveled:Float

    var description:String {
        return String(format: "P: ( %0.2f,%0.2f,%0.2f ) D:(%0.2f,%0.2f,%0.2f ) W:%0.2f",self.position.x,self.position.y,self.position.z,self.direction.x,self.direction.y,self.direction.z,self.weight )
    }
    

    init?(position:Vector, direction:Vector, wavelength:Float) {
        self.wavelength = wavelength

        self.position = position
        self.direction = direction

        self.originalPosition = position
        self.originalDirection = direction

        self.weight = 1
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
    
    func propagate(into material:BulkMaterial, for distance:Float) throws {
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

    func moveBy(_ distance:Float) {
        // This is very slow because of temporary allocation: 
//        self.position += self.direction * distance
        // This is much faster because done in place:
        self.position.addScaledVector(self.direction, scale:distance)
        self.distanceTraveled += distance;
        self.statistics.append((self.position, self.weight))
    }
    
    func decreaseWeightBy(_ delta:Float) {
        self.weight -= delta

        if self.weight < 0 {
            self.weight = 0
        }
    }

    func multiplyWeightBy(scale:Float) {
        self.weight *= scale
        
        if self.weight < 0 {
            self.weight = 0
        }
    }

    func isAlive() -> Bool {
        return weight > 0
    }
    
    func scatterBy(_ θ:Float,_ φ:Float ) {
        self.ePerp.rotateAroundAxis(self.direction, byAngle: φ)
        try! self.ePerp.normalize()
        self.direction.rotateAroundAxis(self.ePerp, byAngle: θ)
        try! self.direction.normalize()
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
            try s.normalize()
            let phi = ePerp.orientedAngleWith(s, aroundAxis: direction)
            ePerp.rotateAroundAxis(direction, byAngle: phi)
            try ePerp.normalize()
        } catch {
            
        }
    
        assert(ePerp.isPerpendicularTo(direction), "ePerp not perpendicular to direction")
        assert(ePerp.isPerpendicularTo(theNormal), "ePerp not perpendicular to normal")
    }
    
    func roulette() {
        let CHANCE:Float = 0.1
        let WeightThreshold:Float = 1e-4
        
        if self.weight <= WeightThreshold {
           let randomFloat = BulkMaterial.randomFloat()
            
            if( randomFloat < CHANCE) {
                /* survived the roulette.*/
                self.multiplyWeightBy( scale: 1.0 / CHANCE );
            } else {
                self.weight = 0
            }
        }
    }
}
