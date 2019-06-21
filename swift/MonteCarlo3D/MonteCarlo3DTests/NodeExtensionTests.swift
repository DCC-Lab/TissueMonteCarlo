//
//  NodeExtensionTests.swift
//  MonteCarlo3D
//
//  Created by Daniel Côté on 2016-02-24.
//  Copyright © 2016 Daniel Côté. All rights reserved.
//

import XCTest
import SceneKit

class NodeExtensionTests: XCTestCase {
    var scene:SCNScene!
    
    
    override func setUp() {
        super.setUp()

        scene = SCNScene()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPointInSphere() {
        let objectGeometry = SCNSphere(radius: 1)
        let objectNode = SCNNode(geometry: objectGeometry)
        objectNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        SCNTransaction.begin()
        scene.rootNode.addChildNode(objectNode)
        SCNTransaction.commit()
        
        for _ in 1...10000 {
            let x = randomFloat()*2-0.5
            let y = randomFloat()*2-0.5
            let z = randomFloat()*2-0.5
            
            let v = SCNVector3(x,y,z)

            var isInside = false
            if v.norm() < 0.978 {
                isInside = true
            }
            
            let node = scene.rootNode.nodeContainingPoint(v)
            
            if isInside && node != objectNode {
                scene.rootNode.nodeContainingPoint(v)
                
                XCTFail("Vector \(v) with norm \(v.norm()) not in sphere")
            }
            if !isInside && node != nil && v.norm() > 1.01 {
                scene.rootNode.nodeContainingPoint(v)
                
                XCTFail("Vector \(v) with norm \(v.norm()) not in world")
            }

        }


    }

    func testPerformancePointInNode0() {
        let objectGeometry = SCNSphere(radius: 1)
        
        let objectNode = SCNNode(geometry: objectGeometry)
        objectNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        objectNode.name = "Sphere"
        SCNTransaction.begin()
        scene.rootNode.addChildNode(objectNode)
        SCNTransaction.commit()
        
        self.measureBlock {
            for _ in 1...100 {
                let x = self.randomFloat()*2-0.5
                let y = self.randomFloat()*2-0.5
                let z = self.randomFloat()*2-0.5
                
                let v = SCNVector3(x,y,z)
                
                let _ = self.scene.rootNode.nodeContainingPoint(v)
            }
        }
        
        objectNode.removeFromParentNode()
        
    }

    func testPerformancePointInNode1() {
        let objectGeometry = SCNSphere(radius: 1)
        objectGeometry.segmentCount <<= 1
        
        let objectNode = SCNNode(geometry: objectGeometry)
        objectNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        objectNode.name = "Sphere"
        SCNTransaction.begin()
        scene.rootNode.addChildNode(objectNode)
        SCNTransaction.commit()
        
        self.measureBlock {
            for _ in 1...100 {
                let x = self.randomFloat()*2-0.5
                let y = self.randomFloat()*2-0.5
                let z = self.randomFloat()*2-0.5
                
                let v = SCNVector3(x,y,z)
                
                let _ = self.scene.rootNode.nodeContainingPoint(v)
            }
        }
        
        objectNode.removeFromParentNode()
        
    }

    func testPerformancePointInNode2() {
        let objectGeometry = SCNSphere(radius: 1)
        objectGeometry.segmentCount <<= 2
        
        let objectNode = SCNNode(geometry: objectGeometry)
        objectNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        objectNode.name = "Sphere"
        SCNTransaction.begin()
        scene.rootNode.addChildNode(objectNode)
        SCNTransaction.commit()
        
        self.measureBlock {
            for _ in 1...100 {
                let x = self.randomFloat()*2-0.5
                let y = self.randomFloat()*2-0.5
                let z = self.randomFloat()*2-0.5
                
                let v = SCNVector3(x,y,z)
                
                let _ = self.scene.rootNode.nodeContainingPoint(v)
            }
        }
        
        objectNode.removeFromParentNode()
        
    }

    func testPerformancePointInNode3() {
        let objectGeometry = SCNSphere(radius: 1)
        objectGeometry.segmentCount <<= 3
        
        let objectNode = SCNNode(geometry: objectGeometry)
        objectNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        objectNode.name = "Sphere"
        SCNTransaction.begin()
        scene.rootNode.addChildNode(objectNode)
        SCNTransaction.commit()
        
        self.measureBlock {
            for _ in 1...100 {
                let x = self.randomFloat()*2-0.5
                let y = self.randomFloat()*2-0.5
                let z = self.randomFloat()*2-0.5
                
                let v = SCNVector3(x,y,z)
                
                let _ = self.scene.rootNode.nodeContainingPoint(v)
            }
        }
        
        objectNode.removeFromParentNode()
        
    }

    func randomFloat() -> Float {
        return Float(rand())/Float(RAND_MAX)
    }
    
    func testPointInCube() {
        let objectGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let objectNode = SCNNode(geometry: objectGeometry)
        objectNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        SCNTransaction.begin()
        scene.rootNode.addChildNode(objectNode)
        SCNTransaction.commit()
        
        for var r:CGFloat = 0.1; r <= 0.99; r += 0.1 {
            for _ in 1...1000 {
                let x = randomFloat()-0.5
                let y = randomFloat()-0.5
                let z = randomFloat()-0.5
                
                var v = SCNVector3(x,y,z)
                v *= r
                
                let node = scene.rootNode.nodeContainingPoint(v)
                
                if node != objectNode {
                    XCTFail("Vector \(v) with norm \(v.norm()) not in sphere")
                }
            }
        }

        for var r:CGFloat = 1.0001; r <= 2; r += 0.1 {
            for _ in 1...1000 {
                let x = randomFloat()+0.5
                let y = randomFloat()+0.5
                let z = randomFloat()+0.5
                
                var v = SCNVector3(x,y,z)
                v *= r
                
                let node = scene.rootNode.nodeContainingPoint(v)
                
                if node == objectNode {
                    XCTFail("Vector \(v) in cube")
                }
            }
        }

    }

    func testPointInLargeAndSmallCubes() {
        let objectGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let smallCube = SCNNode(geometry: objectGeometry)
        smallCube.name = "SmallCube"
        smallCube.position = SCNVector3(x: 0, y: 0, z: 0)
        
        SCNTransaction.begin()
        scene.rootNode.addChildNode(smallCube)
        SCNTransaction.commit()

        let objectGeometry2 = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0)
        let largeCube = SCNNode(geometry: objectGeometry2)
        largeCube.position = SCNVector3(x: 0, y: 0, z: 0)
        largeCube.name = "LargeCube"
        
        SCNTransaction.begin()
        scene.rootNode.addChildNode(largeCube)
        SCNTransaction.commit()

        for _ in 1...1000 {
            let x = randomFloat()*5-2
            let y = randomFloat()*5-2
            let z = randomFloat()*5-2
            
            var isInsideSmallCube = false
            if abs(x) <= 0.5 && abs(y) <= 0.5 && abs(z) <= 0.5 {
                isInsideSmallCube = true
            }

            var isInsideLargeCube = false
            if !isInsideSmallCube && abs(x) <= 1 && abs(y) <= 1 && abs(z) <= 1 {
                isInsideLargeCube = true
            }
            
            let v = SCNVector3(x,y,z)
            
            let node = scene.rootNode.nodeContainingPoint(v)
            
            if isInsideSmallCube && node != smallCube {
                XCTFail("Vector \(v) with norm \(v.norm()) not in small cube")
            }
            if isInsideLargeCube && node != largeCube {
                XCTFail("Vector \(v) with norm \(v.norm()) not in large cube")
            }
            if !isInsideSmallCube && !isInsideLargeCube && node != nil {
                scene.rootNode.nodeContainingPoint(v)
                XCTFail("Vector \(v) with norm \(v.norm()) not in world")
            }
        }
        
    }

