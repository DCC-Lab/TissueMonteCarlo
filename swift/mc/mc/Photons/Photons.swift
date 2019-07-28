//
//  Photons.swift
//  mc
//
//  Created by Daniel Côté on 2019-06-23.
//  Copyright © 2019 DCCLab. All rights reserved.
//

import Foundation

typealias Scalars = [Scalar]
typealias Vectors = [Vector]

class Photons {
    var N:Int
    var r⃗:Vectors
    var û:Vectors
    var êr:Vectors
    var weight:Scalars
    let λ:Scalars
    
    let r⃗ₒ:Vectors
    let ûₒ:Vectors
    var êrₒ:Vectors
    var keepingExtendedStatistics:Bool
    var statistics:[(Vectors,Scalars)]
    var distanceTraveled:Scalars
    
    init?(positions:Vectors, directions:Vectors, wavelengths:Scalars) {
        N = positions.count
        
        r⃗ = positions
        û = directions
        û.normalize()
        
        weight = Scalars(repeating: 1, count:N)
        λ = wavelengths
        
        r⃗ₒ = positions
        ûₒ = û
        
        keepingExtendedStatistics = false
        distanceTraveled = Scalars(repeating: 0, count:N)
        statistics = [(r⃗ₒ,weight)]
        êr = Vectors( vector:Vector(0,0,0), count: N)
        êrₒ = Vectors(vector:Vector(0,0,0), count: N)
        if let vector = defaultEPerpendicular(directions: û) {
            êr = vector
        } else {
            return nil
        }
        êrₒ = êr
    }

