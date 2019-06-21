//
//  Photon.swift
//  Photon
//
//  Created by Daniel Côté on 2015-02-19.
//  Copyright (c) 2015 Daniel Côté. All rights reserved.
//

import Foundation
import SceneKit


class SCNHitTestResultExtended {
    let hitTestResult:SCNHitTestResult
    var direction:SCNVector3
    var indexFrom:CGFloat?
    var indexTo:CGFloat?
    var Rp:CGFloat?
    var Rs:CGFloat?
    var Tp:CGFloat?
    var Ts:CGFloat?
    
    init(hitTest:SCNHitTestResult, direction:SCNVector3) {
        self.hitTestResult = hitTest
        self.direction = direction
    }
    
    func setFresnelCoefficients() -> Void {
        /* Compute angles */
        
        indexFrom = 1
        indexTo = 1
        
        for child in hitTestResult.node.childNodes {
            if  let material = child as? BulkMaterial {
                indexFrom = material.index
            }
        }
        
        
        let cosThetaFrom = abs(direction.dotProduct(hitTestResult.worldNormal));
        let sinThetaFrom = sqrt(1.0 - cosThetaFrom*cosThetaFrom);
        
        let m = indexTo!/indexFrom!
        
        if ( m == 1.0) {
            Rp = 0.0
            Rs = 0.0
            Tp = 1.0
            Ts = 1.0
        }
        
        let sinThetaTo = sinThetaFrom / m;
        
        if (sinThetaTo >= 1.0) {
            // Past critical angle, totally reflected
            Rp = 1.0
            Rs = 1.0
            Tp = 0.0
            Ts = 0.0
        }
        
        let cosThetaTo = sqrt(1.0 - sinThetaTo*sinThetaTo);
        
        // Fresnel coefficients for fields (not intensities)
        Tp = 2.0 * cosThetaFrom / (cosThetaTo + m * cosThetaFrom);
        Ts = 2.0 * cosThetaFrom / (cosThetaFrom + m * cosThetaTo);
        Rp = Tp! * m - 1.0
        Rs = Ts! - 1.0
    }

}

enum MonteCarloError: ErrorType {
    case UnexpectedNil
}

class Photon:CustomStringConvertible {

    let originalPosition:Vector3D
    let originalDirection:Vector3D
    let wavelength:CGFloat
    var position:Vector3D
    var direction:Vector3D
    var ePerp:Vector3D
    var weight:CGFloat
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
    
    func propagateInto(objectsRoot:SCNNode, distance theDistance:CGFloat) throws {

        let defaultOptions:[String:AnyObject] = [SCNHitTestBackFaceCullingKey:false, SCNHitTestSortResultsKey:true, SCNHitTestIgnoreHiddenNodesKey:false, SCNHitTestRootNodeKey:objectsRoot]
        let SAFETY_DISTANCE:CGFloat = 1e-4
        
        while isAlive() {
            let thePosition = position
            let theMaterial = objectsRoot.propertiesAtPosition(thePosition)
            let (θ, φ) = theMaterial.randomScatteringAngles()
            let distance = theMaterial.randomScatteringDistance()
            
            let theDisplacement = direction * (distance+2*SAFETY_DISTANCE)
            
            let hitList = objectsRoot.fastHitTestWithSegmentFromPoint(thePosition, toPoint: thePosition + theDisplacement, options: defaultOptions)
            
            if hitList.count > 0 {
                let hit = hitList[0]
                
                let distanceToInterface = (hit.worldCoordinates - thePosition).abs()
                
                let extendedHit = SCNHitTestResultExtended(hitTest:hit, direction:direction)
                
                moveBy(distanceToInterface - SAFETY_DISTANCE)
                if try isReflectedFromInterface(extendedHit) {
                    reflectAtInterface(extendedHit)
                } else {
                    try transmitThroughInterface(extendedHit)
                    moveBy(2.0 * SAFETY_DISTANCE)
                }
            } else {
                if distance == theMaterial.infiniteDistance {
                    weight = 0
                } else {
                    moveBy(distance)
                    changeDirectionBy(θ, φ:φ)
                    let energyLoss = weight * theMaterial.albedo();
                    decreaseWeightBy(energyLoss)
                }
            }
            
            roulette()
        }
    }

