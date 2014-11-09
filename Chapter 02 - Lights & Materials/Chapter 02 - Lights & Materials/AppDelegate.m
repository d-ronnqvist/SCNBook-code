//
//  AppDelegate.m
//  Chapter 02 - Lights & Materials
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



/** 
 Instead of creating many diffrent projects, the values below
 can be turned on/off to try out the different examples.
 */
const BOOL useOmniLight         = NO;
const BOOL useSpotlight         = !useOmniLight;
const BOOL useAmbientLight      = YES;  /// lights up the full scene a little bit
const BOOL useTwoBoxes          = NO;   /// another box with specular hightlights
const BOOL useMultipleMaterials = YES;  /// different colors on each side


#import "AppDelegate.h"

@implementation AppDelegate

- (void)awakeFromNib
{
    // Same box and camera as in Chapter 1
    // -----------------------------------
    SCNScene *scene = [SCNScene scene];
    self.sceneView.scene = scene;
	
    CGFloat boxSide = 10.0; // A square box
    SCNBox *box = [SCNBox boxWithWidth:boxSide
                                height:boxSide
                                length:boxSide
                         chamferRadius:0.0]; // sharp corners
    
	SCNNode *boxNode = [SCNNode nodeWithGeometry:box];
	[scene.rootNode addChildNode:boxNode];
    
    boxNode.rotation = SCNVector4Make(0, 1, 0,   // rotate around Y
                                      M_PI/5.0); // a small angle
    
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera   = [SCNCamera camera];
    cameraNode.position = SCNVector3Make(0, 10, 20);
    cameraNode.rotation = SCNVector4Make(1, 0, 0, // rotate around X
                                         -sin(10.0/20.0));
    
    [scene.rootNode addChildNode:cameraNode];
    
    NSColor *lightBlueColor = [NSColor colorWithCalibratedRed:  4.0/255.0
                                                        green:120.0/255.0
                                                         blue:255.0/255.0
                                                        alpha:1.0];
    
    // New to this chapter
    // ===================
    
    // A blue box with white lights
    box.firstMaterial.diffuse.contents        = lightBlueColor;
    box.firstMaterial.locksAmbientWithDiffuse = YES;
    NSColor *lightColor = [NSColor whiteColor];
    
    
    if (useOmniLight) {
        // A omni light that fades in intensity from 15 to 20 units of distance
        // --------------------------------------------------------------------
        
        SCNLight *omniLight = [SCNLight light];
        omniLight.type  = SCNLightTypeOmni;
        omniLight.color = lightColor;
        
        // Change when the intenisty of the light starts to fade ...
        [omniLight setAttribute:@15 forKey:SCNLightAttenuationStartKey];
        // ... and where it has faded completely
        [omniLight setAttribute:@20 forKey:SCNLightAttenuationEndKey];
        
        SCNNode *omniLightNode = [SCNNode node];
        omniLightNode.light    = omniLight;
        [cameraNode addChildNode:omniLightNode];

    }
    
    
    
    if (useSpotlight) {
        // A very narrow spot light that fades quickly along the edge
        // ----------------------------------------------------------
        
        SCNLight *spotlight = [SCNLight light];
        spotlight.type  = SCNLightTypeSpot;
        spotlight.color = lightColor;
        
        // Change the inner and outer angles of the spotlight
        [spotlight setAttribute:@25 forKey:SCNLightSpotInnerAngleKey];
        [spotlight setAttribute:@30 forKey:SCNLightSpotOuterAngleKey];
        
        SCNNode *spotlightNode = [SCNNode node];
        spotlightNode.light    = spotlight;
        [cameraNode addChildNode:spotlightNode];
    }
    
    
    
    if (useAmbientLight) {
        // An ambient light makes everything in the scene slightly brighter
        // ----------------------------------------------------------------
        
        SCNLight *ambientLight = [SCNLight light];
        ambientLight.type  = SCNLightTypeAmbient;
        
        // Use a dark gray color to make everything just _a little bit_ brighter
        ambientLight.color = [NSColor colorWithCalibratedWhite:0.25 alpha:1.0];
        
        SCNNode *ambientLightNode = [SCNNode node];
        ambientLightNode.light    = ambientLight;
        [scene.rootNode addChildNode:ambientLightNode];
    }
    
    
    
    if (useMultipleMaterials) {
        // Each side of the box has its own color
        // --------------------------------------
        
        // All have the same diffuse and ambient colors to show the
        // effect of the ambient light, even with these materials.
        
        SCNMaterial *greenMaterial              = [SCNMaterial material];
        greenMaterial.diffuse.contents          = [NSColor greenColor];
        greenMaterial.locksAmbientWithDiffuse   = YES;
        
        SCNMaterial *redMaterial                = [SCNMaterial material];
        redMaterial.diffuse.contents            = [NSColor redColor];
        redMaterial.locksAmbientWithDiffuse     = YES;
        
        SCNMaterial *blueMaterial               = [SCNMaterial material];
        blueMaterial.diffuse.contents           = [NSColor blueColor];
        blueMaterial.locksAmbientWithDiffuse    = YES;
        
        SCNMaterial *yellowMaterial             = [SCNMaterial material];
        yellowMaterial.diffuse.contents         = [NSColor yellowColor];
        yellowMaterial.locksAmbientWithDiffuse  = YES;
        
        SCNMaterial *purpleMaterial             = [SCNMaterial material];
        purpleMaterial.diffuse.contents         = [NSColor purpleColor];
        purpleMaterial.locksAmbientWithDiffuse  = YES;
        
        SCNMaterial *magentaMaterial            = [SCNMaterial material];
        magentaMaterial.diffuse.contents        = [NSColor magentaColor];
        magentaMaterial.locksAmbientWithDiffuse = YES;
        
        
        box.materials =  @[greenMaterial,  redMaterial,    blueMaterial,
                           yellowMaterial, purpleMaterial, magentaMaterial];
        
    }
    
    
    
    if (useTwoBoxes) {
        // Create another box that has a specular material
        // -----------------------------------------------
        
        cameraNode.position = SCNVector3Make(0, 0, 20);
        // No rotation on the box or the camera
        
        SCNVector4 noRotation = SCNVector4Make(1, 0, 0, // axis doesn't matter
                                               0); // 0 degrees
        
        cameraNode.rotation = noRotation;
        boxNode.rotation    = noRotation;
        
        
        // ( Copying will be explained in Chapter 5.
        //   Until then we create a new box instead. )
        
        SCNBox *anotherBox = [SCNBox boxWithWidth:boxSide
                                           height:boxSide
                                           length:boxSide
                                    chamferRadius:0.0];
        
        anotherBox.firstMaterial.diffuse.contents        = lightBlueColor;
        anotherBox.firstMaterial.locksAmbientWithDiffuse = YES;
        // same matarial as the original box but with a specular color
        anotherBox.firstMaterial.specular.contents       = [NSColor whiteColor];
        
        SCNNode *anotherBoxNode = [SCNNode nodeWithGeometry:anotherBox];
        [scene.rootNode addChildNode:anotherBoxNode];
        
        // position the two boxes next to each other
        CGFloat boxMargin = 1.0;
        CGFloat boxPositionX = (boxSide + boxMargin)/2.0;
        boxNode.position        = SCNVector3Make( boxPositionX, 0, 0);
        anotherBoxNode.position = SCNVector3Make(-boxPositionX, 0, 0);
        
    }
}

@end
