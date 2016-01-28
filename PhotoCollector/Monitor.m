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


#define CustomPhotoAlbumName @"New Album"

const NSInteger kConditionLockWaiting = 0;
const NSInteger kConditionLockShouldProceed = 1;


@implementation Monitor
{
    ALAssetsLibrary* library;
    NSInteger _interval;
    AVCaptureStillImageOutput* StillImageOutput;
    AVCaptureSession* captureSession;
    NSConditionLock* camlock ;
    NSConditionLock* photoLock;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initLibrary];
        camlock = [[NSConditionLock alloc]initWithCondition:kConditionLockWaiting];
       // [self initCapture];
    }
    return self;
}

- (void)initLibrary{
    library = [[ALAssetsLibrary alloc]init];
    
    [library loadAssetsForProperty:ALAssetPropertyAssetURL fromAlbum:CustomPhotoAlbumName completion:^(NSMutableArray *array, NSError *error) {
        NSLog(@"Completed");
    }];
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

- (void)takeCamPhotoOn:(NSInteger)position{
    captureSession = [[AVCaptureSession alloc]init];
    
    [captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDevice* inputDevice = nil;
    for(AVCaptureDevice *camera in devices) {
        if (camera.position == position) {
            inputDevice = camera;
            if ([inputDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
                if ([inputDevice lockForConfiguration:nil]) {
                    [inputDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
                    [inputDevice unlockForConfiguration];
                }
            }
            break;
        }
    }
    
         //   [inputDevice addObserver:self forKeyPath:@"adjustingWhiteBalance" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
            
            NSLog(@" camera %@", inputDevice.localizedName);
            
            NSError* error;
            
            AVCaptureDeviceInput* deviceInputFront = nil;
            if (inputDevice != nil) {
                deviceInputFront = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
            }
            
            //[captureSession beginConfiguration];
          //  NSLog(@"add into session");
            if ([captureSession canAddInput:deviceInputFront]) {
                [captureSession addInput:deviceInputFront];
            }
            
            StillImageOutput = [[AVCaptureStillImageOutput alloc] init];
            
            NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
            
            [StillImageOutput setOutputSettings:outputSettings];
            NSLog(@"set up output");
            if ([captureSession canAddOutput:StillImageOutput]) {
                [captureSession addOutput:StillImageOutput];
            }
          
            
            if (![captureSession isRunning]) {
                [captureSession startRunning];
            }
    
    [NSThread sleepForTimeInterval:0.3];
    [self take];
    
    //[camlock lockWhenCondition:kConditionLockShouldProceed];
}

- (void)takeBackPhoto{
    [self takeCamPhotoOn:AVCaptureDevicePositionBack];
}

- (void)takeFrontPhoto{
    [self takeCamPhotoOn:AVCaptureDevicePositionFront];
}

- (void)takeScreenShot{
    
}

- (void) takePhotos{

    [self takeBackPhoto];
    [self takeFrontPhoto];
    [self takeScreenShot];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
   
    AVCaptureDevice* device = (AVCaptureDevice*)object;
    NSLog(@"object is %@", device.localizedName);
    
    NSLog(@"path is %@", keyPath);
    NSLog(@"old change s %@", change[@"old"]);
    NSLog(@"new change s %@", change[@"new"]);
    
    if ([keyPath isEqualToString:@"adjustingWhiteBalance"]) {
 
        
        if ( [[change objectForKey:@"old"] boolValue] == YES &&
            [[change objectForKey:@"new"] boolValue] == NO) {
            
            //[self take];
            NSLog(@"Remove observer");
            
          //  [camlock unlockWithCondition:kConditionLockShouldProceed];
            [device removeObserver:self forKeyPath:@"adjustingWhiteBalance"];
        }
    }
}
    
    
- (void)take{
    
    NSLog(@"Take");
    AVCaptureConnection *videoConnection = nil;
    
    for (AVCaptureConnection *connection in StillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts ]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
    }
    
    __block bool completed = false;
    
    [StillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer != NULL) {
 
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            NSLog(@"%@", image);
            
            // The completion block to be executed after image taking action process done
            void (^completion)(NSURL *, NSError *) = ^(NSURL *assetURL, NSError *error) {
                if (error) {
                    NSLog(@"%s: Write the image data to the assets library (camera roll): %@",
                          __PRETTY_FUNCTION__, [error localizedDescription]);
                }
                
                NSLog(@"%s: Save image with asset url %@ (absolute path: %@), type: %@", __PRETTY_FUNCTION__,
                      assetURL, [assetURL absoluteString], [assetURL class]);
               // NSLog(@"release camlock");
              //  [camlock unlockWithCondition:kConditionLockShouldProceed];
                [captureSession stopRunning];
                completed = true;
            };
            
            void (^failure)(NSError *) = ^(NSError *error) {
                if (error) NSLog(@"%s: Failed to add the asset to the custom photo album: %@",
                                 __PRETTY_FUNCTION__, [error localizedDescription]);
                completed = true;
            };
            
           
            [library saveImage:image
                       toAlbum:CustomPhotoAlbumName
                    completion:completion
                       failure:failure];
            
        }
    }
     ];
    
    // should wait here until the block is completed

}

@end
