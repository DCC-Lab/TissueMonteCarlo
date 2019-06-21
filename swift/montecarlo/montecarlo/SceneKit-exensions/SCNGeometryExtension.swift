//
//  SCNGeometryExtension.swift
//  MonteCarlo3D
//
//  Created by Daniel Côté on 2016-02-15.
//  Copyright © 2016 Daniel Côté. All rights reserved.
//

import Foundation
import SceneKit

extension SCNGeometry {
    func dump(prefix:String) {
        print(prefix,"Geometry count:", geometryElementCount)
        let elements = geometryElements
        let sources = geometrySourcesForSemantic(SCNGeometrySourceSemanticVertex)
        
        for source in sources {
            var sourceVertex = [Float](count: source.vectorCount, repeatedValue: 0)
            source.data.getBytes(&sourceVertex, length:source.vectorCount * sizeof(Float))
            
            print(prefix,"Vertex #: ", source.vectorCount)
        }
        
        for element in elements {
            var elementIndices = [Int16](count: element.primitiveCount, repeatedValue: 0)
            element.data.getBytes(&elementIndices, length:element.primitiveCount * sizeof(Int16))
            print(prefix,"Prim type: ", Int(element.primitiveType.rawValue) )
        }
    }
        
    func triangularSurfacePrimitives() -> [[SCNVector3]] {
        var all = [[SCNVector3]]()
        for i in 0..<geometryElementCount {
            let element = geometryElementAtIndex(i)
            
            if element.primitiveType == SCNGeometryPrimitiveType.Triangles {
                for j in 0..<element.primitiveCount {
                    let primitive = triangularSurfacePrimitiveAtIndex(i, primitiveIndex: j)
                    if primitive != nil {
                        all.append(primitive!)
                    }
                }
            }
        }
        return all
    }
    
    func triangularSurfacePrimitiveAtIndex(geometryIndex:Int, primitiveIndex:Int) ->[SCNVector3]? {
        if geometryIndex >= geometryElements.count {
            return nil
        }
        
        let geometryElement = geometryElements[geometryIndex]
        if geometryElement.primitiveType == .Triangles {
            var indices = [Int16](count: geometryElement.primitiveCount*3, repeatedValue: 0)
            
            if primitiveIndex > geometryElement.primitiveCount * 3 {
                return nil
            }
            
            geometryElement.data.getBytes(&indices, length:geometryElement.primitiveCount * 3 * sizeof(Int16)) // 3 2-byte indices per triangle
            
            var vertexIndex = Int(indices[3*primitiveIndex])
            let a = vertexAtIndex(geometryIndex, vertexIndex:vertexIndex)
            
            vertexIndex = Int(indices[3*primitiveIndex+1])
            let b = vertexAtIndex(geometryIndex, vertexIndex:vertexIndex)
            
            vertexIndex = Int(indices[3*primitiveIndex+2])
            let c = vertexAtIndex(geometryIndex, vertexIndex:vertexIndex)
            
            if a != nil && b != nil && c != nil  {
                return [a!,b!,c!]
            }
        }
        return nil
    }
    
    func vertexAtIndex(geometryIndex:Int, vertexIndex:Int) -> SCNVector3? {
        let sources = geometrySourcesForSemantic(SCNGeometrySourceSemanticVertex)
        if sources.count == 1 {
            let source = sources[0]
            var v = [Float](count: sources[0].componentsPerVector, repeatedValue: 0)
            
            let stride = source.dataStride
            let offset = source.dataOffset
            let bytesPerVector = source.componentsPerVector * source.bytesPerComponent
            let byteRange = NSMakeRange(vertexIndex * stride + offset, bytesPerVector);
            
            source.data.getBytes(&v, range:byteRange)
            
            return SCNVector3(v[0],v[1],v[2])
        }

        return nil
    }
    
}
