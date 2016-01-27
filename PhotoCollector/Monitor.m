//
//  Monitor.m
//  PhotoCollector
//
//  Created by Raymond Li on 16/1/26.
//  Copyright © 2016年 Raymond Li. All rights reserved.
//

#import "Monitor.h"
#import <AssetsLibrary/AssetsLibrary.h>


@implementation Monitor
{
    ALAssetsLibrary* library;
}

- (void) startMonitorWithIntervalInSec{
   // NSLog(@"Cancel all notifications");
   // [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification* photoNitification = [[UILocalNotification alloc]init];
    
    photoNitification.fireDate = nil;
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

- (void) startTimerWithIntervalInSec:(int)interval{
    NSTimer* backgroundTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(showTakePhotoRequest) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:backgroundTimer forMode:NSDefaultRunLoopMode];
    
    [[NSRunLoop currentRunLoop] run];
}



- (void) showTakePhotoRequest{
    NSLog(@"Calling here");
    [self startMonitorWithIntervalInSec];
//    
//    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
//        NSLog(@"Running in the background");
//        [self startMonitorWithIntervalInSec:1];
//    }
//    else
//    {
//        NSLog(@"Running in the foreground");
//    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Take photo"
//                                                         message:@"Click OK to take photos"
//                                                        delegate:self
//                                               cancelButtonTitle:@"Cancel"
//                                               otherButtonTitles:@"OK",nil];
//    
//    [self performSelector:@selector(dismissAlertAfterTimeout:) withObject:errorAlert afterDelay:1];
//    [errorAlert show];
//    }
 
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
        NSLog(@"Button 2 was selected.");
    }

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


@end
