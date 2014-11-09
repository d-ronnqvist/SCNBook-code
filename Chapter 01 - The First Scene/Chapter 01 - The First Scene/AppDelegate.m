//
//  AppDelegate.m
//  Chapter 01 - The First Scene
//
//  Created by David Rönnqvist on 2014-04-05.
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
    self.sceneView.scene = scene;
	
    
    // A square box with sharp corners
    // -------------------------------
    CGFloat boxSide = 10.0; // A square box
    SCNBox *box = [SCNBox boxWithWidth:boxSide
                                height:boxSide
                                length:boxSide
                         chamferRadius:0.0]; // sharp corners
    
	SCNNode *boxNode = [SCNNode nodeWithGeometry:box];
	[scene.rootNode addChildNode:boxNode];
    
    boxNode.rotation = SCNVector4Make(0, 1, 0,   // rotate around Y
                                      M_PI/5.0); // a small angle
    
    
    // A camera looking down at the box
    // --------------------------------
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera   = [SCNCamera camera];
    cameraNode.position = SCNVector3Make(0, 10, 20);
    cameraNode.rotation = SCNVector4Make(1, 0, 0, // rotate around X
                                         -atan2(10.0, 20.0)); // atan(camY/camZ)
    
    [scene.rootNode addChildNode:cameraNode];
    
    
    // A light blue directional light
    // ------------------------------
    NSColor *lightBlueColor = [NSColor colorWithCalibratedRed:  4.0/255.0
                                                        green:120.0/255.0
                                                         blue:255.0/255.0
                                                        alpha:1.0];
    
    SCNLight *light = [SCNLight light];
    light.type  = SCNLightTypeDirectional;
    light.color = lightBlueColor;
	
    SCNNode *lightNode = [SCNNode node];
    lightNode.light    = light;
    [cameraNode addChildNode:lightNode];
}

@end
