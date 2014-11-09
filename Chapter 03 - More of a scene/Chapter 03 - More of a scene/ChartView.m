//
//  ChartView.m
//  Chapter 03 - More of a scene
//
//  Created by David Rönnqvist on 2013-10-30.
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


#import "ChartView.h"

const NSTimeInterval baseAnimationDelay = 1.0;

@interface ChartView ()

@property (nonatomic, weak) SCNNode *chartNode;

@end

@implementation ChartView

- (void)awakeFromNib
{
    
    // An empty scene
    SCNScene *scene = [SCNScene scene];
    self.scene = scene;
    
	// A camera
    // --------
    // The camera is moved back and up from the center of the scene
    // and then rotated so that it looks down to the center
	SCNNode *cameraNode = [SCNNode node];
	cameraNode.camera = [SCNCamera camera];
	cameraNode.position = SCNVector3Make(0, 20, 40);
    cameraNode.rotation = SCNVector4Make(1, 0, 0,
                                         -atan2f(20.0, 45.0));
    
	[scene.rootNode addChildNode:cameraNode];
    
    // A spot light
    // ------------
    // The spot light is positioned right next to the camera
    // so it is offset sligthly and added to the camera node
    SCNLight *spotlight = [SCNLight light];
    spotlight.type  = SCNLightTypeSpot;
    spotlight.color = [NSColor colorWithCalibratedWhite:0.4 alpha:1.0];
    SCNNode *spotlightNode = [SCNNode node];
	spotlightNode.light    = spotlight;
    spotlightNode.position = SCNVector3Make(-30, 25, 30);
    
    // configure the angle of the spotlight
    [spotlight setAttribute:@60  forKey:SCNLightSpotInnerAngleKey];
    [spotlight setAttribute:@100 forKey:SCNLightSpotOuterAngleKey];
	spotlight.castsShadow = YES;
    
    [scene.rootNode addChildNode:spotlightNode];
    
    // make the spotlight look at the center of the scene
	spotlightNode.constraints = @[[SCNLookAtConstraint lookAtConstraintWithTarget:scene.rootNode]];

    
	
    // A directional light
    // -------------------
    // Lights up the scene from the side
    SCNLight *directional = [SCNLight light];
    directional.type  = SCNLightTypeDirectional;
    directional.color = [NSColor colorWithCalibratedWhite:0.3 alpha:1.0];
    SCNNode *directionalNode = [SCNNode node];
    directionalNode.light    = directional;
    directionalNode.rotation = SCNVector4Make(0, 1, 0,
                                              -M_PI_4);
    [scene.rootNode addChildNode:directionalNode];
    
    
    // An ambient light
    // ----------------
    // Helps light up the areas that are not illuminated by the directional light
    SCNLight *ambient = [SCNLight light];
    ambient.type  = SCNLightTypeAmbient;
    ambient.color = [NSColor colorWithCalibratedWhite:0.25 alpha:1.0];
    SCNNode *ambNode = [SCNNode node];
    ambNode.light    = ambient;
    [scene.rootNode addChildNode:ambNode];
    
    
    
    // A reflective floor
    // ------------------
    SCNFloor *floor = [SCNFloor floor];
	// A solid white color, not affected by light
    floor.firstMaterial.diffuse.contents = [NSColor whiteColor];
    floor.firstMaterial.lightingModelName = SCNLightingModelConstant;
    // Less reflective and decrease by distance
    floor.reflectivity = 0.15;
    floor.reflectionFalloffEnd = 15;
	SCNNode *floorNode = [SCNNode nodeWithGeometry:floor];
	[scene.rootNode addChildNode:floorNode];
}



