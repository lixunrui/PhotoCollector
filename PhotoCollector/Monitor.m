//
//  Monitor.m
//  PhotoCollector
//
//  Created by Raymond Li on 16/1/26.
//  Copyright © 2016年 Raymond Li. All rights reserved.
//

#import "Monitor.h"
#import <AssetsLibrary/AssetsLibrary.h>   
#import "ALAssetsLibrary+CustomPhotoAlbum.h"


@implementation Monitor
{
    ALAssetsLibrary* library;
    NSInteger _interval;
    AVCaptureStillImageOutput* StillImageOutput;
}



- (void) startTimerWithIntervalInSec:(int)interval{
    
    //[self performSelectorInBackground:@selector(saySomething) withObject:nil];
    
    _interval = interval;

    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        NSLog(@"Running in the background");
        [self scheduleNotification];
    }
    else{
        [self scheduleAlertBox];
    }
    
}

- (void)scheduleNotification{
    
    NSLog(@"will appear after %ld", (long)_interval);
    NSTimer* alertTimer = [NSTimer scheduledTimerWithTimeInterval:_interval target:self selector:@selector(sendNotification) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:alertTimer forMode:NSDefaultRunLoopMode];
    
    [[NSRunLoop currentRunLoop]run];
}

- (void)sendNotification
{
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive ) {
        UILocalNotification* photoNitification = [[UILocalNotification alloc]init];
        
        NSDate* current = [NSDate date];
        
        NSLog(@"Will be fired at: %@", [current dateByAddingTimeInterval:_interval]);
        
        photoNitification.fireDate = [current dateByAddingTimeInterval:_interval];
        photoNitification.alertBody = @"Take photos";
        //photoNitification.alertAction = @"Take";
        //photoNitification.hasAction = true;
        photoNitification.category=@"PHOTO";
        photoNitification.soundName = UILocalNotificationDefaultSoundName;
        photoNitification.applicationIconBadgeNumber = 1; // increase by 1
        
        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"object 1", @"key 1", nil];
        
        photoNitification.userInfo = infoDict;
        
        //[[UIApplication sharedApplication] scheduleLocalNotification:photoNitification];
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:photoNitification];
    }
    
}

- (void)scheduleAlertBox{
    
    NSLog(@"will appear after %ld", (long)_interval);
    NSTimer* alertTimer = [NSTimer scheduledTimerWithTimeInterval:_interval target:self selector:@selector(showAlert) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:alertTimer forMode:NSDefaultRunLoopMode];
    
    [[NSRunLoop currentRunLoop]run];
}

- (void)showAlert{
    if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Take photo"
                                                             message:@"Click OK to take photos"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                                   otherButtonTitles:@"OK",nil];
        // dismiss the alert box after 9 seconds
        [self performSelector:@selector(dismissAlertAfterTimeout:) withObject:errorAlert afterDelay:9];
        [errorAlert show];
    }

}


- (void)dismissAlertAfterTimeout: (UIAlertView *)alertView{
    NSLog(@"Auto dismiss");
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    NSLog(@"Index is %li", (long)buttonIndex);
    
    if([title isEqualToString:@"Cancel"])
    {
        NSLog(@"Button 1 was selected.");
    }
    else if([title isEqualToString:@"OK"])
    {
        NSLog(@"Schedule next alert");
        //[self scheduleAlertBox];
    }
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];

}

- (void) takePhotos{
    NSLog(@"Photo taken");
    
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    
    picker.allowsEditing=NO;
    
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    picker.showsCameraControls = NO;
    
    [picker takePicture];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSLog(@"DOne");
    
    UIImage* photo = info[UIImagePickerControllerEditedImage];
    
    
}

- (void)takeCamPhotos{
    AVCaptureSession* captureSession = [[AVCaptureSession alloc]init];
    
    [captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    
    //AVCaptureDevice* imageDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDevice *inputDevice = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for(AVCaptureDevice *camera in devices) {
       // if([camera position] == AVCaptureDevicePositionFront) { // is front camera
            inputDevice = camera;
        NSLog(@"Position is %ld", (long)inputDevice.position);
            break;
       // }
       // else{
            // back camera
            
       // }
        
    }
    
    NSError* error;
    
    AVCaptureDeviceInput* deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    
    if ([captureSession canAddInput:deviceInput]) {
        [captureSession addInput:deviceInput];
    }
    
    
     StillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    
    [StillImageOutput setOutputSettings:outputSettings];
    
    [captureSession addOutput:StillImageOutput];
    
    [captureSession startRunning];
    
    
    
    AVCaptureConnection *videoConnection = nil;
    
    for (AVCaptureConnection *connection in StillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts ]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
    }
    [StillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            NSLog(@"%@", image);
            
           // UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            
            /*
            // The completion block to be executed after image taking action process done
            void (^completion)(NSURL *, NSError *) = ^(NSURL *assetURL, NSError *error) {
                if (error) {
                    NSLog(@"%s: Write the image data to the assets library (camera roll): %@",
                          __PRETTY_FUNCTION__, [error localizedDescription]);
                }
                
                NSLog(@"%s: Save image with asset url %@ (absolute path: %@), type: %@", __PRETTY_FUNCTION__,
                      assetURL, [assetURL absoluteString], [assetURL class]);
                // Add new item to |photos_| & table view appropriately
                //NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.photoURLs.count
    //                                                         inSection:0];
//                [self.photoURLs addObject:assetURL];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.tableView insertRowsAtIndexPaths:@[indexPath]
//                                          withRowAnimation:UITableViewRowAnimationFade];
//                });
            };
            
            void (^failure)(NSError *) = ^(NSError *error) {
                if (error) NSLog(@"%s: Failed to add the asset to the custom photo album: %@",
                                 __PRETTY_FUNCTION__, [error localizedDescription]);
            };
            
            
            library = [[ALAssetsLibrary alloc]init];
            // Save image to custom photo album
            // The lifetimes of objects you get back from a library instance are tied to
            //   the lifetime of the library instance.
            [library saveImage:image
                                  toAlbum:@"Custom Photo Album"
                               completion:completion
                                  failure:failure];
             */
            
            [library saveImage:image toAlbum:@"New" withCompletionBlock:nil];
        }
    }
     ];
}


@end
