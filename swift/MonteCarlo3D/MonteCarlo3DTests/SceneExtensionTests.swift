//
//  SceneExtensionTests.swift
//  MonteCarlo3D
//
//  Created by Daniel Côté on 2016-01-23.
//  Copyright © 2016 Daniel Côté. All rights reserved.
//

import XCTest
import SceneKit

class SceneExtensionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSceneCreation() {
        let scene = SCNScene()
        XCTAssertNotNil(scene)
        
    }

    func testSceneObjectCreation() {
        let scene = SCNScene()
        XCTAssertNotNil(scene)
        
        let objectGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        let objectNode = SCNNode(geometry: objectGeometry)
        objectNode.position=SCNVector3(x: 0, y: 0, z: 0)
        SCNTransaction.begin()
        scene.rootNode.addChildNode(objectNode)
        SCNTransaction.commit()

        let material = scene.rootNode.propertiesAtPosition(SCNVector3(0,0,0))
        XCTAssertNotNil(material)
        XCTAssert(material.index == 1)
        XCTAssert(material.mu_a == 0)
        XCTAssert(material.mu_s == 0)
    }


}
