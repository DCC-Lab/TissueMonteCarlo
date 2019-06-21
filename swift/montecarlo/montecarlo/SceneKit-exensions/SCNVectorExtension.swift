//
//  SCNVectorExtension.swift
//  MonteCarlo3D
//
//  Created by Daniel Côté on 2015-03-23.
//  Copyright (c) 2015 Daniel Côté. All rights reserved.
//

import Foundation
import SceneKit

let π:CGFloat = 3.1415926535
enum VectorError : ErrorType { case Null }

typealias Vector3D = SCNVector3


infix operator ×
infix operator •
infix operator ⟂
infix operator ‖


extension SCNVector3:CustomStringConvertible {

    static func vectorFromString(theString:String) -> SCNVector3? {
        let regexp = try! NSRegularExpression(pattern: "[+|-]?\\d+\\.?\\d*", options: NSRegularExpression.Options.caseInsensitive)
        
        let textResults = regexp.matches(in: theString, options: [], range: NSMakeRange(0,theString.lengthOfBytes(using: String.Encoding.isoLatin1)))
        
        var numbers = [Float]()
        for result in textResults {
            for i in 0..<result.numberOfRanges {
                let startIndex = result.range(at: i).location
                let endIndex = result.range(at: i).location+result.range(at: i).length
                
                let numberString = theString.substringWith(theString.startIndex.advancedBy(startIndex)..<theString.startIndex.advancedBy(endIndex))
                let number = Float(numberString)
                if number != nil {
                    numbers.append(number!)
                }
            }
        }
        if numbers.count != 3 {
            return nil
        }
        
        return SCNVector3(numbers[0],numbers[1],numbers[2])
        
    }

    static func randomVector() -> SCNVector3 {
        let x = CGFloat(arc4random())/CGFloat(RAND_MAX)
        let y = CGFloat(arc4random())/CGFloat(RAND_MAX)
        let z = CGFloat(arc4random())/CGFloat(RAND_MAX)
        
        return SCNVector3(x: x, y: y, z: z)
    }

    public var description: String {
        return "(\(x),\(y),\(z))"
    }
    
    subscript(index: Axis) -> CGFloat {
            get {
                switch index {
                case .X:
                    return x
                case .Y:
                    return y
                case .Z:
                    return z
                }
            }
        
            set(newValue) {
                switch index {
                case .X:
                    x = newValue
                case .Y:
                    y = newValue
                case .Z:
                    z = newValue
                }
            }
    }
    
    func norm() -> CGFloat {
        return x*x + y*y + z*z
    }
    
    func abs() -> CGFloat {
        return sqrt(x*x + y*y + z*z)
    }
    
    mutating func normalize() throws -> SCNVector3 {
        let value = sqrt(x*x + y*y + z*z)

        if value != 0 {
            x = x / value
            y = y / value
            z = z / value
        } else {
            throw VectorError.Null
        }
        return self
    }
    
    mutating func addScaledVector(theVector:SCNVector3, scale theScale:CGFloat) {
        x += theVector.x * theScale;
        y += theVector.y * theScale;
        z += theVector.z * theScale;
    }
    
    func dotProduct(_ theVector : SCNVector3 ) -> CGFloat {
        return x * theVector.x + y * theVector.y + z * theVector.z;
    }
    
    func normalizedDotProduct(_ theVector: SCNVector3 ) -> CGFloat {
        var prod = self.dotProduct(theVector)
        
        let norm_u = norm()
        let norm_v = theVector.norm()
        
        if norm_u != 0 && norm_v != 0 {
            prod /= sqrt(norm_u * norm_v);
        }
        
        if prod > 1 {
            return 1
        } else if prod < -1 {
            return -1
        }
        
        return prod;
    }
    
    func crossProduct(_ v: SCNVector3) -> SCNVector3 {
        return  SCNVector3(x:y * v.z - z * v.y,  y:z * v.x - x * v.z,  z: x * v.y - y * v.x)
    }
    
    func normalizedCrossProduct(_ v: SCNVector3) -> SCNVector3 {
        var t = self.crossProduct(v)
        
        let norm_u = self.norm()
        let norm_v = v.norm()
        
        if norm_u != 0 && norm_v != 0 {
            t /= sqrt(norm_u * norm_v);
        }
        
        let norm_t = t.norm()
        if norm_t > 1 {
            t /= sqrt(norm_t);
        }
        
        return t;
    }
    
    func tripleProduct(v : SCNVector3, w : SCNVector3) -> CGFloat {
        let cp = crossProduct(v)
        
        return cp.dotProduct(w)
    }
    
    func orientedAngleWith( y:SCNVector3 , aroundAxis r:SCNVector3 ) -> CGFloat {
        let sinPhi = self.normalizedCrossProduct(y)
        
        var phi = asin(sinPhi.abs())
        
        if self.dotProduct(y) <= 0 {
            phi = .pi - phi
        }
        
        if sinPhi.dotProduct(r) <= 0 {
            phi *= -1
        }
        
        return phi;
    }
    
