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
const BOOL ShouldExportTexturedSpaceship   = !ShouldUseVideoFromDevicesCamera;

@implementation AppDelegate

- (void)awakeFromNib
{
    // Insert code here to initialize your application
    
    SCNNode *spaceship = [self.sceneView.scene.rootNode childNodeWithName:@"Spaceship"
                                                              recursively:YES];
    
    SCNMaterial *shipMaterial = [SCNMaterial material];
    
    // NSImage objects
    shipMaterial.diffuse.contents  = [NSImage imageNamed:@"diffuse.png"];
    shipMaterial.specular.contents = [NSImage imageNamed:@"specular"];
    
    // CGImageRefs
    NSURL *normalImageURL = [[NSBundle mainBundle] URLForResource:@"normal" withExtension:@"png"];
    NSData *imageData = [NSData dataWithContentsOfURL:normalImageURL];
    CGDataProviderRef imageDataProvider = CGDataProviderCreateWithCFData((__bridge CFDataRef)imageData);
    CGImageRef normalCGImage = CGImageCreateWithPNGDataProvider(imageDataProvider, NULL, YES, kCGRenderingIntentDefault);
    
    shipMaterial.normal.contents = (__bridge id)normalCGImage;
    
    CGImageRelease(normalCGImage);
    CGDataProviderRelease(imageDataProvider);
    
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
    
    
    
    if (ShouldExportTexturedSpaceship) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDesktopDirectory, NSUserDomainMask, YES);
        NSString *desktopPath = [paths firstObject];
        
        NSString *exportPath = [desktopPath stringByAppendingPathComponent:@"Exported Spaceship.dae"];
        NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
        
        BOOL saveWasSuccessful = [self.sceneView.scene writeToURL:exportURL
                                                          options:nil
                                                         delegate:self // for writing images to disk
                                                  progressHandler:^(float totalProgress, NSError *error, BOOL *stop) {
                                                      // Check the `error` argument for errors
                                                      if (error) {
                                                          NSLog(@"Error during export: %@", [error localizedDescription]);
                                                      }
                                                  }];
        
        if (!saveWasSuccessful) {
            // Handle the case where the file wasn't successully saved
            NSLog(@"File couldn't be saved :(");
        }
    }
    
}

- (NSURL *)writeImage:(NSImage *)image withSceneDocumentURL:(NSURL *)documentURL originalImageURL:(NSURL *)originalImageURL
{
    // Depedning on what content was added to the material, different information
    // will be available when exporting the images.
    
    NSString *documentName = [[documentURL lastPathComponent] stringByDeletingPathExtension];
    NSURL *containerDirectory = [documentURL URLByDeletingLastPathComponent];
    // The name of the folder to store the images
    NSURL *imageFolderDirectory = [containerDirectory URLByAppendingPathComponent:[documentName stringByAppendingString:@"_textures"]];
    
    
    // The image is not guaranteed to have a suggested URL
    if (!originalImageURL) {
        // Instead of trying to do anything about it, let the default exported deal with it
        // (which it is very likely to manage well)
        return nil;
    }
    
    
    // The name of this image
    NSString *imageName = [originalImageURL lastPathComponent];

    NSURL *imageURL = [imageFolderDirectory URLByAppendingPathComponent:imageName];
    // It's not guaranteed that the name contained an appropriate file extension
    if (![imageURL pathExtension].length) {
        imageURL = [imageURL URLByAppendingPathExtension:@"png"];
    }
    
    
    // Create the folder to put the images in
    NSError *folderCreationError = nil;
    BOOL folderCreationWasSuccessful = [[NSFileManager defaultManager] createDirectoryAtURL:imageFolderDirectory
                                                                withIntermediateDirectories:NO
                                                                                 attributes:nil
                                                                                      error:&folderCreationError];
    // The documentation says that it's better to try and recover then to check for file existance
    //    " It's far better to attempt an operation (such as loading a file or creating
    //      a directory), check for errors, and handle those errors gracefully than it
    //      is to try to figure out ahead of time whether the operation will succeed.   "
    if (!folderCreationWasSuccessful && folderCreationError.code != NSFileWriteFileExistsError) {
        NSLog(@"Textures folder coudn't be created, with error: %@", [folderCreationError localizedDescription]);
        return nil; // To signal that no image was saved
    }
    
    
    // Attempt to save the image
    NSData *imageData = [image TIFFRepresentation];
    BOOL savingImageWasSuccessful = [imageData writeToFile:[imageURL path]
                                                atomically:YES];
    
    if (!savingImageWasSuccessful) {
        NSLog(@"Could not save image at URL: %@", [imageURL absoluteString]);
        return nil; // To signal that no image was saved
    }
    
    return imageURL; // The URL of the saved image
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