    convenience init?(position:Vector, direction:Vector, wavelength:Scalar, N:Int) {
        let thePositions = Vectors(repeating: position, count: N)
        let theDirections = Vectors(repeating: direction, count: N)
        let theWavelength = Scalars(repeating: wavelength, count: N)
        self.init(positions:thePositions, directions:theDirections, wavelengths:theWavelength)
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

    func defaultEPerpendicular(directions:Vectors) -> Vectors? {
        var results = Vectors()
        for û in directions {
            if û.isParallelTo(ẑ) {
                results.append(x̂)
            } else if û.isParallelTo(x̂) {
                results.append(ŷ)
            } else if û.isParallelTo(ŷ) {
                results.append(ẑ)
            } else {
                return nil
            }
        }
        return results
    }

    func reset() {
        
    }
    
    func moveBy(_ distance:Scalars) {
        r⃗ += û * distance
        distanceTraveled += distance
    }

    func scatterBy(_ θ:Scalars,_ φ:Scalars ) {
        êr.rotateAroundAxis(û, byAngle: φ)
        û.rotateAroundAxis(êr, byAngle: θ)

        êr.normalize()
        û.normalize()
    }

    func propagate(into material:BulkMaterial, for distance:Scalar = 0) throws {
        while photons.isAlive() {
            let (θ, φ) = material.randomScatteringAngles(photons:self)
            let distances = material.randomScatteringDistance(photons:self)
            let albedo = material.albedo(photons:self)
            scatterBy(θ, φ)
            moveBy(distances)
            decreaseWeightBy(albedo * weight)
            roulette()
        }
    }

    func isAlive() -> Bool {
        for weight in self.weight {
            if weight > 0 {
                return true
            }
        }
        return false
    }
    
    func decreaseWeightBy(_ delta:Scalars) {
        weight = weight - delta
    }

    func roulette() {
        let CHANCE:Scalar = 0.1
        let threshold:Scalar = 1e-4
        
        for (i,weight) in self.weight.enumerated() {
            if weight <= threshold {
                let randomScalar = Scalar.random(in:0...1)
                if( randomScalar < CHANCE) {
                    /* survived the roulette.*/
                    self.weight[i] *= 1.0 / CHANCE
                } else {
                    self.weight[i]  = 0
                }
            }
        }
    }

}
//class PhotonSIMD4 {
//
//    var position:float4
//    var û:float4
//    var er:float4
//    var weight:Float
//    let λ:Float
//
//    let r⃗ₒ:float4
//    let ûₒ:float4
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
//        return String(format: "P: ( %0.2f,%0.2f,%0.2f ) D:(%0.2f,%0.2f,%0.2f ) W:%0.2f",self.position.x,self.position.y,self.position.z,self.û.x,self.û.y,self.û.z,self.weight )
//    }
//
//
//    init?(position:float4, û:float4, λ:Float) {
//        self.position = position
//        self.û = û
//        self.weight = 1
//        self.λ = λ
//
//        self.r⃗ₒ = position
//        self.ûₒ = û
//
//        self.keepingExtendedStatistics = false
//        self.distanceTraveled = 0
//        self.statistics = []
//        self.er = oHat
//        if self.û == zHat {
//            self.er = xHat
//        } else if (self.û == xHat) {
//            self.er = yHat
//        } else if (self.û == yHat) {
//            self.er = zHat
//        } else if self.û == -zHat {
//            self.er = -xHat
//        } else if (self.û == -xHat) {
//            self.er = -yHat
//        } else if (self.û == -yHat) {
//            self.er = -zHat
//        }
//
//        if û.norm() == 0 {
//            return nil
//        }
//
//    }
//
//    func reset() {
//        self.position = self.r⃗ₒ
//        self.û = self.ûₒ
//        self.er = xHat
//        self.weight = 1
//        self.keepingExtendedStatistics = false
//        self.distanceTraveled = 0
//        self.statistics = [(self.r⃗ₒ,self.weight)]
//    }
//
//    func propagate(into material:BulkMaterialSIMD4, for distance:Scalar) throws {
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
//        self.position.addScaledVector(self.û, scale:distance)
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
//    func scatterBy(_ θ:Float,_ φ:Float ) {
//        self.er.rotateAroundAxis(self.û, byAngle: φ)
//        self.û.rotateAroundAxis(self.er, byAngle: θ)
//
//        try! _ = self.er.normalize()
//        try! _ = self.û.normalize()
//    }
//
//
//    func rotateReferenceFrameInFresnelPlaneWithNormal( theNormal:Vector ) {
//        /* We always want the "s hat" vector in the same orientation
//         compared to dir, regardless of the normal (i.e the normal
//         could be pointing in or out) */
//        var s = û.normalizedCrossProduct(theNormal)
//
//        if û.normalizedDotProduct(theNormal) < 0  {
//            s = s*(-1)
//        }
//
//        do {
//            try _ = s.normalize()
//            let phi = er.orientedAngleWith(s, aroundAxis: û)
//            er.rotateAroundAxis(û, byAngle: phi)
//            try _ = er.normalize()
//        } catch {
//
//        }
//
//        assert(er.isPerpendicularTo(û), "er not perpendicular to û")
//        assert(er.isPerpendicularTo(theNormal), "er not perpendicular to normal")
//    }
//
//    func roulette() {
//        let CHANCE:Scalar = 0.1
//        let WeightThreshold:Scalar = 1e-4
//
//        if self.weight <= WeightThreshold {
//            let randomfloat = Scalar.random(in:0...1)
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

/*
 func propagate(into material:BulkMaterialSIMD4, for distance:Scalar) throws {
 for i in 0...1000 {
 op0 = getPositionsDirectionDistance()
 op1 = getRandomScatteringAngles(N)
 op2 = getRandomScatteringDistance(N)
 op3 = getPropagationMatrix(d)
 op4 = getScatteringMatrix(θ, φ)
 op5 = getIntersection()
 }
 }
 */


//class Photons {
//    var positions:[Vector]
//    var ûs:[Vector]
//    var ers:[Vector]
//    var weights:[Scalar]
//    let λs:[Scalar]
//
//    let r⃗ₒs:[Vector]
//    let ûₒs:[Vector]
//    var keepingExtendedStatistics:Bool
//    var statistics:[(Vector,Scalar)]
//    var distanceTraveled:[Scalar]
//
//    init?(positions:[Vector], ûs:[Vector], λs:[Scalar]) {
//        let N = positions.count
//        guard N == ûs.count && N == λs.count else {
//            return nil
//        }
//
//        self.positions = positions
//        self.ûs = ûs
//        self.weights = [Scalar](repeating: 1.0, count: N)
//        self.λs = λs
//
//        self.r⃗ₒs = positions
//        self.ûₒs = ûs
//
//        self.keepingExtendedStatistics = false
//        self.distanceTraveled = []
//        self.statistics = []
//
//        self.ers = [Vector](repeating: oHat, count: N)
//        for (i, û) in ûs.enumerated() {
//            ers[i] = defaultPerpendicularPlane(propagation: û)
//        }
//
//    }
//
//    func defaultPerpendicularPlane(propagation û:Vector) -> Vector {
//        if û == zHat {
//            return xHat
//        } else if (û == xHat) {
//            return  yHat
//        } else if (û == yHat) {
//            return  zHat
//        } else if û == -zHat {
//            return  -xHat
//        } else if (û == -xHat) {
//            return  -yHat
//        } else if (û == -yHat) {
//            return  -zHat
//        }
//        return oHat
//    }
//
//    func reset() {
//        let N = positions.count
//        self.positions = self.r⃗ₒs
//        self.ûs = self.ûₒs
//        self.ers = [Vector](repeating: oHat, count: N)
//        for (i, û) in ûs.enumerated() {
//            ers[i] = defaultPerpendicularPlane(propagation: û)
//        }
//
//        self.weights = [Scalar](repeating: 1.0, count: N)
//    }
//
//    func propagate(into material:BulkMaterial, for distance:Scalar) throws {
////        while isAlive() {
////            let (θ, φ) = material.randomScatteringAngles()
////            let distance = material.randomScatteringDistance()
////            if distance.isInfinite {
////                weight = 0
////            } else {
////                scatterBy(θ, φ)
////                moveBy(distance)
////                material.absorbEnergy(self)
////            }
////            roulette()
////        }
//    }
//
//    func moveBy(_ distances:[Scalar]) {
//        self.position.addScaledVector(self.û, scale:distance)
//        self.distanceTraveled += distance;
//        //self.statistics.append((self.position, self.weight))
//    }
//
//    func decreaseWeightBy(_ delta:Scalar) {
//        self.weight -= delta
//        if self.weight < 0 {
//            self.weight = 0
//        }
//    }
//
//    func multiplyWeightBy(scale:Scalar) {
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
//    func scatterBy(_ θ:Scalar,_ φ:Scalar ) {
//        self.er.rotateAroundAxis(self.û, byAngle: φ)
//        self.û.rotateAroundAxis(self.er, byAngle: θ)
//
//        try! _ = self.er.normalize()
//        try! _ = self.û.normalize()
//    }
//
//
//    func rotateReferenceFrameInFresnelPlaneWithNormal( theNormal:Vector ) {
//        /* We always want the "s hat" vector in the same orientation
//         compared to dir, regardless of the normal (i.e the normal
//         could be pointing in or out) */
//        var s = û.normalizedCrossProduct(theNormal)
//
//        if û.normalizedDotProduct(theNormal) < 0  {
//            s = s*(-1)
//        }
//
//        do {
//            try _ = s.normalize()
//            let phi = er.orientedAngleWith(s, aroundAxis: û)
//            er.rotateAroundAxis(û, byAngle: phi)
//            try _ = er.normalize()
//        } catch {
//
//        }
//
//        assert(er.isPerpendicularTo(û), "er not perpendicular to û")
//        assert(er.isPerpendicularTo(theNormal), "er not perpendicular to normal")
//    }
//
//    func roulette() {
//        let CHANCE:Scalar = 0.1
//        let WeightThreshold:Scalar = 1e-4
//
//        if self.weight <= WeightThreshold {
//            let randomfloat = Scalar.random(in:0...1)
//
//            if( randomfloat < CHANCE) {
//                /* survived the roulette.*/
//                self.multiplyWeightBy( scale: 1.0 / CHANCE );
//            } else {
//                self.weight = 0
//            }
//        }
//    }
//
//}
////
////class PhotonMPS {
////    var device:MTLDevice!
////    var library:MTLLibrary!
////    var queue:MTLCommandQueue!
////
////    var mpsVector:MPSVector?
////
////    required init?() {
////        let devices = MTLCopyAllDevices()
////        guard devices.count > 0 else {
////            return nil
////        }
////        device = devices[0]
////
////        for potentialDevice in devices {
////            if !potentialDevice.isLowPower {
////                device = potentialDevice
////            }
////        }
////
////        library = device!.makeDefaultLibrary()!
////        queue = device!.makeCommandQueue()!
////
//////
//////        buffer: MTLBuffer, descriptor: MPSVectorDescriptor)
////
//////        mpsVector = MPSVector()
////    }
////}
//
//
