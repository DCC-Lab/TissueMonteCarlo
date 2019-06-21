//
//  SCNKdTree.swift
//  MonteCarlo3D
//
//  Created by Daniel Côté on 2016-02-14.
//  Copyright © 2016 Daniel Côté. All rights reserved.
//

import Foundation
import SceneKit

enum Axis:Int {
    case X=0,Y=1,Z=2
}

enum RelativePosition {
    case ToTheLeft, Straddling, ToTheRight
}

extension SCNNode {
    func allKDTriangles() -> [KDTriangle] {
        var triangles=[KDTriangle]()
        
        if geometry != nil {
            for i in 0..<geometry!.elementCount {
                let element = geometry!.element(at: i)
                
                if element.primitiveType == SCNGeometryPrimitiveType.triangles {
                    for j in 0..<element.primitiveCount {
                        triangles.append(KDTriangle(node:self, geometryIndex:i, primitiveIndex: j)!)
                    }
                }
            }
        }
        return triangles
    }

    func fastHitTestWithSegmentFromPoint(fromPoint:SCNVector3, toPoint:SCNVector3, options:[String:AnyObject] ) -> [SCNHitTestResult]{

        return self.hitTestWithSegmentFromPoint(fromPoint, toPoint: toPoint, options: options)
        
//        let kdt:SCNNode? = childNodeWithName("KDTree", recursively: false)
//        
//        if kdt == nil {
//            let rootNode = KDTNode()
//            
//            let nodesWithGeometry = self.childNodesPassingTest({ (child:SCNNode, bool:UnsafeMutablePointer<ObjCBool>) -> Bool in
//                if child.geometry != nil {
//                    return true
//                } else {
//                    return false
//                }
//            })
//            
//            var allTriangles = [KDTriangle]()
//            for node in nodesWithGeometry {
//                allTriangles.appendContentsOf(node.allKDTriangles())
//            }
//            rootNode.buildTree(.X, triangles: allTriangles )
//        }
    }

}


class KDTNode {
    var triangles:[KDTriangle]
    var leftNode:KDTNode?
    var rightNode:KDTNode?
    var axis:Axis?
    var value:CGFloat?
    
    required init() {
        leftNode = nil
        rightNode = nil
        axis = nil
        value = nil
        triangles = [KDTriangle]()
    }
    
    func buildTree(splitAxis:Axis, triangles:[KDTriangle]) {
        
        if triangles.count < 15 {
            self.triangles.appendContentsOf(triangles)
            return
        }
        
        leftNode = KDTNode()
        rightNode = KDTNode()
        
        value = chooseSplitValue(forAxis: splitAxis, triangles: triangles)
        axis = splitAxis
        
        var leftKD = [KDTriangle]()
        var rightKD = [KDTriangle]()
        
        for triangle in triangles {
            let vertices = triangle.vertices!
            
            if vertices[0][splitAxis] <= value && vertices[1][splitAxis] <= value && vertices[2][splitAxis] <= value {
                leftKD.append(triangle)
            } else if vertices[0][splitAxis] >= value && vertices[1][splitAxis] >= value && vertices[2][splitAxis] >= value {
                rightKD.append(triangle)
            } else {
                leftKD.append(triangle)
                rightKD.append(triangle)
            }
        }

        var nextSplit = Axis.X
        
        if splitAxis == .X {
            nextSplit = .Y
        } else if splitAxis == .Y {
            nextSplit = .Z
        }
        
        leftNode!.buildTree(nextSplit, triangles: leftKD)
        rightNode!.buildTree(nextSplit, triangles: rightKD)
    }
        
    func chooseSplitValue(forAxis splitAxis:Axis, triangles:[KDTriangle]) -> CGFloat {
        var values = [CGFloat]()
        
        for kdPrimitive in triangles {
            values.append(kdPrimitive.maxPoint![splitAxis])
            values.append(kdPrimitive.minPoint![splitAxis])
        }
        
        let sorted = values.sort { return $0 < $1 }
        return sorted[values.count/2]
    }
    

