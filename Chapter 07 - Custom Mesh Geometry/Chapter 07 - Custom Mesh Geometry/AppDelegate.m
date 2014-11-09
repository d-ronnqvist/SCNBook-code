//
//  AppDelegate.m
//  Chapter 07 - Custom Mesh Geometry
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
@import GLKit;

@implementation AppDelegate

- (void)awakeFromNib
{
    // Basic scene setup
    SCNScene *scene = [SCNScene scene];
    self.meshView.scene = scene;
    
    
    // The mesh will have a size of 100 x 100
    int width  = 100;
    int height = 100;
    
    
    // Generate the index data for the mesh
    // ------------------------------------
    
    NSUInteger indexCount = (2 * width + 1) * (height-1);
    // Create a buffer for the index data
    int *indices = calloc(indexCount, sizeof(int));
    
    // Generate index data as desscribed in the chapter
    int i = 0;
    for (int h=0 ; h<height-1 ; h++) {
        BOOL isEven = h%2 == 0;
        if (isEven) {
            // --->
            for (int w=0 ; w<width ; w++) {
                indices[i++] =  h    * width + w;
                indices[i++] = (h+1) * width + w;
            }
        } else {
            // <---
            for (int w=width-1 ; w>=0 ; w--) {
                indices[i++] = (h+0) * width + w;
                indices[i++] = (h+1) * width + w;
            }
        }
        int previous = indices[i-1];
        indices[i++] = previous;
    }
    NSAssert(indexCount == i, @"Should have added as many lines as the size of the buffer");
    
    
    
    // Generate the source data for the mesh
    // -------------------------------------
    
    // Create buffers for the source data
    NSUInteger pointCount = width * height;
    SCNVector3 *vertices = calloc(pointCount, sizeof(SCNVector3));
    SCNVector3 *normals  = calloc(pointCount, sizeof(SCNVector3));
    CGPoint    *UVs = calloc(pointCount, sizeof(CGPoint));
    
    
    // Define the function that is used to calculate the y(x,z)
    GLKVector3(^function)(float, float) = ^(float x, float z) {
        float angle = 1.0/2.0 * sqrt(pow(x, 2) + pow(z, 2));
        return GLKVector3Make(x,
                              2.0 * cos(angle),
                              z);
    };
    
    // Define the range of x and z for which values are calculated
    float minX = -30.0, maxX = 30.0;
    float minZ = -30.0, maxZ = 30.0;
    
    
    for (int h = 0 ; h<height ; h++) {
        for (int w = 0 ; w<width ; w++) {
            // Calculate x and z for this point
            CGFloat x = w/(CGFloat)(width-1)  * (maxX-minX) + minX;
            CGFloat z = h/(CGFloat)(height-1) * (maxZ-minZ) + minZ;
            
            // The index for the vertex/normal/texture buffers
            NSUInteger index = h*width + w;
            
            // Vertex data
            GLKVector3 current = function(x,z);
            vertices[index] = SCNVector3FromGLKVector3(current);
            
            // Normal data
            CGFloat delta = 0.001;
            GLKVector3 nextX   = function(x+delta, z);
            GLKVector3 nextZ   = function(x,       z+delta);
            
            GLKVector3 dx = GLKVector3Subtract(nextX, current);
            GLKVector3 dz = GLKVector3Subtract(nextZ, current);
            
            GLKVector3 normal = GLKVector3Normalize( GLKVector3CrossProduct(dz, dx) );
            normals[index] = SCNVector3FromGLKVector3(normal);
            
            // Texture data
            UVs[index] = CGPointMake(w/(CGFloat)(width-1),
                                     h/(CGFloat)(height-1));
        }
    }
    
    
    // Create sources for the vertext/normal/texture data
    SCNGeometrySource *vertexSource  =
    [SCNGeometrySource geometrySourceWithVertices:vertices
                                            count:pointCount];
    SCNGeometrySource *normalSource  =
    [SCNGeometrySource geometrySourceWithNormals:normals
                                           count:pointCount];
    SCNGeometrySource *textureSource =
    [SCNGeometrySource geometrySourceWithTextureCoordinates:UVs
                                                      count:pointCount];
    
    
    // Create index data ...
    NSData *indexData = [NSData dataWithBytes:indices
                                       length:sizeof(indices)*indexCount];
    // ... and use it to create the geometry element
    SCNGeometryElement *element =
    [SCNGeometryElement geometryElementWithData:indexData
                                  primitiveType:SCNGeometryPrimitiveTypeTriangleStrip
                                 primitiveCount:indexCount
                                  bytesPerIndex:sizeof(int)];
    
    // Create the geometry object with the sources and the element
    SCNGeometry *geometry =
    [SCNGeometry geometryWithSources:@[vertexSource, normalSource, textureSource]
                            elements:@[element]];
    
    // Give it a blue checker board texture
    SCNMaterial *blueMaterial      = [SCNMaterial material];
    blueMaterial.diffuse.contents  = [NSImage imageNamed:@"checkerboard"];
    blueMaterial.specular.contents = [NSColor darkGrayColor];
    blueMaterial.shininess         = 0.25;
    
    // Scale down the image when used as a texture ...
    blueMaterial.diffuse.contentsTransform = CATransform3DMakeScale(5.0, 5.0, 1.0);
    // ... and make it repeat
    blueMaterial.diffuse.wrapS = SCNRepeat;
    blueMaterial.diffuse.wrapT = SCNRepeat;
    
    geometry.materials = @[blueMaterial];
    
    
    // Create a node to hold the geometry and
    SCNNode *geometryNode = [SCNNode nodeWithGeometry:geometry];
    [scene.rootNode addChildNode:geometryNode];
}

@end
