//
//  PieChartView.m
//  Chapter 03 - Pie Chart
//
//  Created by David Rönnqvist on 08/06/14.
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


#import "PieChartView.h"

@interface PieChartView ()
@property (strong) SCNNode *chartNode;
@end

@implementation PieChartView

- (void)awakeFromNib
{
    // An empty scene
    SCNScene *scene = [SCNScene scene];
    self.scene = scene;
    
    // A camera
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.position = SCNVector3Make(0, 0, 30);
    [scene.rootNode addChildNode:cameraNode];
    
    self.allowsCameraControl = YES;
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
  
    
    CGFloat sum = [[numbers valueForKeyPath:@"@sum.self"] doubleValue];
    NSPoint center = NSMakePoint(0, 0);
    CGFloat radius = 12.0;
    
    __block CGFloat startAngle = 0.0;
    
    // for each number (as an NSNumber)
    [numbers enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        NSNumber *number = obj;
    
        CGFloat segmentAngle = 360 * [number doubleValue]/sum;
        CGFloat endAngle = startAngle + segmentAngle;
        
        // create the path
        NSBezierPath *segmentPath = [NSBezierPath bezierPath];
        [segmentPath moveToPoint:center];
        [segmentPath appendBezierPathWithArcWithCenter:center
                                                radius:radius
                                            startAngle:startAngle
                                              endAngle:startAngle+segmentAngle];
        [segmentPath closePath];
        segmentPath.flatness = 0.05;
        
        // create the shape
        CGFloat shapeThickness = 3.0;
        SCNShape *segmentShape = [SCNShape shapeWithPath:segmentPath
                                          extrusionDepth:shapeThickness];
        segmentShape.chamferRadius = 0.3;
        SCNNode *segmentNode = [SCNNode nodeWithGeometry:segmentShape];
        [chartNode addChildNode:segmentNode];
        
        
        // draw attention to one of the shapes by moving it
        // away from the center of the pie chart
        if (index == 1) {
            CGFloat midAngle = (startAngle + endAngle)/2.0;
            midAngle = midAngle * M_PI / 180.0; // to radians
            
            CGFloat explodeDistance = 2.5;
            segmentNode.position = SCNVector3Make(explodeDistance * cos(midAngle),
                                                  explodeDistance * sin(midAngle),
                                                  0.0);
        }
        
        
        // give each segment a unique color
        CGFloat hue = index * 1.0/[numbers count];
        NSColor *color = [NSColor colorWithCalibratedHue:hue
                                              saturation:1.0
                                              brightness:1.0
                                                   alpha:1.0];
        
        segmentShape.firstMaterial.diffuse.contents  = color;
        segmentShape.firstMaterial.specular.contents = [NSColor darkGrayColor];
        
        // increment the start angle for the next iteration
        startAngle = endAngle;
    }];
}

@end
