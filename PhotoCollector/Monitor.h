//
//  Monitor.h
//  PhotoCollector
//
//  Created by Raymond Li on 16/1/26.
//  Copyright © 2016年 Raymond Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@import UIKit;
@import AVFoundation;

@interface Monitor : NSObject <UIAlertViewDelegate, UINavigationControllerDelegate ,UIImagePickerControllerDelegate>

- (instancetype)initWith:(UIViewController*)view;

- (void) startTimerWithIntervalInSec:(int)interval;

- (void) takePhotos;

@end
