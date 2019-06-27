//
//  MonteCarlo3DTests.swift
//  MonteCarlo3DTests
//
//  Created by Daniel Côté on 2015-03-23.
//  Copyright (c) 2015 Daniel Côté. All rights reserved.
//

import Cocoa
import SceneKit
import XCTest
@testable import mc
import SceneKit

public let π:CGFloat = 3.1415926535
public let xHat = SCNVector3(x: 1, y: 0, z: 0)
public let yHat = SCNVector3(x: 0, y: 1, z: 0)
public let zHat = SCNVector3(x: 0, y: 0, z: 1)
public let oHat = SCNVector3(x: 0, y: 0, z: 0)

class VectorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func myRandom() -> CGFloat {
        return CGFloat(arc4random_uniform(30000))/30000
    }

    func testVector() {
        
        // Basic
        let start = NSDate()
        print("Basic test started: rotation around XYZ axes");
        var vectorA = xHat;
        var vectorB = xHat;
        vectorA.rotateAroundZ(π/2)
        vectorB.rotateAroundAxis(zHat, byAngle: π/2)
        XCTAssert(vectorA == vectorB, "Rotation around Z failed")
        XCTAssert(vectorA == yHat, "Rotation around Z failed")
        vectorA.rotateAroundX(π/2)
        vectorB.rotateAroundAxis(xHat, byAngle: π/2)
        XCTAssert(vectorA == vectorB, "Rotation around X failed")
        XCTAssert(vectorA == zHat, "Rotation around X failed")
        vectorA.rotateAroundY(π/2)
        vectorB.rotateAroundAxis(yHat, byAngle: π/2)
        XCTAssert(vectorA == vectorB, "Rotation around Y failed \(vectorA.description) \(vectorB.description)")
        XCTAssert(vectorA == xHat, "Rotation around Y failed \(vectorA.description) is not \(xHat.description)")
        print("Done in \(-start.timeIntervalSinceNow)");
        
        // Arbitrary axis
       
        print("Done rotations");
        
    }
    
