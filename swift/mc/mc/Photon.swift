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

class GenericPhoton<T, V, M:MatrixProtocol> where T == V.T, V == M.V  {
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
        if self.direction == V.zHat {
            self.ePerp = V.xHat
        } else if (self.direction == V.xHat) {
            self.ePerp = V.yHat
        } else if (self.direction == V.yHat) {
            self.ePerp = V.zHat
        }

        if direction.norm() == T(0.0) {
            return nil
        }

    }
    
    func reset() {
        self.position = self.originalPosition
        self.direction = self.originalDirection
        self.ePerp = V.xHat
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
                material.absorbEnergy(self)
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

class PhotonSIMD4 : GenericPhoton<Float, float4, float4x4> {

    override func propagate(into material:BulkMaterial<Float, float4, float4x4>, for distance:Float) throws {
        while isAlive() {
            let (θ, φ) = material.randomScatteringAngles()
            let distance = Float(material.randomScatteringDistance())
            let d⃗  = direction * distance
            let T  = float4x4.translate(d⃗)
            let mφ = float4x4.rotate(radians: Float(φ), axis: direction)
            let mθ = float4x4.rotate(radians: Float(θ), axis: ePerp)
            position = mθ * mφ * T * position
            material.absorbEnergy(self)
            roulette()
        }
    }

    override func moveBy(_ distance:Float) {
        self.position.addScaledVector(self.direction, scale:distance)
        self.distanceTraveled += distance
    }

    override func scatterBy(_ θ:Float,_ φ:Float ) {
        self.ePerp.rotateAroundAxis(self.direction, byAngle: φ)
        self.direction.rotateAroundAxis(self.ePerp, byAngle: θ)

        try! _ = self.ePerp.normalize()
        try! _ = self.direction.normalize()
    }
}
