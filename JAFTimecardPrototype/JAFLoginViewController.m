//
//  JAFLoginViewController.m
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 7/9/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "JAFLoginViewController.h"
#import "SVProgressHUD.h"
#import "JAFAPIClient.h"
#import "JAFUser.h"

@interface JAFLoginViewController ()

@end

@implementation JAFLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didPressGo:(id)sender {
    if (self.companyCodeTextField.text.length == 0 ||
        self.usernameTextField.text.length == 0 ||
        self.passwordTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"All fields are required"];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Logging in" maskType:SVProgressHUDMaskTypeGradient];
    [JAFAPIClient setAPIDomain:self.companyCodeTextField.text];
    [JAFUser login:self.usernameTextField.text andPassword:self.passwordTextField.text completion:^(JAFUser *user, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:YES forKey:@"logged_in"];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }else{
            [SVProgressHUD showErrorWithStatus:@"Error logging in, check your username and password and try again"];
        }
    }];
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return  YES;
}

@end
