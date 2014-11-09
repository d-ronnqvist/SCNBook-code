//
//  EarthView.m
//  Chapter 05 - Earth
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


// ==================================================================================
//   IMPORTANT NOTE:
// The Image assets (textures) that are included in this project are used with permission
// from the original creator. These permissions include their usage in the digital book
// and in this sample project (including distribution of the sample project).
//
// If you want to use them for other purposes, you can download lower resolution versions
// at: http://planetpixelemporium.com/earth.html or get in contact with the creator.


#import "EarthView.h"
@import CoreLocation;
@import GLKit;


@interface EarthView ()

// The pin the is placed when clicking
@property (nonatomic, strong) SCNNode *pinNode;
// The earth
@property (nonatomic, strong) SCNNode *earthNode;

// Used to get the information about the place that was clicked
@property (nonatomic, strong) CLGeocoder *geocoder;

// Used to read that information out loud.
@property (nonatomic, strong) NSSpeechSynthesizer *speech;

@end


@implementation EarthView

- (void)awakeFromNib
{
    // Scene setup
    // -----------
    SCNScene *scene = [SCNScene scene];
    self.scene = scene;
    self.backgroundColor = [NSColor colorWithCalibratedWhite:0.05 alpha:1.0];
    
    SCNCamera *camera = [SCNCamera camera];
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = camera;
    cameraNode.position = SCNVector3Make(0, 0, 8);
    [scene.rootNode addChildNode:cameraNode];
    
    
    // Create a sphere and use multiple textures to make it look like the earth
    SCNSphere *earth = [SCNSphere sphereWithRadius:3.0];
    SCNMaterial *earthMaterial = [SCNMaterial material];
    
    earthMaterial.diffuse.contents  = [NSImage imageNamed:@"earth_diffuse_4k"];
    earthMaterial.specular.contents = [NSImage imageNamed:@"earth_specular_1k"];
    earthMaterial.emission.contents = [NSImage imageNamed:@"earth_lights_4k"];
    earthMaterial.normal.contents   = [NSImage imageNamed:@"earth_normal_4k"];
    earthMaterial.multiply.contents = [NSColor colorWithCalibratedWhite:0.7 alpha:1.0];
    earthMaterial.shininess	        = 0.05;
    
    earth.firstMaterial = earthMaterial;
    
    SCNNode *earthNode = [SCNNode nodeWithGeometry:earth];
    // tilt the earth
    SCNNode *axisNode = [SCNNode node];
    [scene.rootNode addChildNode:axisNode];
    [axisNode addChildNode:earthNode];
    axisNode.rotation = SCNVector4Make(1, 0, 0, M_PI/6.);
    
    self.earthNode = earthNode;
    
    
    // Create a larger sphere to look like clouds
    SCNSphere *clouds = [SCNSphere sphereWithRadius:3.075];
    clouds.segmentCount = 144; // 3 times the default
    SCNMaterial *cloudsMaterial = [SCNMaterial material];
    
    cloudsMaterial.diffuse.contents = [NSColor whiteColor];
    cloudsMaterial.locksAmbientWithDiffuse = YES;
    // Use a texture where RGB (or lack thereof) determines transparency of the material
    cloudsMaterial.transparent.contents = [NSImage imageNamed:@"clouds_transparent_2K"];
    cloudsMaterial.transparencyMode = SCNTransparencyModeRGBZero;
    
    // Don't have the clouds cast shadows
    cloudsMaterial.writesToDepthBuffer = NO;
    
    
    // ------------------
    // This is a "shader modifier" to create an atmospheric halo effect.
    // We won't go into shader modifiers until Chapter 13. But it adds a nice
    // visual effect to this example.
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"AtmosphereHalo" withExtension:@"glsl"];
    NSError *error;
    NSString *shaderSource = [[NSString alloc] initWithContentsOfURL:url
                                                            encoding:NSUTF8StringEncoding
                                                               error:&error];
    if (!shaderSource) {
        // Handle the error
        NSLog(@"Failed to load shader source code, with error: %@", [error localizedDescription]);
    } else {
        cloudsMaterial.shaderModifiers = @{ SCNShaderModifierEntryPointFragment : shaderSource };
    }
    // ------------------
    
    clouds.firstMaterial = cloudsMaterial;
    SCNNode *cloudNode = [SCNNode nodeWithGeometry:clouds];
    
    [earthNode addChildNode:cloudNode];
    
    earthNode.rotation = SCNVector4Make(0, 1, 0, 0); // specify the rataion axis
    cloudNode.rotation = SCNVector4Make(0, 1, 0, 0); // specify the rataion axis
    
    // Animate the rotation of the earth and the clouds
    // ------------------------------------------------
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"rotation.w"]; // animate the angle
    rotate.byValue   = @(M_PI*2.0);
    rotate.duration  = 50.0;
    rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotate.repeatCount = INFINITY;
    
    [earthNode addAnimation:rotate forKey:@"rotate the earth"];
    
    CABasicAnimation *rotateClouds = [CABasicAnimation animationWithKeyPath:@"rotation.w"]; // animate the angle
    rotateClouds.byValue   = @(-M_PI*2.0);
    rotateClouds.duration  = 150.0;
    rotateClouds.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotateClouds.repeatCount = INFINITY;
    
    [cloudNode addAnimation:rotateClouds forKey:@"slowly move the clouds"];
    
    
    // Create something to light up the earth.
    SCNLight *sun    = [SCNLight light];
    sun.type         = SCNLightTypeSpot;
    
    // Configure the shadows that the sun casts
    sun.castsShadow  = YES;
    sun.shadowRadius = 3.0;
    sun.shadowColor  = [NSColor colorWithCalibratedWhite:0.0 alpha:0.75];
    [sun setAttribute:@10 forKey:SCNLightShadowNearClippingKey];
    [sun setAttribute:@40 forKey:SCNLightShadowFarClippingKey];
    
    SCNNode *sunNode = [SCNNode node];
    sunNode.light    = sun;
    
    // Position the sun to the left
    sunNode.position = SCNVector3Make(-15., 0., 12.);
    
    // Made the sun point at the earth
    sunNode.constraints = @[[SCNLookAtConstraint lookAtConstraintWithTarget:earthNode]];
    [scene.rootNode addChildNode:sunNode];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [super mouseUp:theEvent];
    
    // Get the location of the click
    NSPoint eventLocation = [theEvent locationInWindow];
    NSPoint point = [self convertPoint:eventLocation fromView:nil];
    
    // Get the hit on the earth
    NSArray *hits = [self hitTest:point options:@{SCNHitTestRootNodeKey: self.earthNode,
                                                  SCNHitTestIgnoreChildNodesKey: @YES}];
    
    SCNHitTestResult *hit = [hits firstObject];
    
    // No reason to continue without a hit
    if (!hit) return;
    
    
    // Use the texture coordinate to approximate a location
    CGPoint textureCoordinate = [hit textureCoordinatesWithMappingChannel:0];
    CLLocation *location = [self coordinateFromPoint:textureCoordinate];
    
    [self.geocoder reverseGeocodeLocation:location
                        completionHandler:^(NSArray *placemarks, NSError *error) {
                            CLPlacemark *place = [placemarks firstObject];
                            
                            NSString *placeName = place.country;
                            if (!placeName)
                                placeName = place.ocean;
                            if (!placeName)
                                placeName = place.inlandWater;
                            
                            [self.speech startSpeakingString:placeName];
                        }];
    
    
    // Position the hit where the user clicked
    self.pinNode.position = hit.localCoordinates;
    
    // Calcualte how to rotate the pin so that it points in the
    // same direction as the surface normal at that location.
    GLKVector3 pinDirection = GLKVector3Make(0.0, 1.0, 0.0);
    GLKVector3 normal       = SCNVector3ToGLKVector3(hit.localNormal);
    
    GLKVector3 rotationAxis = GLKVector3CrossProduct(pinDirection, normal);
    CGFloat    cosAngle     = GLKVector3DotProduct(pinDirection, normal);
    
    GLKVector4 rotation = GLKVector4MakeWithVector3(rotationAxis, acos(cosAngle));
    self.pinNode.rotation = SCNVector4FromGLKVector4(rotation);
}