    func testLocalTriangles() {
        let scene = SCNScene()
        XCTAssertNotNil(scene)
        
        let objectGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        let objectNode = SCNNode(geometry: objectGeometry)
        objectNode.position=SCNVector3(x: 1, y: 1, z: 1) // local primitive don't change
        SCNTransaction.begin()
        scene.rootNode.addChildNode(objectNode)
        SCNTransaction.commit()
        
        let triangles = objectNode.triangularSurfacePrimitives(convertToWorldCoordinates: false)
        XCTAssert(triangles.count == 6 * 2)
        for p in triangles {
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

    func testWorldTriangles() {
        let scene = SCNScene()
        XCTAssertNotNil(scene)
        
        let objectGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        let objectNode = SCNNode(geometry: objectGeometry)
        objectNode.position=SCNVector3(x: 1, y: 1, z: 1)
        SCNTransaction.begin()
        scene.rootNode.addChildNode(objectNode)
        SCNTransaction.commit()
        
        let triangles = objectNode.triangularSurfacePrimitives(convertToWorldCoordinates: true)
        XCTAssert(triangles.count == 6 * 2)
        for p in triangles {
            XCTAssert(p.count == 3)
            XCTAssertEqualWithAccuracy(abs(p[0].x-1), 0.5, accuracy:1e-6)
            XCTAssertEqualWithAccuracy(abs(p[0].y-1), 0.5, accuracy:1e-6)
            XCTAssertEqualWithAccuracy(abs(p[0].z-1), 0.5, accuracy:1e-6)
            XCTAssertEqualWithAccuracy(abs(p[1].x-1), 0.5, accuracy:1e-6)
            XCTAssertEqualWithAccuracy(abs(p[1].y-1), 0.5, accuracy:1e-6)
            XCTAssertEqualWithAccuracy(abs(p[1].z-1), 0.5, accuracy:1e-6)
            XCTAssertEqualWithAccuracy(abs(p[2].x-1), 0.5, accuracy:1e-6)
            XCTAssertEqualWithAccuracy(abs(p[2].y-1), 0.5, accuracy:1e-6)
            XCTAssertEqualWithAccuracy(abs(p[2].z-1), 0.5, accuracy:1e-6)
        }
    }

}
