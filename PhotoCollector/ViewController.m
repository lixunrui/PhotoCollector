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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.monitor = [[Monitor alloc] init];
    
    AppDelegate* del = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    // create an Observer
    [[NSNotificationCenter defaultCenter] addObserver:self.monitor selector:@selector(takePhotos) name:@"TakePhotos" object:del];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)didClickStartButton:(id)sender {
    
    [self.monitor startTimerWithIntervalInSec:10];
}
- (IBAction)didClickExitButton:(id)sender {
    exit(0);
}
- (IBAction)didClickPhotoLibraryButton:(id)sender {
}

@end
