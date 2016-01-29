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
    NSArray *devices ;
    int currentDeviceIndex;
    UIViewController* parentView;
    NSTimer* notificationTimer ;
}


- (instancetype)initWith:(UIViewController*)view
{
    self = [super init];
    if (self) {
        [self initNotification];
        [self initLibrary];
        parentView = view;
    }
    return self;
}

- (void)initLibrary{
    library = [[ALAssetsLibrary alloc]init];
    
    NSLog(@"Load album");
    
    [library loadAssetsForProperty:ALAssetPropertyAssetURL fromAlbum:CustomPhotoAlbumName completion:^(NSMutableArray *array, NSError *error) {
    }];
    
    devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
}

- (void) startTimerWithIntervalInSec:(int)interval{
    
    //[self performSelectorInBackground:@selector(saySomething) withObject:nil];
    
    _interval = interval;

    //if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        NSLog(@"Running in the background");
        [self scheduleNotification];
  //  }
  ///  else{
   ///     NSLog(@"Running in the foreground");
     //   [self scheduleAlertBox];
//    }
    
}

- (void)initNotification{
    
    UIMutableUserNotificationAction *acceptAction =
    [[UIMutableUserNotificationAction alloc] init];
    
    // Define an ID string to be passed back to your app when you handle the action
    acceptAction.identifier = @"ACCEPT_IDENTIFIER";
    
    // Localized string displayed in the action button
    acceptAction.title = @"Take Photos";
    
    // If you need to show UI, choose foreground
    acceptAction.activationMode =  UIUserNotificationActivationModeBackground;
    
    //UIUserNotificationActivationModeForeground;

    
    
    // Destructive actions display in red
    acceptAction.destructive = NO;
    
    // Set whether the action requires the user to authenticate
    acceptAction.authenticationRequired = NO;
    
    
    // First create the category
    UIMutableUserNotificationCategory *inviteCategory =
    [[UIMutableUserNotificationCategory alloc] init];
    
    // Identifier to include in your push payload and local notification
    inviteCategory.identifier = @"PHOTO";
    
    // Add the actions to the category and set the action context
    [inviteCategory setActions:@[acceptAction]
                    forContext:UIUserNotificationActionContextDefault];
    
    // Set the actions to present in a minimal context
    [inviteCategory setActions:@[acceptAction]
                    forContext:UIUserNotificationActionContextMinimal];
    
    
    NSSet *categories = [NSSet setWithObjects:inviteCategory, nil];
    
    
    
    UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:categories];
    
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
}

- (void)scheduleNotification{
    
    NSLog(@"will appear after %ld", (long)_interval);
    notificationTimer = [NSTimer scheduledTimerWithTimeInterval:_interval target:self selector:@selector(sendNotification) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:notificationTimer forMode:NSDefaultRunLoopMode];
    
    [[NSRunLoop currentRunLoop]run];
}

- (void)sendNotification
{
    currentDeviceIndex = 0;
    
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive ) {
        UILocalNotification* photoNitification = [[UILocalNotification alloc]init];
        
        NSDate* current = [NSDate date];
        
        NSLog(@"Status is %ld", (long)[[UIApplication sharedApplication] applicationState]);
        
        NSLog(@"Will be fired at: %@", [current dateByAddingTimeInterval:_interval]);
        
     //   photoNitification.fireDate = [current dateByAddingTimeInterval:_interval];
        photoNitification.alertBody = @"Take photos";
        //photoNitification.alertAction = @"Take";
        //photoNitification.hasAction = true;
        photoNitification.category=@"PHOTO";
        photoNitification.soundName = UILocalNotificationDefaultSoundName;
        //photoNitification.applicationIconBadgeNumber = 1; // increase by 1
        
        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"object 1", @"key 1", nil];
        
        photoNitification.userInfo = infoDict;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:photoNitification];
        
        //[[UIApplication sharedApplication] presentLocalNotificationNow:photoNitification];
    }
    else{
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Take photo"
                                                             message:@"Click OK to take photos"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                                   otherButtonTitles:@"OK",nil];
        // dismiss the alert box after 9 seconds
        [self performSelector:@selector(dismissAlertAfterTimeout:) withObject:errorAlert afterDelay:9];
        [errorAlert show];
//        NSLog(@"End the task for notification");
//        [notificationTimer invalidate];
//        
//        [self startTimerWithIntervalInSec:(int)_interval];
    }
}

