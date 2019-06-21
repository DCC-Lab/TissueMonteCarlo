//
//  SCNNodeExtension.swift
//  MonteCarlo3D
//
//  Created by Daniel Côté on 2016-02-16.
//  Copyright © 2016 Daniel Côté. All rights reserved.
//

import Foundation
import SceneKit

let air = BulkHenyeyGreenstein(mu_s: 0, mu_a: 0, index: 1, g:0)

extension SCNNode {
    func dumpNode(level:Int=0) {
        var spacing = ""
        for _ in 0...level {
            spacing += "\t"
        }
        
        if name != nil {
            print(spacing, name!)
            print(spacing, position)
            print(spacing, transform)
            self.geometry?.dump(prefix:spacing+"\t")
        } else {
            print(spacing, self)
            print(spacing, position)
            print(spacing, transform)
        }
        for node in childNodes {
            node.dumpNode(level: level+1)
        }
    }

    func dumpAllPrimitives() {
        if geometry != nil {
            for i in 0..<geometry!.elementCount {
                let element = geometry!.element(at: i)
                
                if element.primitiveType == SCNGeometryPrimitiveType.triangles {
                    for j in 0..<element.primitiveCount {
                        print( geometry?.triangularSurfacePrimitiveAtIndex(geometryIndex: i, primitiveIndex: j)!,"\n")
                    }
                }
            }
        }
    }

    func triangularSurfacePrimitives(convertToWorldCoordinates world:Bool) -> [[SCNVector3]] {
        var primitives = [[SCNVector3]]()
        if geometry != nil {
            
            for i in 0..<geometry!.elementCount {
                let element = geometry!.element(at: i)
                
                if element.primitiveType == SCNGeometryPrimitiveType.triangles {
                    for j in 0..<element.primitiveCount {
                        let primitive = geometry?.triangularSurfacePrimitiveAtIndex(geometryIndex: i, primitiveIndex: j)
                        
                        if primitive != nil {
                            if world {
                                primitives.append( convertVerticesToWorldCoordinates(vertices: primitive!) )
                            } else {
                                primitives.append( primitive! )
                            }
                        }
                    }
                }
            }
        }
        return primitives
    }

    func convertVerticesToWorldCoordinates(vertices:[SCNVector3]) -> [SCNVector3] {
        var worldVertices = [SCNVector3]()
        
        for vertex in vertices {
            let worldVertex = convertPosition(vertex, to: nil)
            worldVertices.append(worldVertex)
        }
        
        return worldVertices
    }
    
    func nodeContainingPoint(thePoint:SCNVector3) -> SCNNode? {
        let farAwayPoint = SCNVector3(0,100,0)
        let hitList = self.fastHitTestWithSegmentFromPoint(fromPoint:thePoint,
            toPoint: farAwayPoint,
            options: [SCNHitTestBackFaceCullingKey.rawValue:false, SCNHitTestSortResultsKey:true, SCNHitTestIgnoreHiddenNodesKey:false])
        
        var distinctHits = [SCNHitTestResult]()
        for hit in hitList {
            var isIdenticalToOther = false
            for acceptedHit in distinctHits {
                if hit.node == acceptedHit.node && (hit.worldCoordinates - acceptedHit.worldCoordinates).abs() < 1e-6 {
                    isIdenticalToOther = true
                    break
                }
            }
            
            if !isIdenticalToOther {
                distinctHits.append(hit)
            }
        }
        
        for hit in distinctHits {
            var count = 0;
            for otherHit in distinctHits {
                if otherHit.node == hit.node {
                    count += 1
                }
            }
            if count % 2 == 1 {
                return hit.node
            }
        }
        
        return nil
    }
    
    func nodesAtInterface(thePoint:SCNVector3, theDisplacement:SCNVector3) throws -> SCNNode? {
        var node:SCNNode?
        
        let hitList = self.fastHitTestWithSegmentFromPoint(fromPoint:thePoint,
            toPoint: thePoint + theDisplacement,
            options: [SCNHitTestBackFaceCullingKey:false, SCNHitTestSortResultsKey:true, SCNHitTestIgnoreHiddenNodesKey:false])
        
        if hitList.count > 1 {
            var direction = theDisplacement
            try direction.normalize()
            
            let hit = hitList[0]
            if direction.dotProduct(hit.worldNormal) > 0 {
                node = hit.node
            }
        }
        
        return node
    }
    
    func propertiesAtPosition(thePoint:SCNVector3) -> BulkMaterial {
        let node:SCNNode? = nodeContainingPoint(thePoint: thePoint)
        
        if node != nil {
            for child in node!.childNodes {
                if let material = child as? BulkMaterial {
                    return material
                }
            }
        }

        return air
    }
    
    
}
