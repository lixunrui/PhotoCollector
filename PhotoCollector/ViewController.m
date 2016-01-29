//
//  ViewController.m
//  PhotoCollector
//
//  Created by Raymond Li on 16/1/26.
//  Copyright © 2016年 Raymond Li. All rights reserved.
//

#import "ViewController.h"
#import "Monitor.h"
#import "AppDelegate.h"

@interface ViewController ()



@end

@implementation ViewController
{
    //Monitor* monitor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"view did load");
    // Do any additional setup after loading the view, typically from a nib.
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    self.monitor = [[Monitor alloc] initWith:self];
   
    AppDelegate* del = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    del.controller = self;
    
    self.started = false;
    
    
    
    // create an Observer
    [[NSNotificationCenter defaultCenter] addObserver:self.monitor selector:@selector(takePhotos) name:@"TakePhotos" object:del];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didClickStartButton:(id)sender {

    if (self.started == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
        [self.monitor startTimerWithIntervalInSec:20];
        });
        self.started = YES;
    }
    
}

@end