    func moveBy(distance:CGFloat) {
        // This is very slow because of temporary allocation: 
        // self.position += self.direction * distance
        // This is much faster because done in place:
        self.position.addScaledVector(self.direction, scale:distance)
        self.distanceTraveled += distance;
        self.statistics.append((self.position, self.weight))
    }
    
    func decreaseWeightBy(delta:CGFloat) -> CGFloat {
        self.weight -= delta

        if self.weight > 0 {
            return self.weight
        } else {
            self.weight = 0
            return self.weight
        }
    }

    func multiplyWeightBy(scale:CGFloat) -> CGFloat {
        self.weight *= scale
        
        if self.weight < 0 {
            self.weight = 0
        }
        
        return self.weight;
    }

    func isAlive() -> Bool {
        return weight > 0
    }
    
    func changeDirectionBy(θ:CGFloat, φ:CGFloat ) {
        assert(!isnan(self.ePerp.x) && !isnan(self.ePerp.y) && !isnan(self.ePerp.z),"Eperp is nan")
        self.ePerp.rotateAroundAxis(self.direction, byAngle: φ)
        
        try! self.ePerp.normalize()
        
        assert( self.ePerp.norm() != 0 ,"ePerp is null")
        assert(!isnan(self.ePerp.x) && !isnan(self.ePerp.y) && !isnan(self.ePerp.z),"Eperp is nan")
        
        self.direction.rotateAroundAxis(self.ePerp, byAngle: θ)
        try! self.direction.normalize()
        assert(!isnan(self.direction.x) && !isnan(self.direction.y) && !isnan(self.direction.z),"Direction is nan")
 
        assert(ePerp.isPerpendicularTo(direction), "ePerp not perpendicular to direction dp= \( ePerp.normalizedDotProduct(direction))")

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
    
    func isReflectedFromInterface(intersect:SCNHitTestResultExtended) throws -> Bool {
        rotateReferenceFrameInFresnelPlaneWithNormal(intersect.hitTestResult.worldNormal)
        intersect.setFresnelCoefficients()
        
        let probability:CGFloat
        if ( intersect.Rp != nil && intersect.Rs != nil ) {
            probability = (intersect.Rp! * intersect.Rp! / 2.0 + intersect.Rs! * intersect.Rs! / 2.0);
        } else {
            throw MonteCarloError.UnexpectedNil
        }
    
        let num = BulkMaterial.randomFloat()
    
        if num < probability {
            return true
        } else {
            return false
        }
    
    }
    
    func reflectAtInterface(intersect:SCNHitTestResultExtended) {
        rotateReferenceFrameInFresnelPlaneWithNormal(intersect.hitTestResult.worldNormal)

        let θi = acos(abs(self.direction.normalizedDotProduct(intersect.hitTestResult.worldNormal)))
        changeDirectionBy(-π + 2*θi, φ: 0)
    }
    
    func transmitThroughInterface(intersect:SCNHitTestResultExtended) throws {
        rotateReferenceFrameInFresnelPlaneWithNormal(intersect.hitTestResult.worldNormal)
    
        let θi = acos(abs(direction.normalizedDotProduct(intersect.hitTestResult.worldNormal)))

        let sinθt = sin(θi) / (intersect.indexFrom!/intersect.indexTo!)
        
        if ( sinθt <= 1.0) {
            let θt = asin(sinθt);
            changeDirectionBy(θi - θt, φ: 0)
        } else {
            throw MonteCarloError.UnexpectedNil
        }
    }
    
    func roulette() {
        let CHANCE:CGFloat = 0.1
        let WeightThreshold:CGFloat = 1e-4
        
        if self.weight <= WeightThreshold {
           let randomFloat = BulkMaterial.randomFloat()
            
            if( randomFloat < CHANCE) {
                /* survived the roulette.*/
                self.multiplyWeightBy( 1.0 / CHANCE );
            } else {
                self.weight = 0
            }
        }
    }
}