- (void)scheduleAlertBox{
    
    NSLog(@"will appear after %ld", (long)_interval);
    notificationTimer = [NSTimer scheduledTimerWithTimeInterval:_interval target:self selector:@selector(showAlert) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:notificationTimer forMode:NSDefaultRunLoopMode];
    
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
    else{
        
        NSLog(@"End the task for Alert");
        
        [notificationTimer invalidate];
        
        [self startTimerWithIntervalInSec:(int)_interval];
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
        [self takePhotos];
    }
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];

}

- (void)takeCamPhotoOn:(AVCaptureDevice*)currentDevice{
    
    // init the session
    captureSession = [[AVCaptureSession alloc]init];
    
    [captureSession setSessionPreset:AVCaptureSessionPresetPhoto];

    if ([currentDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
        if ([currentDevice lockForConfiguration:nil]) {
            [currentDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
            [currentDevice unlockForConfiguration];
             }
        
        if ([currentDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            if ([currentDevice lockForConfiguration:nil]) {
                [currentDevice setFocusMode:AVCaptureFocusModeAutoFocus];
                [currentDevice unlockForConfiguration];
            }
        }
    }
    
    NSLog(@" camera %@", currentDevice.localizedName);
            
    NSError* error;
            
    AVCaptureDeviceInput* deviceInputFront = nil;
    if (currentDevice != nil) {
        deviceInputFront = [AVCaptureDeviceInput deviceInputWithDevice:currentDevice error:&error];
    }

    if ([captureSession canAddInput:deviceInputFront]) {
        [captureSession addInput:deviceInputFront];
    }
            
    StillImageOutput = [[AVCaptureStillImageOutput alloc] init];
            
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
            
    [StillImageOutput setOutputSettings:outputSettings];
    
    if ([captureSession canAddOutput:StillImageOutput]) {
        [captureSession addOutput:StillImageOutput];
    }
          
            
    if (![captureSession isRunning]) {
        [captureSession startRunning];
    }
    
    // put a delay to give the cam enought time to stablize
    // or using KVO to monitor, but this KVO is using Asyn call, which needs to implete thread wait and lock
    [NSThread sleepForTimeInterval:0.5];
    
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
            
            [self saveImage:image];
        }
    }
    ];
}

- (void)saveImage:(UIImage*)image{
    // The completion block to be executed after image taking action process done
    void (^completion)(NSURL *, NSError *) = ^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"%s: Write the image data to the assets library (camera roll): %@",
                  __PRETTY_FUNCTION__, [error localizedDescription]);
        }
        
        NSLog(@"%s: Save image with asset url %@ (absolute path: %@), type: %@", __PRETTY_FUNCTION__,
              assetURL, [assetURL absoluteString], [assetURL class]);
  
        NSLog(@"device number is %lu with current index is %d", (unsigned long)devices.count, currentDeviceIndex);
        
        dispatch_async(dispatch_get_main_queue(), ^{
        if (devices.count > currentDeviceIndex) {
            [captureSession stopRunning];
            [self takeCamPhotoOn:devices[currentDeviceIndex]];
            currentDeviceIndex++;
        }
        });
        
        
    };
    
    void (^failure)(NSError *) = ^(NSError *error) {
        if (error) NSLog(@"%s: Failed to add the asset to the custom photo album: %@",
                         __PRETTY_FUNCTION__, [error localizedDescription]);
    };
    
    [library saveImage:image
               toAlbum:CustomPhotoAlbumName
            completion:completion
               failure:failure];
}

- (void)takePhotos{
    
    // take screenhot first
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(parentView.view.window.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(parentView.view.window.bounds.size);
    
    [parentView.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
//    CGSize screenSize = [[UIScreen mainScreen] applicationFrame].size;
//    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
//    CGContextRef ctx = CGBitmapContextCreate(nil, screenSize.width, screenSize.height, 8, 4*(int)screenSize.width, colorSpaceRef, kCGImageAlphaPremultipliedLast);
//    CGContextTranslateCTM(ctx, 0.0, screenSize.height);
//    CGContextScaleCTM(ctx, 1.0, -1.0);
//    
//    [(CALayer*)parentView.view.layer renderInContext:ctx];
//    
//    CGImageRef cgImage = CGBitmapContextCreateImage(ctx);
//    UIImage *image = [UIImage imageWithCGImage:cgImage];
//    
   [self saveImage:image];
//    
    
//    // create graphics context with screen size
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    UIGraphicsBeginImageContext(screenRect.size);
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    [[UIColor blackColor] set];
//    CGContextFillRect(ctx, screenRect);
//    
//    // grab reference to our window
//    NSArray* wins = [UIApplication sharedApplication].windows;
//
//    
//    // transfer content into our context
//    [window.layer renderInContext:ctx];
//    UIImage *screengrab = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    [self saveImage:screengrab];
    
}


@end
