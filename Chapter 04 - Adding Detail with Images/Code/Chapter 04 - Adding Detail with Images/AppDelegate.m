//
//  AppDelegate.m
//  Chapter 04 - Adding Detail with Images
//
//  Created by David Rönnqvist on 2014-07-20.
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
@import AVFoundation;

const BOOL ShouldUseVideoFromDevicesCamera = NO; // Change to YES to enable video as reflection

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    SCNNode *spaceship = [self.sceneView.scene.rootNode childNodeWithName:@"Spaceship"
                                                              recursively:YES];
    
    SCNMaterial *shipMaterial = [SCNMaterial material];
    
    // NSImage objects
    shipMaterial.diffuse.contents  = [NSImage imageNamed:@"diffuse"];
    shipMaterial.specular.contents = [NSImage imageNamed:@"specular"];
    
    // File names
    shipMaterial.normal.contents   = @"normal";
    
    // Paths
    shipMaterial.emission.contents = [[NSBundle mainBundle] pathForResource:@"emission" ofType:@"png"];
    
    // URLs
    shipMaterial.multiply.contents = [[NSBundle mainBundle] URLForResource:@"multiply" withExtension:@"png"];
    
    // Layers
    if (ShouldUseVideoFromDevicesCamera) {
        shipMaterial.reflective.contents = [self videoPreviewLayer];
        shipMaterial.fresnelExponent = 0.5; // slighly less reflections
    }
    
    spaceship.geometry.materials = @[shipMaterial];
}

- (CALayer *)videoPreviewLayer
{
    NSError *inputError = nil;
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice
                                                                             error:&inputError];
    if (!videoInput) {
        // Look at `inputError` for information about the error
        NSLog(@"Failed to get video input, with error: %@", [inputError localizedDescription]);
        return nil;
    }
    
    AVCaptureSession *captureSession = [AVCaptureSession new];
    if ([captureSession canAddInput:videoInput]) {
        [captureSession addInput:videoInput];
    } else {
        // Handle the case where there is no input to work with
        NSLog(@"Can't add video input to capture session.");
        return nil;
    }
    
    CGFloat textureSize = 256.0;
    AVCaptureVideoPreviewLayer *cameraPreview = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    // A layer that should be used as a texture needs an explicit size
    cameraPreview.frame = CGRectMake(0, 0, textureSize, textureSize);
    
    [captureSession startRunning];
    
    return cameraPreview;
}

@end
