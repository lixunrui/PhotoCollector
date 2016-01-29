//
//  ConfigurationViewController.m
//  PhotoCollector
//
//  Created by Raymond Li on 16/1/30.
//  Copyright © 2016年 Raymond Li. All rights reserved.
//

#import "ConfigurationViewController.h"

@interface ConfigurationViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtIntervel;
@property (weak, nonatomic) IBOutlet UISwitch *swScreenshot;
@property (weak, nonatomic) IBOutlet UISwitch *swFrontPhoto;
@property (weak, nonatomic) IBOutlet UISwitch *swRearPhoto;

@end

@implementation ConfigurationViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //default data
    _storeData = [[NSDictionary alloc]initWithObjectsAndKeys:
                 [NSNumber numberWithInt:10],@"interval",
                 [NSNumber numberWithInt:1],@"screenshot",
                 [NSNumber numberWithInt:1],@"front",
                 [NSNumber numberWithInt:1],@"rear" ,
                 nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)swScreenshotChanged:(id)sender {
    UISwitch* currentSwitch = (UISwitch*)sender;
    
    if ([currentSwitch isOn]) {
        [_storeData setValue:[NSNumber numberWithInt:1] forKey:@"screenshot"];
    }
    else{
        [_storeData setValue:[NSNumber numberWithInt:0] forKey:@"screenshot"];

    }
}

- (IBAction)swFrontPhotoChanged:(id)sender {
    UISwitch* currentSwitch = (UISwitch*)sender;
    
    if ([currentSwitch isOn]) {
        [_storeData setValue:[NSNumber numberWithInt:1] forKey:@"front"];
    }
    else{
        [_storeData setValue:[NSNumber numberWithInt:0] forKey:@"front"];
        
    }
}

- (IBAction)swRearPhoto:(id)sender {
    UISwitch* currentSwitch = (UISwitch*)sender;
    
    if ([currentSwitch isOn]) {
        [_storeData setValue:[NSNumber numberWithInt:1] forKey:@"rear"];
    }
    else{
        [_storeData setValue:[NSNumber numberWithInt:0] forKey:@"rear"];
    }
}

- (IBAction)didChangeInterval:(id)sender {
    
    UITextField* text = (UITextField*)sender;
    
    [_storeData setValue:text.text forKey:@"interval"];
}


@end
