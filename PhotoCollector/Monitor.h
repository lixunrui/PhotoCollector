//
//  Monitor.h
//  PhotoCollector
//
//  Created by Raymond Li on 16/1/26.
//  Copyright © 2016年 Raymond Li. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface Monitor : NSObject <UIAlertViewDelegate>
- (void) startTimerWithIntervalInSec:(int)interval;

- (void) takePhotos;
@end