    func distanceToPlaneWithOrigin(origin v0: SCNVector3, normal vn:SCNVector3, alongVector vd:SCNVector3 )-> CGFloat {
        return -(vn.x * (x - v0.x) + vn.y * (y - v0.y) + vn.z * (z - v0.z) ) / (vn.x * vd.x + vn.y * vd.y + vn.z * vd.z)
    }
    
    func isParallelTo(_ v:SCNVector3 ) -> Bool {
        let dp = self.dotProduct(v)
        
        if fabs(dp/self.abs()/v.abs() - 1) <= 1e-5  {
            return true
        }
        
        return false
    }
    
    func isPerpendicularTo(_ v:SCNVector3 ) -> Bool {
        let dp = self.dotProduct(v)
        
        if fabs(dp)/self.abs()/v.abs() <= 1e-5 {
            return true
        }
        
        return false
    }
    
    mutating func rotateAroundX( inPhi: CGFloat) {
        let c = cos(inPhi)
        let s = sin(inPhi)
        let tempY = y
        
        y = c * tempY - s * z
        z = s * tempY + c * z
    }
    
    mutating func rotateAroundY( inPhi: CGFloat) {
        let c = cos(inPhi)
        let s = sin(inPhi)
        let tempZ = z
        
        z = c * tempZ - s * x
        x = s * tempZ + c * x
    }
    
    mutating func rotateAroundZ( inPhi: CGFloat) {
        let c = cos(inPhi)
        let s = sin(inPhi)
        let tempX = x
        
        x = c * tempX - s * y
        y = s * tempX + c * y
    }
    
    mutating func rotateAroundAxis(u:SCNVector3, byAngle theta:CGFloat) {
        //http://en.wikipedia.org/wiki/Rotation_matrix
        
        let cosTheta = cos(theta)
        let sinTheta = sin(theta)
        let oneMinusCosTheta = 1 - cosTheta
        
        let ux:CGFloat = u.x
        let uy:CGFloat = u.y
        let uz:CGFloat = u.z
        
        let X = x
        let Y = y
        let Z = z
        
        x = (cosTheta + ux * ux * oneMinusCosTheta ) * X + (ux*uy * oneMinusCosTheta - uz * sinTheta) * Y
        x = x + (ux * uz * oneMinusCosTheta + uy * sinTheta ) * Z
        y = (uy*ux * oneMinusCosTheta + uz * sinTheta) * X + (cosTheta + uy * uy * oneMinusCosTheta ) * Y
        y = y + (uy * uz * oneMinusCosTheta - ux * sinTheta ) * Z
        z = (uz*ux * oneMinusCosTheta - uy * sinTheta) * X + (uz * uy * oneMinusCosTheta + ux * sinTheta) * Y
        z = z + (cosTheta + uz*uz * oneMinusCosTheta) * Z
    }
}

func == (left: SCNVector3, right: SCNVector3) -> Bool {
    let diff = (left-right).abs()
    
    if diff < 1e-6 {
        return true
    }
    return false
}

prefix func - (vector: SCNVector3) -> SCNVector3 {
    return SCNVector3(x: -vector.x, y: -vector.y, z:-vector.z)
}

func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3(x: left.x + right.x, y: left.y + right.y, z:left.z + right.z)
}

func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3(x: left.x - right.x, y: left.y - right.y, z:left.z - right.z)
}

func * (left: SCNVector3, scalar: CGFloat) -> SCNVector3 {
    return SCNVector3(x: left.x * scalar, y: left.y * scalar, z:left.z * scalar)
}

func * (scalar: CGFloat, left: SCNVector3) -> SCNVector3 {
    return SCNVector3(x: left.x * scalar, y: left.y * scalar, z:left.z * scalar)
}

func / (left: SCNVector3, scalar: CGFloat) -> SCNVector3 {
    return SCNVector3(x: left.x / scalar, y: left.y / scalar, z:left.z / scalar)
}

func × (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return left.crossProduct(right)
}

func • (left: SCNVector3, right: SCNVector3) -> CGFloat {
    return left.dotProduct(right)
}

func ⟂ (left: SCNVector3, right: SCNVector3) -> Bool {
    return left.isPerpendicularTo(right)
}

func ‖ (left: SCNVector3, right: SCNVector3) -> Bool {
    return left.isParallelTo(right)
}

func += ( left: inout SCNVector3, right: SCNVector3) {
    left.x += right.x
    left.y += right.y
    left.z += right.z
}

func -= ( left: inout SCNVector3, right: SCNVector3) {
    left.x -= right.x
    left.y -= right.y
    left.z -= right.z
}

func *= ( left: inout SCNVector3, scalar: CGFloat) {
    left.x *= scalar
    left.y *= scalar
    left.z *= scalar
}

func /= ( left: inout SCNVector3, scalar: CGFloat) {
    left.x /= scalar
    left.y /= scalar
    left.z /= scalar
}


let xHat = SCNVector3(x: 1, y: 0, z: 0)
let yHat = SCNVector3(x: 0, y: 1, z: 0)
let zHat = SCNVector3(x: 0, y: 0, z: 1)
let oHat = SCNVector3(x: 0, y: 0, z: 0)