    func hitTestClosestOnlyKDTreeWithSegmentFromPoint(pointA:SCNVector3, toPoint pointB:SCNVector3 ) -> (CGFloat,KDTriangle)? {
        
        let direction = pointB - pointA
        var stack = [(KDTNode, CGFloat, CGFloat)]()
        var t_near = 0 as CGFloat
        var t_far = 1 as CGFloat

        var node = self
        while true {
            while node.leftNode != nil || node.rightNode != nil {
                // traverse ’til next leaf
                let d = (node.value! - pointA[node.axis!]) / direction[node.axis!]

                if d <= t_near {
                    node = node.rightNode!
                } else if d >= t_far {
                    node = node.leftNode!
                } else {
                    stack.append((node.rightNode!,d,t_far))
                    
                    node = node.leftNode!
                    t_far = d
                }
            }

            // have a leaf now
            let intersect = node.intersectRayWithClosestPrimitives(fromPoint: pointA, toPoint: pointB)
            
            if intersect != nil {
                return intersect!
            }
            
            if stack.isEmpty {
                return nil
            } else {
                ( node, t_near, t_far ) = stack.removeLast()
            }
        }
    }

    func hitTestWithSegmentFromPoint(pointA:SCNVector3, toPoint pointB:SCNVector3, closestOnly:Bool ) -> [(CGFloat,KDTriangle)] {
        
        let direction = pointB - pointA
        var stack = [(KDTNode, CGFloat, CGFloat)]()
        var t_near = 0 as CGFloat
        var t_far = 1 as CGFloat
        var intersects = [(CGFloat,KDTriangle)]()
        var node = self
        
        while true {
            while node.leftNode != nil || node.rightNode != nil {
                // traverse ’til next leaf
                let d = (node.value! - pointA[node.axis!]) / direction[node.axis!]
                
                if d <= t_near {
                    node = node.rightNode!
                } else if d >= t_far {
                    node = node.leftNode!
                } else {
                    stack.append((node.rightNode!,d,t_far))
                    
                    node = node.leftNode!
                    t_far = d
                }
            }
            
            // have a leaf now

            if closestOnly {
                let intersect = node.intersectRayWithClosestPrimitives(fromPoint: pointA, toPoint: pointB)
                if intersect != nil {
                    intersects.append(intersect!)
                    return intersects
                }
            } else {
                let intersect = node.intersectRayWithAllPrimitives(fromPoint: pointA, toPoint: pointB)
                if intersect.count != 0 {
                    intersects.appendContentsOf(intersect)
                }
            }
            
            
            if stack.isEmpty {
                return intersects
            } else {
                ( node, t_near, t_far ) = stack.removeLast()
            }
        }
    }

    func hitTestRecursiveWithSegmentFromPoint(pointA:SCNVector3, toPoint pointB:SCNVector3 ) -> (CGFloat,KDTriangle)? {
        return recursiveTraverse(fromPoint:pointA, toPoint: pointB, t_near: 0, t_far: 1)
    }
    
    func recursiveTraverse(fromPoint pointA:SCNVector3, toPoint pointB:SCNVector3, t_near:CGFloat, t_far:CGFloat) -> (CGFloat,KDTriangle)? {
        let direction = pointB - pointA
        
        if leftNode == nil && rightNode == nil {
            return intersectRayWithClosestPrimitives(fromPoint:pointA, toPoint: pointB)
        }
        
        let d = (value! - pointA[axis!]) / direction[axis!]

        if d <= t_near {
            return rightNode?.recursiveTraverse(fromPoint:pointA, toPoint: pointB, t_near: t_near, t_far:t_far)
        } else if d >= t_far {
            return leftNode?.recursiveTraverse(fromPoint:pointA, toPoint: pointB, t_near: t_near, t_far:t_far)
        } else {
            let t_hit = leftNode?.recursiveTraverse(fromPoint:pointA, toPoint: pointB, t_near: t_near, t_far: d)
            if t_hit != nil {
                return t_hit
            }
            return rightNode?.recursiveTraverse(fromPoint:pointA, toPoint: pointB, t_near: d, t_far: t_far)
        }
        
    }

