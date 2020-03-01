//
//  SceneKitExtensions.swift
//  MonteCarlo3D
//
//  Created by Daniel Côté on 2015-03-24.
//  Copyright (c) 2015 Daniel Côté. All rights reserved.
//

import Foundation
import SceneKit

extension SCNScene {

    func dumpTree() {
        rootNode.dumpNode()
    }
    
    func addLine(vertexList:[SCNVector3]) {
        let vertexSource = SCNGeometrySource(vertices: vertexList, count: vertexList.count)
        
        if vertexList.count == 0 {
            return
        }
        
        var indexList:[Int32] = []
        for i in 0..<vertexList.count-1 {
            indexList.append(Int32(i))
            indexList.append(Int32(i+1))
        }
        let indexData = NSData(bytes: &indexList, length: indexList.count * sizeof(Int32))
        
        let element = SCNGeometryElement(data: indexData, primitiveType: SCNGeometryPrimitiveType.Line,
            primitiveCount: indexList.count, bytesPerIndex: sizeof(Int32))
        
        let lines = SCNGeometry(sources: [vertexSource], elements: [element])
        let cellNode = SCNNode(geometry: lines)
        cellNode.name = "Line"
        
        rootNode.addChildNode(cellNode)
        
    }

}
