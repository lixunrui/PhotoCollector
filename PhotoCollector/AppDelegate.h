//
//  AppDelegate.h
//  PhotoCollector
//
//  Created by Raymond Li on 16/1/26.
//  Copyright © 2016年 Raymond Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "Monitor.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController* controller;
@property (strong, nonatomic) Monitor* monitor;


@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;

@end

