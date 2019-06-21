//
//  KDTNodeTests.swift
//  MonteCarlo3D
//
//  Created by Daniel Côté on 2016-03-02.
//  Copyright © 2016 Daniel Côté. All rights reserved.
//

import XCTest
import SceneKit

class KDTNodeTests: XCTestCase {
    var scene:SCNScene?
    
    override func setUp() {
        super.setUp()

        scene = SCNScene()
        XCTAssertNotNil(scene)
        
        let objectGeometry = SCNSphere(radius: 1)
        let objectNode = SCNNode(geometry: objectGeometry)
        objectNode.name = "Sphere"
        objectNode.position=SCNVector3(x: 0, y: 0, z: 0)
        SCNTransaction.begin()
        scene!.rootNode.addChildNode(objectNode)
        SCNTransaction.commit()

        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testKDTNodeInit() {
        let sphereNode = scene!.rootNode.childNodeWithName("Sphere", recursively: true)
  
        
        let all = sphereNode?.allKDTriangles()
        
        XCTAssertNotNil(all)
        XCTAssert(all!.count != 0)
        
    }

    func testBuildKDTree() {
        let sphereNode = scene!.rootNode.childNodeWithName("Sphere", recursively: true)
        
        let all = sphereNode?.allKDTriangles()
        XCTAssertNotNil(all)
        XCTAssert(all!.count != 0)
        let kdRoot = KDTNode()
        kdRoot.buildTree(Axis.X, triangles: all!)
        XCTAssert(kdRoot.leftNode != nil)
        XCTAssert(kdRoot.rightNode != nil)
    }

    func testTraverseKDTree() {
        let defaultOptions:[String:AnyObject] = [SCNHitTestBackFaceCullingKey:false, SCNHitTestSortResultsKey:true, SCNHitTestIgnoreHiddenNodesKey:false]

        let sphereNode = scene!.rootNode.childNodeWithName("Sphere", recursively: true)
        
        let all = sphereNode?.allKDTriangles()
        XCTAssertNotNil(all)
        XCTAssert(all!.count != 0)
        let kdRoot = KDTNode()
        kdRoot.buildTree(Axis.X, triangles: all!)
        XCTAssert(kdRoot.leftNode != nil)
        XCTAssert(kdRoot.rightNode != nil)

        for _ in 0...1000 {
            var kd_distance:CGFloat? = nil
            var apple_distance:CGFloat? = nil
            
            let origin = oHat //SCNVector3.randomVector()
            var direction = 2*SCNVector3.randomVector()
            try! direction.normalize()
            
            let tuple = kdRoot.hitTestRecursiveWithSegmentFromPoint(origin, toPoint: origin+direction)
            if tuple != nil {
                let (a,_) = tuple!
                kd_distance = a
            }
            
            var hitList = sphereNode?.hitTestWithSegmentFromPoint(origin, toPoint: origin+direction, options: defaultOptions)
            
            if hitList!.count > 0 {
                let hit = hitList![0]
                
                apple_distance = hit.worldCoordinates.abs()

            }
            
            if kd_distance != nil && apple_distance != nil {
                XCTAssertEqualWithAccuracy(kd_distance!, apple_distance!, accuracy: CGFloat(0.01))
            }
            
//            XCTAssert(kd_prim == apple_prim)
            
        }

    }
    
    func testTraverseKDTreePerformance() {
        let sphereNode = scene!.rootNode.childNodeWithName("Sphere", recursively: true)
        
        let all = sphereNode?.allKDTriangles()
        XCTAssertNotNil(all)
        XCTAssert(all!.count != 0)
        let kdRoot = KDTNode()
        kdRoot.buildTree(Axis.X, triangles: all!)
        XCTAssert(kdRoot.leftNode != nil)
        XCTAssert(kdRoot.rightNode != nil)
        
        self.measureBlock {
            for _ in 0...1000 {
                let _ = kdRoot.hitTestRecursiveWithSegmentFromPoint(SCNVector3.randomVector(), toPoint: SCNVector3.randomVector())
                
            }
        }
    }

    func testTraverseIterativeKDTreePerformance() {
        let sphereNode = scene!.rootNode.childNodeWithName("Sphere", recursively: true)
        
        let all = sphereNode?.allKDTriangles()
        XCTAssertNotNil(all)
        XCTAssert(all!.count != 0)
        let kdRoot = KDTNode()
        kdRoot.buildTree(Axis.X, triangles: all!)
        XCTAssert(kdRoot.leftNode != nil)
        XCTAssert(kdRoot.rightNode != nil)
        
        self.measureBlock {
            for _ in 0...1000 {
                let _ = kdRoot.hitTestWithSegmentFromPoint(SCNVector3.randomVector(), toPoint: SCNVector3.randomVector(), closestOnly: true)
                
            }
        }
    }

    func testIntersectWithSegmentPerformance() {
        let sphereNode = scene!.rootNode.childNodeWithName("Sphere", recursively: true)
        let defaultOptions:[String:AnyObject] = [SCNHitTestBackFaceCullingKey:false, SCNHitTestSortResultsKey:true, SCNHitTestIgnoreHiddenNodesKey:false]
        
        self.measureBlock {
            for _ in 0...1000 {
                var _ = sphereNode?.hitTestWithSegmentFromPoint(SCNVector3.randomVector(), toPoint: SCNVector3.randomVector(), options: defaultOptions)
            }
        }
    }

    func testIntersectWithRay() {
        let a = SCNVector3(1,0,0)
        let b = SCNVector3(1,1,0)
        let c = SCNVector3(1,1,1)
        let triangle = KDTriangle(vertices:[a,b,c])
        
        var t = triangle!.intersectWithRay(fromPoint:oHat, toPoint: oHat + 2*xHat)
        XCTAssertNotNil(t)
        XCTAssertEqualWithAccuracy(CGFloat(0.5), t!, accuracy: 0.01)

        t = triangle!.intersectWithRay(fromPoint:oHat, toPoint: oHat +  xHat)
        XCTAssertNotNil(t)
        XCTAssertEqualWithAccuracy(CGFloat(1.0), t!, accuracy: 0.01)

        // toot short
        t = triangle!.intersectWithRay(fromPoint:oHat, toPoint: oHat +  0.9*xHat)
        XCTAssertNil(t)
        
        // too much on the side
        t = triangle!.intersectWithRay(fromPoint:SCNVector3(0,-0.1,0), toPoint: SCNVector3(0,-0.1,0) + xHat)
        XCTAssertNil(t)

        // too high
        t = triangle!.intersectWithRay(fromPoint:SCNVector3(1,1,0), toPoint: SCNVector3(1,1,0) + xHat)
        XCTAssertNil(t)

        // wrong direction
        t = triangle!.intersectWithRay(fromPoint:oHat, toPoint: oHat - xHat)
        XCTAssertNil(t)

    }

    func testIntersectCubeTrianglesWithRayKDTree() {
        let cube = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let trianglesSurfacePrimitives = cube.triangularSurfacePrimitives()
        
        var kdPrimitives = [KDTriangle]()
        for triangle in trianglesSurfacePrimitives {
            kdPrimitives.append(KDTriangle(vertices: triangle)!)
        }
        
        let kdRoot = KDTNode()
        kdRoot.buildTree(Axis.X, triangles: kdPrimitives)
        
        let tuple = kdRoot.hitTestRecursiveWithSegmentFromPoint(oHat, toPoint: oHat + xHat)
        if tuple != nil {
            var (kdt,kdtriangle) = tuple!
            XCTAssertNotNil(kdt)
            XCTAssertEqualWithAccuracy(CGFloat(0.5), kdt, accuracy: 0.01)
        } else {
            XCTFail()
        }
        
        
//        t = triangle!.intersectWithRay(fromPoint:oHat, toPoint: oHat +  xHat)
//        XCTAssertNotNil(t)
//        XCTAssertEqualWithAccuracy(CGFloat(1.0), t!, accuracy: 0.01)
//        
//        // toot short
//        t = triangle!.intersectWithRay(fromPoint:oHat, toPoint: oHat +  0.9*xHat)
//        XCTAssertNil(t)
//        
//        // too much on the side
//        t = triangle!.intersectWithRay(fromPoint:SCNVector3(0,-0.1,0), toPoint: SCNVector3(0,-0.1,0) + xHat)
//        XCTAssertNil(t)
//        
//        // too high
//        t = triangle!.intersectWithRay(fromPoint:SCNVector3(1,1,0), toPoint: SCNVector3(1,1,0) + xHat)
//        XCTAssertNil(t)
//        
//        // wrong direction
//        t = triangle!.intersectWithRay(fromPoint:oHat, toPoint: oHat - xHat)
//        XCTAssertNil(t)

    }

    func testKDTreeIntersectRayWithSphere() {
        let sphereNode = scene!.rootNode.childNodeWithName("Sphere", recursively: true)
        
        let kdPrimitives = sphereNode?.allKDTriangles()
        XCTAssertNotNil(kdPrimitives)
        XCTAssert(kdPrimitives!.count != 0)
        
        let kdRoot = KDTNode()
        kdRoot.buildTree(Axis.X, triangles: kdPrimitives!)
        
        for _ in 0...1000 {
            var direction = SCNVector3.randomVector()
            try! direction.normalize()
            
            let tuple = kdRoot.hitTestRecursiveWithSegmentFromPoint(oHat, toPoint: oHat + direction)
            if tuple != nil {
                var (kdt,kdtriangle) = tuple!
                XCTAssertNotNil(kdt)
                XCTAssertEqualWithAccuracy(Float(kdt), 1, accuracy: 0.03)
            } else {
                XCTFail()
            }
        }
    }

    func testIterativeKDTreeIntersectRayWithSphere() {
        let sphereNode = scene!.rootNode.childNodeWithName("Sphere", recursively: true)
        
        let kdPrimitives = sphereNode?.allKDTriangles()
        XCTAssertNotNil(kdPrimitives)
        XCTAssert(kdPrimitives!.count != 0)
        
        let kdRoot = KDTNode()
        kdRoot.buildTree(Axis.X, triangles: kdPrimitives!)
        
        for _ in 0...1000 {
            var direction = SCNVector3.randomVector()
            try! direction.normalize()
            
            let tuple = kdRoot.hitTestClosestOnlyKDTreeWithSegmentFromPoint(oHat, toPoint: oHat + direction)
            if tuple != nil {
                var (kdt,kdtriangle) = tuple!
                XCTAssertNotNil(kdt)
                XCTAssertEqualWithAccuracy(Float(kdt), 1, accuracy: 0.03)
            } else {
                XCTFail()
            }
        }
    }

    func testIntersectRayWithSphere() {
        let sphereNode = scene!.rootNode.childNodeWithName("Sphere", recursively: true)
        
        let all = sphereNode?.allKDTriangles()
        XCTAssertNotNil(all)
        XCTAssert(all!.count != 0)
        
        for _ in 0...1000 {
            var direction = SCNVector3.randomVector()
            try! direction.normalize()
            
            for triangle in all! {
                let t = triangle.intersectWithRay(fromPoint: oHat, toPoint: oHat + direction)
                
                if t != nil  {
                    XCTAssertEqualWithAccuracy(Float(t!), 1, accuracy: 0.03)
                }
            }
        }
    }

    func testIntersectRayWithAllElementInScene() {
        let sphereNode = scene!.rootNode.childNodeWithName("Sphere", recursively: true)
        
        let all = sphereNode?.allKDTriangles()
        XCTAssertNotNil(all)
        XCTAssert(all!.count != 0)
        
        for triangle in all! {
            for _ in 0...40 {
                if triangle.vertices != nil {
                    let a = triangle.vertices![0]
                    let b = triangle.vertices![1]
                    let c = triangle.vertices![2]
                    
                    let v1 = b-a
                    let v2 = c-a
                    
                    let origin = SCNVector3.randomVector()
                    let direction = 2 * (a - origin + 0.5 * v1 + 0.5 * v2 )
                    
                    let t = triangle.intersectWithRay(fromPoint: origin, toPoint: origin+direction)
                    
                    if t != nil  {
                        XCTAssertEqualWithAccuracy(Float(t!), 0.5, accuracy: 0.01)
                    } else {
                        XCTFail()
                    }
                }
            }
        }
    }

//    func testPointInLargeAndSmallCubes() {
//        let objectGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
//        let smallCube = SCNNode(geometry: objectGeometry)
//        smallCube.name = "SmallCube"
//        smallCube.position = SCNVector3(x: 0, y: 0, z: 0)
//        
//        SCNTransaction.begin()
//        var scene = SCNScene()
//        
//        scene.rootNode.addChildNode(smallCube)
//        SCNTransaction.commit()
//        
//        let objectGeometry2 = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0)
//        let largeCube = SCNNode(geometry: objectGeometry2)
//        largeCube.position = SCNVector3(x: 0, y: 0, z: 0)
//        largeCube.name = "LargeCube"
//        
//        SCNTransaction.begin()
//        scene.rootNode.addChildNode(largeCube)
//        SCNTransaction.commit()
//        
//        for _ in 1...1000 {
//            let x = randomFloat()*5-2
//            let y = randomFloat()*5-2
//            let z = randomFloat()*5-2
//            
//            var isInsideSmallCube = false
//            if abs(x) <= 0.5 && abs(y) <= 0.5 && abs(z) <= 0.5 {
//                isInsideSmallCube = true
//            }
//            
//            var isInsideLargeCube = false
//            if !isInsideSmallCube && abs(x) <= 1 && abs(y) <= 1 && abs(z) <= 1 {
//                isInsideLargeCube = true
//            }
//            
//            let v = SCNVector3(x,y,z)
//            
//            let node = scene.rootNode.nodeContainingPoint(v)
//            
//            if isInsideSmallCube && node != smallCube {
//                XCTFail("Vector \(v) with norm \(v.norm()) not in small cube")
//            }
//            if isInsideLargeCube && node != largeCube {
//                XCTFail("Vector \(v) with norm \(v.norm()) not in large cube")
//            }
//            if !isInsideSmallCube && !isInsideLargeCube && node != nil {
//                scene.rootNode.nodeContainingPoint(v)
//                XCTFail("Vector \(v) with norm \(v.norm()) not in world")
//            }
//        }
//        
//    }

    
    func testMeasureCost() {
        let sphereNode = scene!.rootNode.childNodeWithName("Sphere", recursively: true)

        let all = sphereNode?.allKDTriangles()
        XCTAssertNotNil(all)
        XCTAssert(all!.count != 0)

        
        let primitive = all![0]
        self.measureBlock {
            primitive.intersectWithRay(fromPoint:SCNVector3(0,0,0), toPoint: SCNVector3.randomVector())
        }
        
    }

}
