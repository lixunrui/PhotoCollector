//
//  AppDelegate.m
//  PhotoCollector
//
//  Created by Raymond Li on 16/1/26.
//  Copyright © 2016年 Raymond Li. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // let the os know, that we still need this app running at background
    UIApplication *photoTimer = [UIApplication sharedApplication];
    
    // create background task
    __block UIBackgroundTaskIdentifier bgTask = [photoTimer beginBackgroundTaskWithExpirationHandler:^{
        [photoTimer endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // create a timer based on the parameter which use to fire taking photo event
  /*  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.controller = (ViewController*)self.window.rootViewController;
        
        [self.controller.monitor startTimerWithIntervalInSec:3];
    }); */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    // ask fo permission to send alert
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound|UIUserNotificationTypeBadge categories:nil]];
    }
    
    UIMutableUserNotificationAction *acceptAction =
    [[UIMutableUserNotificationAction alloc] init];
    
    // Define an ID string to be passed back to your app when you handle the action
    acceptAction.identifier = @"ACCEPT_IDENTIFIER";
    
    // Localized string displayed in the action button
    acceptAction.title = @"Take Photos";
    
    // If you need to show UI, choose foreground
    acceptAction.activationMode = UIUserNotificationActivationModeBackground;
    
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
    
    
    
    UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];

    
   
    
    UILocalNotification *notification = [launchOptions valueForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    
    NSLog(@"Did finish lanuch with options");
    if (notification) {
        [self showAlarm:notification.alertBody];
        NSLog(@"AppDelegate didFinishLaunchingWithOptions");
        application.applicationIconBadgeNumber = 0;
    }
 
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
    NSLog(@"Receive anything");
    [self showAlarm:notification.alertBody];
    application.applicationIconBadgeNumber = 0;
    NSLog(@"AppDelegate didReceiveLocalNotification %@", notification.userInfo);

}

- (void) application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())completionHandler{
    
    if ([identifier isEqualToString:@"ACCEPT_IDENTIFIER"]) {
        NSLog(@"Take photoing....");
      //  [self.controller.monitor takePhotos];
       
        // post a notification
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"TakePhotos" object:self]];
    }
    
    completionHandler();
}



- (void)showAlarm:(NSString *)text {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alarm"
                                                        message:text delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
