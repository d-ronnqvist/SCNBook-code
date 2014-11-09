//
//  AppDelegate.m
//  Chapter 12 - Custom Shaders
//
//  Created by David Rönnqvist on 2014-04-22.
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


/**
 Instead of creating many diffrent projects, the values below
 can be turned on/off to try out the different examples.
 */
const BOOL useBasicShading      = NO;  // looks the same as a regular SCNMaterial configuration
const BOOL useCustomShading     = !useBasicShading; // twists the geometry and toon shades the fragments

const BOOL useTexture           = YES;  // this is only used in the "basic" shader


@interface AppDelegate () <SCNProgramDelegate>
@property (strong) GLKTextureInfo *texture;
@end


@implementation AppDelegate

- (void)awakeFromNib
{
    // Base scene
    SCNScene *scene = [SCNScene scene];
    self.sceneView.scene = scene;
    
    // Camera
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.position = SCNVector3Make(0, 4, 4);
    
    cameraNode.rotation = SCNVector4Make(1, 0, 0,
                                         -M_PI_4);
    
    [scene.rootNode addChildNode:cameraNode];
    
    
    // Geometry object
    SCNTorus *torus = [SCNTorus torusWithRingRadius:1.0 pipeRadius:0.65];
    torus.ringSegmentCount = 400;
    torus.pipeSegmentCount = 100;
    
    SCNNode *torusNode = [SCNNode nodeWithGeometry:torus];
    [scene.rootNode addChildNode:torusNode];
    
    NSString *shaderName;
    if (useBasicShading) {
        shaderName = @"myShader";
    } else if (useCustomShading) {
        shaderName = @"customShader";
    }
    
    // Read the shaders source from the two files.
    NSURL *vertexShaderURL   = [[NSBundle mainBundle] URLForResource:shaderName withExtension:@"vert"];
    NSURL *fragmentShaderURL = [[NSBundle mainBundle] URLForResource:shaderName withExtension:@"frag"];
    NSString *vertexShader   = [[NSString alloc] initWithContentsOfURL:vertexShaderURL
                                                              encoding:NSUTF8StringEncoding
                                                                 error:NULL];
    NSString *fragmentShader = [[NSString alloc] initWithContentsOfURL:fragmentShaderURL
                                                              encoding:NSUTF8StringEncoding
                                                                 error:NULL];
    
    // Create a shader program and assign the shaders
    SCNProgram *program = [SCNProgram program];
    program.vertexShader   = vertexShader;
    program.fragmentShader = fragmentShader;
    
    // Become the program delegate (to get runtime compilation errors)
    program.delegate = self;
    
    
    // Associate geometry and node data with the attributes and uniforms
    // -----------------------------------------------------------------
    
    // Attributes (position, normal, texture coordinate)
    [program setSemantic:SCNGeometrySourceSemanticVertex
               forSymbol:@"position"
                 options:nil];
    [program setSemantic:SCNGeometrySourceSemanticNormal
               forSymbol:@"normal"
                 options:nil];
    [program setSemantic:SCNGeometrySourceSemanticTexcoord
               forSymbol:@"textureCoordinate"
                 options:nil];
    
    // Uniforms (the three different transformation matrices)
    [program setSemantic:SCNModelViewProjectionTransform
               forSymbol:@"modelViewProjection"
                 options:nil];
    [program setSemantic:SCNModelViewTransform
               forSymbol:@"modelView"
                 options:nil];
    [program setSemantic:SCNNormalTransform
               forSymbol:@"normalTransform"
                 options:nil];
    
    
    
    // Bind additional uniforms to the shader code
    // -------------------------------------------
    
    // Bind the diffuse color with a custom light blue color
    [torus.firstMaterial handleBindingOfSymbol:@"diffuseColor"
                                    usingBlock:^(unsigned int programID,
                                                 unsigned int location,
                                                 SCNNode *renderedNode,
                                                 SCNRenderer *renderer)
     {
         // the 3f suffix stands for "3 floats"
         glUniform3f(location, 0.043, 0.498, 1.000);
     }];
    
    // Bind a bool to switch between using a texture (see below) and a solid color (see above)
    [torus.firstMaterial handleBindingOfSymbol:@"shouldUseTexture"
                                    usingBlock:^(unsigned int programID,
                                                 unsigned int location,
                                                 SCNNode *renderedNode,
                                                 SCNRenderer *renderer)
     {
         glUniform1i(location, useTexture);
         
         // both glUniform1i() and glUniform1f() can be used to pass a bool
         // http://www.khronos.org/opengles/sdk/docs/man/xhtml/glUniform.xml
     }];
    
    static NSTimeInterval time = 0.0;
    // Bind a bool to switch between using a texture (see below) and a solid color (see above)
    [torus.firstMaterial handleBindingOfSymbol:@"time"
                                    usingBlock:^(unsigned int programID,
                                                 unsigned int location,
                                                 SCNNode *renderedNode,
                                                 SCNRenderer *renderer)
     {
         glUniform1f(location, time+=0.01);
     }];
    
    
    // Bind the texture sampler (using GLKit to load the texture)
    [torus.firstMaterial handleBindingOfSymbol:@"checkerboardTexture"
                                    usingBlock:^(unsigned int programID,
                                                 unsigned int location,
                                                 SCNNode *renderedNode,
                                                 SCNRenderer *renderer)
     {
         
         if (!self.texture) {
             NSError *textureLoadingError = nil;
             NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"checker tile dark" ofType:@"jpg"];
             GLKTextureInfo *texture = [GLKTextureLoader textureWithContentsOfFile:imagePath options:nil error:&textureLoadingError];
             
             if(!texture) {
                 // Handle the error
             }
             self.texture = texture;
         }
         
         glBindTexture(GL_TEXTURE_2D, self.texture.name);
     }];
    
    
    // Make the torus use the custom shaders
    torus.firstMaterial.program = program;
    
    // Slowly spin the torus to better see the effect of the shader
    CABasicAnimation *spin = [CABasicAnimation animationWithKeyPath:@"rotation"];
    spin.fromValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, 0)];
    spin.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI*2.0)];
    spin.duration = 10;
    spin.repeatCount = INFINITY;
    spin.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    [torusNode addAnimation:spin forKey:nil];
}

#pragma mark - SCNProgramDelegate

- (void)program:(SCNProgram *)program
    handleError:(NSError *)error
{
    // Handle the error.
    NSLog(@"%@", error.localizedDescription);
}

@end