//    func testInitFromText() {
//        var vector = SCNVector3.vectorFromString("(1,2,3)")
//        XCTAssertNotNil(vector)
//        XCTAssert(vector! == SCNVector3(1,2,3))
//        vector = SCNVector3.vectorFromString("(-1,2.0,0.3)")
//        XCTAssertNotNil(vector)
//        XCTAssert(vector! == SCNVector3(-1,2,0.3))
//
//        vector = SCNVector3.vectorFromString("(1,2)")
//        XCTAssertNil(vector)
//        vector = SCNVector3.vectorFromString("(1,2,3,4)")
//        XCTAssertNil(vector)
//
//    }
    
    func testNorm() {
        var aVector = SCNVector3(0,1,2)
        XCTAssertEqualWithAccuracy(5, aVector.norm(), accuracy: 1e-6)
        aVector = SCNVector3(0,0,0)
        XCTAssertEqualWithAccuracy(0, aVector.norm(), accuracy: 1e-6)
    }

    func testAbs() {
        var aVector = SCNVector3(0,1,2)
        XCTAssertEqualWithAccuracy(sqrt(5), aVector.abs(), accuracy: 1e-6)
        aVector = SCNVector3(0,0,0)
        XCTAssertEqualWithAccuracy(0, aVector.abs(), accuracy: 1e-6)
    }

    func testNormalize() {
        var aVector = SCNVector3(0,0,10)
        do {
            try aVector.normalize()
            XCTAssert(aVector == SCNVector3(0,0,1))
        } catch {
            XCTFail("Normalization should have succeeded")
        }
        aVector = SCNVector3(0,0,0)
        do {
            try aVector.normalize()
            XCTFail("Normalization should have thrown")
        } catch {
            
        }
    }

    func testDotProduct() {
        let v1 = SCNVector3(0,1,2)
        let v2 = SCNVector3(3,4,5)
        let v3 = SCNVector3(0,0,0)
        XCTAssertEqualWithAccuracy(v1.dotProduct(v2), 14, accuracy: 1e-6)
        XCTAssertEqualWithAccuracy(v1·v2, 14, accuracy: 1e-6)
        XCTAssertEqualWithAccuracy(v1.dotProduct(v3), 0, accuracy: 1e-6)

    }

    func testCrossProduct() {
        XCTAssert(xHat.crossProduct(yHat) == zHat)
        xHat × yHat
        XCTAssert(yHat.crossProduct(zHat) == xHat)
        XCTAssert(zHat.crossProduct(xHat) == yHat)
        
    }

    func testTripleProduct() {
        XCTAssert(xHat.tripleProduct(v:yHat, w: zHat) == 1)
        
    }
    
    func testOrientedAngle() {
        let v2 = SCNVector3(1,1,0)
        let v3 = SCNVector3(1,-1,0)
        let v4 = SCNVector3(0,1,1)
        let v5 = SCNVector3(0,1,-1)
        let v6 = SCNVector3(1,0,1)
        let v7 = SCNVector3(-1,0,1)
        
        XCTAssertEqualWithAccuracy(xHat.orientedAngleWith(v2, aroundAxis: zHat), π/4, accuracy: 1e-6)
        XCTAssertEqualWithAccuracy(xHat.orientedAngleWith(v3, aroundAxis: zHat), -π/4, accuracy: 1e-6)

        XCTAssertEqualWithAccuracy(yHat.orientedAngleWith(v4, aroundAxis: xHat), π/4, accuracy: 1e-6)
        XCTAssertEqualWithAccuracy(yHat.orientedAngleWith(v5, aroundAxis: xHat), -π/4, accuracy: 1e-6)

        XCTAssertEqualWithAccuracy(zHat.orientedAngleWith(v6, aroundAxis: yHat), π/4, accuracy: 1e-6)
        XCTAssertEqualWithAccuracy(zHat.orientedAngleWith(v7, aroundAxis: yHat), -π/4, accuracy: 1e-6)

    }

    func testIsParallel() {
        let v = SCNVector3(1,1,0)

        XCTAssert(v.isParallelTo(v))
        XCTAssert(v.isParallelTo(3*v))

        for _ in 0...1000 {
            let v1 = SCNVector3.randomVector()
            XCTAssert(v1.isParallelTo(4*v1))
        }

        XCTAssert(xHat.isParallelTo(xHat))
        XCTAssert(xHat‖xHat)
        XCTAssert(yHat.isParallelTo(yHat))
        XCTAssert(zHat.isParallelTo(zHat))

        XCTAssert(!xHat.isParallelTo(yHat))
        XCTAssert(!yHat.isParallelTo(zHat))
        XCTAssert(!zHat.isParallelTo(xHat))

    }

    func testIsPerpendicular() {
        XCTAssert(xHat.isPerpendicularTo(yHat))
        XCTAssert(xHat ⟂ yHat)
        XCTAssert(yHat.isPerpendicularTo(xHat))
        XCTAssert(xHat.isPerpendicularTo(zHat))
        XCTAssert(zHat.isPerpendicularTo(xHat))
        XCTAssert(yHat.isPerpendicularTo(zHat))
        XCTAssert(zHat.isPerpendicularTo(yHat))

        XCTAssert(xHat.isPerpendicularTo(-yHat))
        XCTAssert(yHat.isPerpendicularTo(-xHat))
        XCTAssert(xHat.isPerpendicularTo(-zHat))
        XCTAssert(zHat.isPerpendicularTo(-xHat))
        XCTAssert(yHat.isPerpendicularTo(-zHat))
        XCTAssert(zHat.isPerpendicularTo(-yHat))

        XCTAssert(!zHat.isPerpendicularTo(zHat))

    }

    func testNormalizedCrossProduct() {
        XCTAssert(xHat.normalizedCrossProduct(2*yHat) == zHat,"\(xHat.crossProduct(2*yHat))")
        XCTAssert(yHat.normalizedCrossProduct(2*zHat) == xHat)
        XCTAssert(zHat.normalizedCrossProduct(2*xHat) == yHat)
        
    }

    func testGlobalDefinitions() {
        XCTAssert(xHat == SCNVector3(1,0,0))
        XCTAssert(yHat == SCNVector3(0,1,0))
        XCTAssert(zHat == SCNVector3(0,0,1))
        XCTAssert(oHat == SCNVector3(0,0,0))
    }
    
    func testNormalizedDotProduct() {
        XCTAssertEqualWithAccuracy(xHat.normalizedDotProduct(yHat), 0, accuracy: 1e-6)
    }
    
    func testUnitVectorsPerpendicular() {
        XCTAssert(xHat.isPerpendicularTo(yHat))
        XCTAssert(xHat.isPerpendicularTo(zHat))
        XCTAssert(yHat.isPerpendicularTo(zHat))
    }

    func testAddScaledVector() {
        var v1 = SCNVector3(0,1,2)
        let v2 = SCNVector3(3,4,5)
        
        v1.addScaledVector(v2, scale: 2)
        XCTAssert(v1 == SCNVector3(6,9,12))
    }

    func testRandomVector() {

        for _ in 1...1000 {
            let v = SCNVector3.randomVector()
            XCTAssert(v.x >= 0 && v.x <= 1)
            XCTAssert(v.y >= 0 && v.y <= 1)
            XCTAssert(v.z >= 0 && v.z <= 1)
        }
    }

    func testAddVector() {
        let v1 = SCNVector3(0,1,2)
        let v2 = SCNVector3(3,4,5)
        
        XCTAssert(v1+v2 == SCNVector3(3,5,7))
    }

    func testAddVectorInPlace() {
        var v1 = SCNVector3(0,1,2)
        let v2 = SCNVector3(3,4,5)
        v1 += v2
        XCTAssert(v1 == SCNVector3(3,5,7))
    }

    func testSubtractVector() {
        var v1 = SCNVector3(0,1,2)
        let v2 = SCNVector3(3,4,5)
        
        v1 -= v2
        XCTAssert(v1 == SCNVector3(-3,-3,-3))
    }

    func testMultiplyVectorScalar() {
        let v1 = SCNVector3(0,1,2)
        
        XCTAssert(v1*3 == SCNVector3(0,3,6))
    }
    func testDivideVectorScalar() {
        let v1 = SCNVector3(0,1,2)
        
        XCTAssert(v1/3 == SCNVector3(0,1.0/3.0,2.0/3.0))
    }

    func testEqualVector() {
        let v1 = SCNVector3(0,1,2)
        
        XCTAssert(v1 == SCNVector3(0,1,2))
        XCTAssert( !(v1 == SCNVector3(0,1,2.00001)))
    }


}
