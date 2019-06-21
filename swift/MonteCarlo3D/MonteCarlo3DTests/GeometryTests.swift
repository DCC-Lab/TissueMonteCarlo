//
//  GeometryTests.swift
//  MonteCarlo3D
//
//  Created by Daniel Côté on 2016-02-25.
//  Copyright © 2016 Daniel Côté. All rights reserved.
//

import XCTest
import SceneKit

class GeometryTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPrimitive() {
        let scene = SCNScene()
        XCTAssertNotNil(scene)
        
        let objectGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        let objectNode = SCNNode(geometry: objectGeometry)
        objectNode.position=SCNVector3(x: 0, y: 0, z: 0)
        SCNTransaction.begin()
        scene.rootNode.addChildNode(objectNode)
        SCNTransaction.commit()
        
        let primitives = objectGeometry.triangularSurfacePrimitives()
        XCTAssert(primitives.count == 6 * 2)
        for p in primitives {
            XCTAssert(p.count == 3)
            XCTAssertEqualWithAccuracy(abs(p[0].x), 0.5, accuracy:1e-6)
            XCTAssertEqualWithAccuracy(abs(p[0].y), 0.5, accuracy:1e-6)
            XCTAssertEqualWithAccuracy(abs(p[0].z), 0.5, accuracy:1e-6)
            XCTAssertEqualWithAccuracy(abs(p[1].x), 0.5, accuracy:1e-6)
            XCTAssertEqualWithAccuracy(abs(p[1].y), 0.5, accuracy:1e-6)
            XCTAssertEqualWithAccuracy(abs(p[1].z), 0.5, accuracy:1e-6)
            XCTAssertEqualWithAccuracy(abs(p[2].x), 0.5, accuracy:1e-6)
            XCTAssertEqualWithAccuracy(abs(p[2].y), 0.5, accuracy:1e-6)
            XCTAssertEqualWithAccuracy(abs(p[2].z), 0.5, accuracy:1e-6)
        }
    }

    func testPrimitiveOutOfRange() {
        let scene = SCNScene()
        XCTAssertNotNil(scene)
        
        let objectGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        let objectNode = SCNNode(geometry: objectGeometry)
        objectNode.position=SCNVector3(x: 0, y: 0, z: 0)
        SCNTransaction.begin()
        scene.rootNode.addChildNode(objectNode)
        SCNTransaction.commit()

        XCTAssertNil(objectGeometry.triangularSurfacePrimitiveAtIndex(0, primitiveIndex: 1000))
        XCTAssertNil(objectGeometry.triangularSurfacePrimitiveAtIndex(1000, primitiveIndex: 0))
        XCTAssertNil(objectGeometry.triangularSurfacePrimitiveAtIndex(1000, primitiveIndex: 1000))
        XCTAssertNotNil(objectGeometry.triangularSurfacePrimitiveAtIndex(0, primitiveIndex: 0))
        
    }
    
    func testAllTriangularPrimitives() {
        let scene = SCNScene()
        XCTAssertNotNil(scene)
        
        let objectGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        let objectNode = SCNNode(geometry: objectGeometry)
        objectNode.position=SCNVector3(x: 0, y: 0, z: 0)
        SCNTransaction.begin()
        scene.rootNode.addChildNode(objectNode)
        SCNTransaction.commit()
        
        let allTriangles = objectGeometry.triangularSurfacePrimitives()
        XCTAssertNotNil(allTriangles)
        XCTAssert(allTriangles.count == 6 * 2)
    }
    
    func testMovedPrimitive() {
        let scene = SCNScene()
        XCTAssertNotNil(scene)
        
        let objectGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        let objectNode = SCNNode(geometry: objectGeometry)
        objectNode.position=SCNVector3(x: 1, y: 1, z: 1)
        SCNTransaction.begin()
        scene.rootNode.addChildNode(objectNode)
        SCNTransaction.commit()
        
        // local primitives don't change.
        
        let primitives = objectGeometry.triangularSurfacePrimitives()
        XCTAssert(primitives.count == 6 * 2)
        for p in primitives {
            XCTAssert(p.count == 3)
            XCTAssertEqualWithAccuracy(abs(p[0].x), 0.5, accuracy:1e-6)
            XCTAssertEqualWithAccuracy(abs(p[0].y), 0.5, accuracy:1e-6)
            XCTAssertEqualWithAccuracy(abs(p[0].z), 0.5, accuracy:1e-6)
            XCTAssertEqualWithAccuracy(abs(p[1].x), 0.5, accuracy:1e-6)
            XCTAssertEqualWithAccuracy(abs(p[1].y), 0.5, accuracy:1e-6)
            XCTAssertEqualWithAccuracy(abs(p[1].z), 0.5, accuracy:1e-6)
            XCTAssertEqualWithAccuracy(abs(p[2].x), 0.5, accuracy:1e-6)
            XCTAssertEqualWithAccuracy(abs(p[2].y), 0.5, accuracy:1e-6)
            XCTAssertEqualWithAccuracy(abs(p[2].z), 0.5, accuracy:1e-6)
        }
    }

}