- (void)setNumbers:(NSArray *)numbers
{
	// remove the old nodes first
    [self.chartNode removeFromParentNode];
    
    // add a new chart node
	SCNNode *chartNode = [SCNNode node];
	[self.scene.rootNode addChildNode:chartNode];
    chartNode.position = SCNVector3Make(0, 0.25, 0);
    chartNode.rotation = SCNVector4Make(0, 1, 0,
                                        -M_PI/8.3);
    
	self.chartNode = chartNode; // the numbers will be added to this node

    

    
	const CGFloat barRadius = 2.3;
	const CGFloat margin    = 1.5;
	
    
	// |    |  |    |
	// |____|  |____|
	// :<----->:
	const CGFloat stepLength = barRadius * 2.0 + margin;
	
    
    // one node to hold all the numbers inside the chart node
	SCNNode *numbersNode = [SCNNode node];
    [self.chartNode addChildNode:numbersNode];
	
    
    SCNMaterial *cylinderMaterial = [self cylinderMaterial];
    
    NSNumberFormatter *spellOutFormatter = [NSNumberFormatter new];
    spellOutFormatter.numberStyle = NSNumberFormatterSpellOutStyle;
    
    
    // for each number (as an NSNumber)
    // create a cylinder and a text element
    [numbers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *number = obj;
        
        // create one node to position the cylinder and text along the x-axis
        SCNNode *barNode = [SCNNode node];
		barNode.position = SCNVector3Make(stepLength*idx, 0, 0);
		[numbersNode addChildNode:barNode];
        
		
		// create a cylinder for the actual "bars"
		CGFloat height = [number doubleValue];
		SCNCylinder *cylinder = [SCNCylinder cylinderWithRadius:barRadius
                                                    height:height];
	
		cylinder.firstMaterial = cylinderMaterial;
		SCNNode *cylinderNode = [SCNNode nodeWithGeometry:cylinder];
        cylinderNode.position = SCNVector3Make(0, height/2.0, 0);
        
        [barNode addChildNode:cylinderNode];
        
        
        
        // create a text element to display on top of each bar
		NSString *numberText = [spellOutFormatter stringFromNumber:number];
        SCNText *text = [SCNText textWithString:numberText
                                 extrusionDepth:0.2];
		text.firstMaterial.diffuse.contents = [NSColor colorWithCalibratedWhite:.9 alpha:1.0];
        text.font = [NSFont systemFontOfSize:2.5];
		text.flatness = 0.1;
        
        SCNNode *textNode  = [SCNNode nodeWithGeometry:text];
		// invert the rotation of the chart
		textNode.transform = CATransform3DInvert(self.chartNode.worldTransform);
		// center on top of the bar
        textNode.position =
        SCNVector3Make(-text.textSize.width/2.0,
                       height-.05,
                       0.0);

        [barNode addChildNode:textNode];
        
        
        
        // animate the bar growing as it appears
        NSTimeInterval animationDelay = baseAnimationDelay +  0.5 * idx / (numbers.count + 1.0);
    
        [cylinderNode addAnimation:[self growingCylinderAnimationWithDelay:animationDelay]
                            forKey:@"grow"];
		
		[textNode addAnimation:[self growTextAnimationWithDelay:animationDelay]
                        forKey:@"move text updwards"];
        
	}];
	
    // Center the numbers in the chart
	SCNVector3 boundingBoxMin, boundingBoxMax;
	[numbersNode getBoundingBoxMin:&boundingBoxMin
                               max:&boundingBoxMax];
	
	CGFloat totalWidth = boundingBoxMax.x - boundingBoxMin.x;
    CGFloat middleX = boundingBoxMin.x - totalWidth/2.0;
    
    numbersNode.position = SCNVector3Make(middleX, 0, 0);

    
    // Add an animation that rotates the chart
    [self.chartNode addAnimation:[self chartRotationAnimationWithDelay:baseAnimationDelay]
						  forKey:@"Rotate the entire chart"];
    
}

#pragma mark - Factory methods

/*!
 @param delay The amount of time before the animation begins
 
 @return An animation that rotates the chart
 */
- (CAAnimation *)growingCylinderAnimationWithDelay:(NSTimeInterval)delay
{
    // animate the cylinder, growing from the bottom
    // by changing the height ...
    CABasicAnimation *grow = [CABasicAnimation animationWithKeyPath:@"geometry.height"];
    grow.fromValue = @0.25;
    // ... and the position
    CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position.y"];
    move.fromValue = @0;
    
    // group both animations
    CAAnimationGroup *growGroup = [CAAnimationGroup animation];
    growGroup.animations = @[grow, move];
    growGroup.duration   = 1.0;
    growGroup.beginTime  = CACurrentMediaTime() + delay;
    growGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    growGroup.fillMode = kCAFillModeBackwards;
    
    return growGroup;
}

/*!
 @param delay The amount of time before the animation begins
 
 @return An animation moves the text up as the bars are growing
 */
- (CAAnimation *)growTextAnimationWithDelay:(NSTimeInterval)delay
{
    // as the cylinder grows, the text moves upwards to it's final position
    CABasicAnimation *moveText = [CABasicAnimation animationWithKeyPath:@"position.y"];
    moveText.fromValue = @0;
    moveText.duration  = 1.0;
    moveText.beginTime = CACurrentMediaTime() + delay;
    moveText.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    moveText.fillMode = kCAFillModeBackwards;
    
    return moveText;
}


/*!
 @param delay The amount of time before the animation begins
 
 @return An animation that rotates the chart
 */
- (CAAnimation *)chartRotationAnimationWithDelay:(NSTimeInterval)delay
{
    // animate the rotation of the chart
    CABasicAnimation *rotateChart = [CABasicAnimation animationWithKeyPath:@"rotation.w"];
    rotateChart.fromValue = @(0);
    rotateChart.duration  = 1.5;
	rotateChart.beginTime = CACurrentMediaTime() + delay;
	rotateChart.fillMode  = kCAFillModeBackwards;
    rotateChart.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    return rotateChart;
}


/*!
 @return The blue shiny material that the cylinders use
 */
- (SCNMaterial *)cylinderMaterial
{
    SCNMaterial *material = [SCNMaterial material];
    
    NSColor *lightBlueColor = [NSColor colorWithCalibratedRed:74./255. green:165./255. blue:227./255. alpha:1.0];
    
    material.diffuse.contents  = lightBlueColor;
    material.specular.contents = [NSColor whiteColor];
    material.shininess = 0.15;
    material.locksAmbientWithDiffuse = YES;
    
    return material;
}


@end
