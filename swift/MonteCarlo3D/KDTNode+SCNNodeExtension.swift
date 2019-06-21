//
//  KDTNode+SCNNodeExtension.swift
//  MonteCarlo3D
//
//  Created by Daniel Côté on 2016-03-09.
//  Copyright © 2016 Daniel Côté. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode {
    func fastHitTestWithSegmentFromPoint(fromPoint:SCNVector3, toPoint:SCNVector3, options:[String:AnyObject] ) -> [SCNHitTestResult]{

        let kdt:SCNNode? = childNodeWithName("KDTree", recursively: false)
            
        if kdt == nil {
            let rootNode = KDTNode()
            
            let nodesWithGeometry = self.childNodesPassingTest({ (child:SCNNode, bool:UnsafeMutablePointer<ObjCBool>) -> Bool in
                if child.geometry != nil {
                    return true
                } else {
                    return false
                }
            })
            
            var allTriangles = [KDTriangle]()
            for node in nodesWithGeometry {
                allTriangles.appendContentsOf(node.allKDTriangles())
            }
            rootNode.buildTree(.X, triangles: allTriangles )
        }
    }
    
}