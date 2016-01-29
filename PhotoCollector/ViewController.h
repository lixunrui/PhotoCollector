//
//  ViewController.h
//  PhotoCollector
//
//  Created by Raymond Li on 16/1/26.
//  Copyright © 2016年 Raymond Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Monitor.h"

@interface ViewController : UIViewController <UIImagePickerControllerDelegate>

@property bool started;

@property (strong, atomic) Monitor* monitor;
@end

