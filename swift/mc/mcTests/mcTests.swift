//
//  mcTests.swift
//  mcTests
//
//  Created by Daniel Côté on 2019-06-21.
//  Copyright © 2019 DCCLab. All rights reserved.
//

import XCTest
import SceneKit
@testable import mc

class mcTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func myRandom() -> CGFloat {
        return CGFloat(arc4random_uniform(30000))/30000
    }

    func testInitVector() {
        var _ = Vector3D()
    }

    func testInitVectorWithArg() {
        var _ = Vector3D(1,2,3)
    }

    func testInitVectorWithGlobalVecrtors() {
        var _ = xHat
        var _ = yHat
        var _ = zHat
    }

    func testNorm() {
        var v = Vector3D(1,0,0)
        XCTAssert(v.norm() == 1)
        
    }

//    func testRotation() {
//        var vectorA = xHat
////        var vectorB = yHat
//
//        vectorA.rotateAroundZ(3.14)
////        vectorB.rotateAroundAxis(zHat, byAngle: π/2)
////        XCTAssert(vectorA == vectorB, "Rotation around Z failed")
////        XCTAssert(vectorA == yHat, "Rotation around Z failed")
//    }
    
    func testFloat3Operations() {
        var v = float3(1,2,3)
        var u = float3(1,2,3)
        self.measure {
            for i in 0...100000 {
                var w = u + v
                XCTAssert(w==float3(2,4,6))
                w = v + v - 5*u
                XCTAssert(w==float3(-3,-6,-9))
                var n = try! w.normalize()
                var m = w.abs()
            }
        }
    }

    func testSCN3VectorOperations() {
        var v = SCNVector3(1,2,3)
        var u = SCNVector3(1,2,3)
        self.measure {
            for i in 0...100000 {
                var w = u + v
                XCTAssert(w==SCNVector3(2,4,6))
                w = v + v - 5*u
                XCTAssert(w==SCNVector3(-3,-6,-9))
                var n = try! w.normalize()
                var m = w.abs()
            }
        }
    }

}
