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

let xHat = SCNVector3(x: 1, y: 0, z: 0)
let yHat = SCNVector3(x: 0, y: 1, z: 0)
let zHat = SCNVector3(x: 0, y: 0, z: 1)
let oHat = SCNVector3(x: 0, y: 0, z: 0)


class Photon {
    var position:Vector3D
    var direction:Vector3D
    var ePerp:Vector3D
    var weight:CGFloat

    let originalPosition:Vector3D
    let originalDirection:Vector3D
    let wavelength:CGFloat
    var keepingExtendedStatistics:Bool
    var statistics:[(Vector3D,CGFloat)]
    var distanceTraveled:CGFloat

    var description:String {
        return String(format: "P: ( %0.2f,%0.2f,%0.2f ) D:(%0.2f,%0.2f,%0.2f ) W:%0.2f",self.position.x,self.position.y,self.position.z,self.direction.x,self.direction.y,self.direction.z,self.weight )
    }
    

    init?(position:Vector3D, direction:Vector3D, wavelength:CGFloat) {
        self.originalPosition = position
        self.originalDirection = direction
        self.wavelength = wavelength

        self.position = position
        self.direction = direction

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
    
    func propagateInto(material:BulkMaterial, distance theDistance:CGFloat) throws {
        while isAlive() {
            let (θ, φ) = material.randomScatteringAngles()
            let distance = material.randomScatteringDistance()
            
            if distance == material.infiniteDistance {
                weight = 0
            } else {
                moveBy(distance)
                changeDirectionBy(θ, φ)
                let energyLoss = weight * material.albedo();
                decreaseWeightBy(energyLoss)
            }
            
            roulette()
        }
    }

    func moveBy(_ distance:CGFloat) {
        // This is very slow because of temporary allocation: 
        // self.position += self.direction * distance
        // This is much faster because done in place:
        self.position.addScaledVector(self.direction, scale:distance)
        self.distanceTraveled += distance;
        self.statistics.append((self.position, self.weight))
    }
    
    func decreaseWeightBy(_ delta:CGFloat) {
        self.weight -= delta

        if self.weight < 0 {
            self.weight = 0
        }
    }

    func multiplyWeightBy(scale:CGFloat) {
        self.weight *= scale
        
        if self.weight < 0 {
            self.weight = 0
        }
    }

    func isAlive() -> Bool {
        return weight > 0
    }
    
    func changeDirectionBy(_ θ:CGFloat,_ φ:CGFloat ) {
        self.ePerp.rotateAroundAxis(self.direction, byAngle: φ)
        try! self.ePerp.normalize()
        self.direction.rotateAroundAxis(self.ePerp, byAngle: θ)
        try! self.direction.normalize()
    }

    
    func rotateReferenceFrameInFresnelPlaneWithNormal( theNormal:Vector3D ) {
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
        let CHANCE:CGFloat = 0.1
        let WeightThreshold:CGFloat = 1e-4
        
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
