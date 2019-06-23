//
//  mcTests.swift
//  mcTests
//
//  Created by Daniel Côté on 2019-06-21.
//  Copyright © 2019 DCCLab. All rights reserved.
//

import XCTest
import SceneKit
import simd

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
//
//    func testFloat3Operations() {
//        var v = float3(1,2,3)
//        var u = float3(1,2,3)
//        self.measure {
//            for i in 0...100000 {
//                var w = u + v
//                XCTAssert(w==float3(2,4,6))
//                w = v + v - 5*u
//                XCTAssert(w==float3(-3,-6,-9))
//                var n = try! w.normalize()
//                var m = w.abs()
//            }
//        }
//    }
//
//    func testSCN3VectorOperations() {
//        var v = SCNVector3(1,2,3)
//        var u = SCNVector3(1,2,3)
//        self.measure {
//            for i in 0...100000 {
//                var w = u + v
//                XCTAssert(w==SCNVector3(2,4,6))
//                w = v + v - 5*u
//                XCTAssert(w==SCNVector3(-3,-6,-9))
//                var n = try! w.normalize()
//                var m = w.abs()
//            }
//        }
//    }
//
//    func testVectorizedAbsFloat3() {
//        let array = [float3](repeating: float3(1,2,3), count: 100000)
//        self.measure {
//            array.abs()
//        }
//    }
//
//    func testNonVectorizedAbsFloat3() {
//        let array = [float3](repeating: float3(1,2,3), count: 100000)
//        self.measure {
//            for v in array {
//                v.abs()
//            }
//        }
//    }
//
//    func testVectorizedNormCrossFloat3() {
//        let u = [float3](repeating: float3(1,2,3), count: 1000000)
//        let v = [float3](repeating: float3(3,2,1), count: 1000000)
//        self.measure {
//            u.normalizedCrossProduct(v)
//        }
//    }
//
//    func testNonVectorizedNormCrossFloat3() {
//        let us = [float3](repeating: float3(1,2,3), count: 1000000)
//        let vs = [float3](repeating: float3(3,2,1), count: 1000000)
//        self.measure {
//            for (i,u) in vs.enumerated() {
//                u.normalizedCrossProduct(vs[i])
//            }
//        }
//    }
//
//    func testVectorizedOrientedAnglesFloat3() {
//        let u = [float3](repeating: float3(1,2,3), count: 1000000)
//        let v = [float3](repeating: float3(3,2,1), count: 1000000)
//        let w = [float3](repeating: float3(4,5,6), count: 1000000)
//        self.measure {
//            u.orientedAngleWith(v, aroundAxis: w)
//        }
//    }
//
    func testNonVectorizedOrientedAnglesFloat4() {
        let us = [float4](repeating: float4(1,2,3,1), count: 1000000)
        let vs = [float4](repeating: float4(3,2,1,1), count: 1000000)
        let ws = [float4](repeating: float4(4,5,6,1), count: 1000000)
        self.measure {
            for (i,u) in us.enumerated() {
                u.orientedAngleWith(vs[i], aroundAxis: ws[i])
            }
        }
    }

    func testVectorizedOrientedAnglesFloat4() {
        let u = [float4](repeating: float4(1,2,3,1), count: 1000000)
        let v = [float4](repeating: float4(3,2,1,1), count: 1000000)
        let w = [float4](repeating: float4(4,5,6,1), count: 1000000)
        self.measure {
            u.orientedAngleWith(v, aroundAxis: w)
        }
    }

}
