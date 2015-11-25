/*

File: ControllerImageCapture.m

Abstract: Uses Image Capture for discovery of devices and download of
          device images.

Version: 1.1

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
Computer, Inc. ("Apple") in consideration of your agreement to the
following terms, and your use, installation, modification or
redistribution of this Apple software constitutes acceptance of these
terms.  If you do not agree with these terms, please do not use,
install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software. 
Neither the name, trademarks, service marks or logos of Apple Computer,
Inc. may be used to endorse or promote products derived from the Apple
Software without specific prior written permission from Apple.  Except
as expressly stated in this notice, no other rights or licenses, express
or implied, are granted by Apple herein, including but not limited to
any patent rights that may be infringed by your derivative works or by
other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright © 2008-2009 Apple Inc., All Rights Reserved

*/

#import <Quartz/Quartz.h>
#import "Controller.h"
#import "ControllerImageCapture.h"
#import "ControllerBrowsing.h"


@implementation Controller(ImageCapture)

- (IBAction)showImageCaptureUI: (id)sender
{
    // if we don't have a window yet, load it from the nib file
    if (NULL == imageCaptureWindow)
    {
        if (![NSBundle loadNibNamed: @"ImageCapture"
                              owner: self])
        {
            NSLog(@"    could not load ImageCapture.nib");
            return;
        }
    }
    
    // show image capture window
    [imageCaptureWindow makeKeyAndOrderFront: self];
    
    // we don't want a postProcessing application
    cameraView.postProcessApplication = NULL;
    scannerView.postProcessApplication = NULL;
}


- (void)deviceBrowserView: (IKDeviceBrowserView*)deviceBrowserView
       selectionDidChange: (ICDevice*)device
{
    if ((device.type & ICDeviceTypeCamera) == ICDeviceTypeCamera)
    {
        // if a camera got selected, display the camera tab
        [tabView selectTabViewItemWithIdentifier: @"Camera"];
        
        // set the camera device, clear scanner device
        [cameraView setCameraDevice: (ICCameraDevice*)device];
        [scannerView setScannerDevice: 0];
        
    } else if ((device.type & ICDeviceTypeScanner) == ICDeviceTypeScanner)
    {
        // if a scanner got selected, display the scanner tab
        [tabView selectTabViewItemWithIdentifier: @"Scanner"];

        // clear camera device, set the scanner device
        [scannerView setScannerDevice: (ICScannerDevice*)device];
        [cameraView setCameraDevice: 0];
    }
}


- (IBAction)rotateLeft: (id)sender
{
    // pass through to the camera view
    [cameraView rotateLeft: sender];
}


- (IBAction)rotateRight: (id)sender
{
    // pass through to the camera view
    [cameraView rotateRight: sender];
}


- (void)cameraDeviceView: (IKCameraDeviceView *)cameraDeviceView
         didDownloadFile: (ICCameraFile*)file
                location: (NSURL *)url
                fileData: (NSData *)data
                   error: (NSError*)error
{
    if (error == NULL)
    {
        // by default we are using the 'IKCameraDeviceViewTransferModeFileBased' mode
        // so check for the url...
        if (url)
        {
            NSString * path = [url path];
            
            //add it to our datasource
            [self addImageWithPath: path];
            
            //reflect changes
            [imageBrowser reloadData];
        }
    }    
}


- (void)scannerDeviceView: (IKScannerDeviceView *)scannerDeviceView
             didScanToURL: (NSURL *)url
                 fileData: (NSData *)data
                    error: (NSError*)error
{
    if (error == NULL)
    {
        // by default we are using the 'IKScannerDeviceViewTransferModeFileBased' mode
        // so check for the url...
        if (url)
        {
            NSString * path = [url path];
            
            //add it to our datasource
            [self addImageWithPath: path];
            
            //reflect changes
            [imageBrowser reloadData];
        }
    }    
}
@end