    func intersectRayWithClosestPrimitives(fromPoint pointA:SCNVector3, toPoint pointB:SCNVector3) -> (CGFloat,KDTriangle)? {
        var dMin:CGFloat?
        var closestPrimitive:KDTriangle?
        
        for primitive in triangles {
            let d = primitive.intersectWithRay(fromPoint:pointA, toPoint: pointB)
            
            if d != nil {
                if dMin != nil {
                    if dMin > d {
                        dMin = d
                        closestPrimitive = primitive
                    }
                } else {
                    dMin = d!
                    closestPrimitive = primitive
                }
            }
        }
        if dMin != nil {
            return (dMin!, closestPrimitive!)
        }
        
        return nil
    }


    func intersectRayWithAllPrimitives(fromPoint pointA:SCNVector3, toPoint pointB:SCNVector3) -> [(CGFloat,KDTriangle)] {
        
        var intersects = [(CGFloat,KDTriangle)]()
        
        for primitive in triangles {
            let d = primitive.intersectWithRay(fromPoint:pointA, toPoint: pointB)
            
            if d != nil {
                intersects.append((d!, primitive))
            }
        }
        
        return intersects
    }

}

struct KDTriangle {
    var node:SCNNode?
    var geometryIndex:Int?
    var primitiveIndex:Int?

    var vertices:[SCNVector3]?
    var maxPoint:SCNVector3?
    var minPoint:SCNVector3?

    init?(vertices:[SCNVector3]) {
        if vertices.count == 3 {
            self.vertices = vertices
            self.maxPoint = SCNVector3(
                max(vertices[0].x, vertices[1].x, vertices[2].x),
                max(vertices[0].y, vertices[1].y, vertices[2].y),
                max(vertices[0].z, vertices[1].z, vertices[2].z))
            self.minPoint = SCNVector3(
                min(vertices[0].x, vertices[1].x, vertices[2].x),
                min(vertices[0].y, vertices[1].y, vertices[2].y),
                min(vertices[0].z, vertices[1].z, vertices[2].z))
        } else {
            return nil
        }
    }

    init?(node:SCNNode, geometryIndex:Int, primitiveIndex:Int) {
        if node.geometry == nil {
            return nil
        } else {
            let theVertices:[SCNVector3]? = node.geometry!.triangularSurfacePrimitiveAtIndex(geometryIndex: geometryIndex, primitiveIndex: primitiveIndex)
            if theVertices == nil {
                return nil
            } else {
                self.init(vertices:theVertices!)
                self.node = node
                self.geometryIndex = geometryIndex
                self.primitiveIndex = primitiveIndex
            }
        }

    }
    
    func intersectWithRay(fromPoint pointA:SCNVector3, toPoint pointB:SCNVector3) -> CGFloat? {
        // https://en.wikipedia.org/wiki/Möller–Trumbore_intersection_algorithm
        
        let direction = pointB-pointA
        
        let EPSILON:CGFloat = 1e-6
        let v1 = vertices![0]
        let v2 = vertices![1]
        let v3 = vertices![2]
        
        //Find vectors for two edges sharing V1
        let e1 = v2-v1
        let e2 = v3-v1
        //Begin calculating determinant - also used to calculate u parameter
        let P = direction.crossProduct(e2)
        //if determinant is near zero, ray lies in plane of triangle
        let det = e1.dotProduct(P)
        //NOT CULLING
        if det > -EPSILON && det < EPSILON {
            return nil
        }
        
        let inv_det = 1.0 / det;
        
        //calculate distance from V1 to ray origin
        let T = pointA - v1
        
        //Calculate u parameter and test bound
        let u = T.dotProduct(P) * inv_det
        
        //The intersection lies outside of the triangle
        if u < 0.0 || u > 1.0 {
            return nil
        }
        
        //Prepare to test v parameter
        let Q = T.crossProduct(e1)
        //Calculate V parameter and test bound
        let v = direction.dotProduct(Q) * inv_det
        
        //The intersection lies outside of the triangle
        if v < 0.0 || v > 1.0 {
            return nil
        }

        let t = e2.dotProduct(Q) * inv_det
        
        if t > EPSILON && t <= 1 { //ray intersection
            return t
        }
        
        return nil
    }
    
}

