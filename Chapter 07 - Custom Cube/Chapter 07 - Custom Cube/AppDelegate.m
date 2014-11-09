//
//  AppDelegate.m
//  Chapter 07 - Custom Cube
//
//  Created by David Rönnqvist on 2014-04-06.
//  Copyright (c) 2014 David Rönnqvist.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in the
// Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
// and to permit persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import "AppDelegate.h"

@implementation AppDelegate

- (void)awakeFromNib
{
    // An empty scene
    SCNScene *scene = [SCNScene scene];
    self.cubeView.scene = scene;
    
	SCNNode *cameraNode = [SCNNode node];
	cameraNode.camera   = [SCNCamera camera];
	cameraNode.position = SCNVector3Make(0, 12, 30);
    cameraNode.rotation = SCNVector4Make(1, 0, 0,
                                         -sin(12.0/30.0));

    
    [scene.rootNode addChildNode:cameraNode];
	
    
    // Custom geometry data for a cube
    // --------------------------
    CGFloat cubeSide = 15.0;
    CGFloat halfSide = cubeSide/2.0;
    
    SCNVector3 vertices[] = {
        SCNVector3Make(-halfSide, -halfSide,  halfSide),
        SCNVector3Make( halfSide, -halfSide,  halfSide),
        SCNVector3Make(-halfSide, -halfSide, -halfSide),
        SCNVector3Make( halfSide, -halfSide, -halfSide),
        SCNVector3Make(-halfSide,  halfSide,  halfSide),
        SCNVector3Make( halfSide,  halfSide,  halfSide),
        SCNVector3Make(-halfSide,  halfSide, -halfSide),
        SCNVector3Make( halfSide,  halfSide, -halfSide),
        
        // repeat exactly the same
        SCNVector3Make(-halfSide, -halfSide,  halfSide),
        SCNVector3Make( halfSide, -halfSide,  halfSide),
        SCNVector3Make(-halfSide, -halfSide, -halfSide),
        SCNVector3Make( halfSide, -halfSide, -halfSide),
        SCNVector3Make(-halfSide,  halfSide,  halfSide),
        SCNVector3Make( halfSide,  halfSide,  halfSide),
        SCNVector3Make(-halfSide,  halfSide, -halfSide),
        SCNVector3Make( halfSide,  halfSide, -halfSide),
        
        // repeat exactly the same
        SCNVector3Make(-halfSide, -halfSide,  halfSide),
        SCNVector3Make( halfSide, -halfSide,  halfSide),
        SCNVector3Make(-halfSide, -halfSide, -halfSide),
        SCNVector3Make( halfSide, -halfSide, -halfSide),
        SCNVector3Make(-halfSide,  halfSide,  halfSide),
        SCNVector3Make( halfSide,  halfSide,  halfSide),
        SCNVector3Make(-halfSide,  halfSide, -halfSide),
        SCNVector3Make( halfSide,  halfSide, -halfSide)
    };
    
    SCNVector3 normals[] = {
        // up and down
        SCNVector3Make( 0, -1, 0),
        SCNVector3Make( 0, -1, 0),
        SCNVector3Make( 0, -1, 0),
        SCNVector3Make( 0, -1, 0),
        
        SCNVector3Make( 0, 1, 0),
        SCNVector3Make( 0, 1, 0),
        SCNVector3Make( 0, 1, 0),
        SCNVector3Make( 0, 1, 0),
        
        // back and front
        SCNVector3Make( 0, 0,  1),
        SCNVector3Make( 0, 0,  1),
        SCNVector3Make( 0, 0, -1),
        SCNVector3Make( 0, 0, -1),
        
        SCNVector3Make( 0, 0, 1),
        SCNVector3Make( 0, 0, 1),
        SCNVector3Make( 0, 0, -1),
        SCNVector3Make( 0, 0, -1),
        
        // left and right
        SCNVector3Make(-1, 0, 0),
        SCNVector3Make( 1, 0, 0),
        SCNVector3Make(-1, 0, 0),
        SCNVector3Make( 1, 0, 0),
        
        SCNVector3Make(-1, 0, 0),
        SCNVector3Make( 1, 0, 0),
        SCNVector3Make(-1, 0, 0),
        SCNVector3Make( 1, 0, 0),
    };
    
	CGPoint UVs[] = {
		CGPointMake(0, 0), // bottom
		CGPointMake(1, 0), // bottom
		CGPointMake(0, 1), // bottom
		CGPointMake(1, 1), // bottom
		
		CGPointMake(0, 1), // top
		CGPointMake(1, 1), // top
		CGPointMake(0, 0), // top
		CGPointMake(1, 0), // top
		
		CGPointMake(0, 1), // front
		CGPointMake(1, 1), // front
		CGPointMake(1, 1), // back
		CGPointMake(0, 1), // back
		
		CGPointMake(0, 0), // front
		CGPointMake(1, 0), // front
		CGPointMake(1, 0), // back
		CGPointMake(0, 0), // back
		
		CGPointMake(1, 1), // left
		CGPointMake(0, 1), // right
		CGPointMake(0, 1), // left
		CGPointMake(1, 1), // right
		
		CGPointMake(1, 0), // left
		CGPointMake(0, 0), // right
		CGPointMake(0, 0), // left
		CGPointMake(1, 0), // right
    };
    
    // Indices that turn the source data into triangles and lines
    // ----------------------------------------------------------
    
    int solidIndices[] = {
        // bottom
        0, 2, 1,
        1, 2, 3,
        // back
        10, 14, 11,  // 2, 6, 3,   + 8
        11, 14, 15,  // 3, 6, 7,   + 8
        // left
        16, 20, 18,  // 0, 4, 2,   + 16
        18, 20, 22,  // 2, 4, 6,   + 16
        // right
        17, 19, 21,  // 1, 3, 5,   + 16
        19, 23, 21,  // 3, 7, 5,   + 16
        // front
        8,  9, 12,  // 0, 1, 4,   + 8
        9, 13, 12,  // 1, 5, 4,   + 8
        // top
        4, 5, 6,
        5, 7, 6
    };
    
    int lineIndices[] = {
        // bottom
        0, 1,
        0, 2,
        1, 3,
        2, 3,
        // top
        4, 5,
        4, 6,
        5, 7,
        6, 7,
        // sides
        0, 4,
        1, 5,
        2, 6,
        3, 7,
        // diagonals
        0, 5,
        1, 7,
        2, 4,
        3, 6,
        1, 2,
        4, 7
    };
    
    // Creating the custom geometry object
    // ----------------------------------
    
    // Sources for the vertices, normals, and UVs
    SCNGeometrySource *vertexSource =
    [SCNGeometrySource geometrySourceWithVertices:vertices
                                            count:24];
    SCNGeometrySource *normalSource =
    [SCNGeometrySource geometrySourceWithNormals:normals
                                           count:24];
    
    SCNGeometrySource *uvSource =
	[SCNGeometrySource geometrySourceWithTextureCoordinates:UVs count:24];
    
    
    
    NSData *solidIndexData = [NSData dataWithBytes:solidIndices
                                            length:sizeof(solidIndices)];
    
    NSData *lineIndexData = [NSData dataWithBytes:lineIndices
                                           length:sizeof(lineIndices)];
    
    // Create one element for the triangles and one for the lines
    // using the two different buffers defined above
    SCNGeometryElement *solidElement =
    [SCNGeometryElement geometryElementWithData:solidIndexData
                                  primitiveType:SCNGeometryPrimitiveTypeTriangles
                                 primitiveCount:12
                                  bytesPerIndex:sizeof(int)];
    
    SCNGeometryElement *lineElement =
    [SCNGeometryElement geometryElementWithData:lineIndexData
                                  primitiveType:SCNGeometryPrimitiveTypeLine
                                 primitiveCount:18
                                  bytesPerIndex:sizeof(int)];
    
    
    
    // Create a geometry object from the sources and the two elements
    SCNGeometry *geometry =
    [SCNGeometry geometryWithSources:@[vertexSource, normalSource, uvSource]
                            elements:@[solidElement, lineElement]];
    
    
    // Give the cube a light blue colored material for the solid part ...
    NSColor *lightBlueColor = [NSColor colorWithCalibratedRed:  4.0/255.0
                                                        green:120.0/255.0
                                                         blue:255.0/255.0
                                                        alpha:1.0];
    
    SCNMaterial *solidMataterial = [SCNMaterial material];
    solidMataterial.diffuse.contents = lightBlueColor;
	solidMataterial.locksAmbientWithDiffuse = YES;
	
    // ... and a white constant material for the lines
    SCNMaterial *lineMaterial = [SCNMaterial material];
    lineMaterial.diffuse.contents  = [NSColor whiteColor];
    lineMaterial.lightingModelName = SCNLightingModelConstant;
    
    geometry.materials = @[solidMataterial, lineMaterial];
    
    
    // Attach the cube (solid + lines) to a node and add it to the scene
    SCNNode *cubeNode = [SCNNode nodeWithGeometry:geometry];
    [scene.rootNode addChildNode:cubeNode];
}

@end