#pragma mark - Lazy initializers

- (SCNNode *)pinNode
{
    if (!_pinNode) {
        // Create a pin with a red head just like the bars in Chapter 3
        // (a pin node that hold both the body node and the head node)
        
        CGFloat bodyHeight = 0.3;
        CGFloat bodyRadius = 0.019;
        CGFloat headRadius = 0.06;
        
        // Create a cylinder and a sphere
        SCNCylinder *body = [SCNCylinder cylinderWithRadius:bodyRadius
                                                     height:bodyHeight];
        SCNSphere *head   = [SCNSphere sphereWithRadius:headRadius];
        
        // Create and assign the two materials
        SCNMaterial *headMaterial = [SCNMaterial material];
        SCNMaterial *bodyMaterial = [SCNMaterial material];
        
        headMaterial.diffuse.contents = [NSColor redColor];
        headMaterial.emission.contents = [NSColor colorWithCalibratedRed:0.2 green:0. blue:0. alpha:1.0];
        bodyMaterial.specular.contents = [NSColor whiteColor];
        bodyMaterial.emission.contents = [NSColor colorWithCalibratedRed:0.1 green:0.1 blue:0.1 alpha:1.0];
        headMaterial.specular.contents = [NSColor whiteColor];
        bodyMaterial.shininess = 100;
        
        head.firstMaterial = headMaterial;
        body.firstMaterial = bodyMaterial;
        
        // Create and position the two nodes
        SCNNode *bodyNode = [SCNNode nodeWithGeometry:body];
        bodyNode.position = SCNVector3Make(0, bodyHeight/2.0, 0.);
        SCNNode *headNode = [SCNNode nodeWithGeometry:head];
        headNode.position = SCNVector3Make(0, bodyHeight, 0.);
        
        // Add them both to the pin node
        SCNNode *pinNode = [SCNNode node];
        [pinNode addChildNode:bodyNode];
        [pinNode addChildNode:headNode];
        
        // Add to the earth
        [self.earthNode addChildNode:pinNode];
        _pinNode = pinNode;
    }
    return _pinNode;
}

- (CLGeocoder *)geocoder
{
    if (!_geocoder) {
        _geocoder = [CLGeocoder new];
    }
    return _geocoder;
}

- (NSSpeechSynthesizer *)speech
{
    if (!_speech) {
        NSString *defaultVoice = [NSSpeechSynthesizer defaultVoice];
        _speech = [[NSSpeechSynthesizer alloc] initWithVoice:defaultVoice];
    }
    return _speech;
}

#pragma mark - Converting to latitude & longitude

- (CLLocation *) coordinateFromPoint:(CGPoint)point
{
    CGFloat u = point.x;
    CGFloat v = point.y;
    
    CLLocationDegrees lat = (0.5-v)*180.0;
    CLLocationDegrees lon = (u-0.5)*360.0;
    
    return [[CLLocation alloc] initWithLatitude:lat
                                      longitude:lon];
}

@end
