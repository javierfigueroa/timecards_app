//
//  JAFForgotPasswordViewController.m
//  JAFTimecardPrototype
//
//  Created by killboy7 on 5/4/14.
//  Copyright (c) 2014 Javier Figueroa. All rights reserved.
//

#import "JAFForgotPasswordViewController.h"
#import "JAFButton.h"
#import "JAFTextField.h"
#import "SVProgressHUD.h"
#import "JAFUser.h"

@interface JAFForgotPasswordViewController ()

@end

@implementation JAFForgotPasswordViewController

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
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    UIImage *greenButtonImage = [UIImage imageNamed:@"green-btn"];
    UIImage *stretchableGreenButton = [greenButtonImage stretchableImageWithLeftCapWidth:22 topCapHeight:0];
    [self.forgotPasswordButton setBackgroundImage:stretchableGreenButton forState:UIControlStateNormal];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didSelectPasswordButton:(id)sender {
    if (self.companyTextField.text.length == 0 ||
        self.emailTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"All fields are required"];
        return;
    }
    
    [self.companyTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    
    [SVProgressHUD showWithStatus:@"Resetting..." maskType:SVProgressHUDMaskTypeGradient];
    [JAFUser resetPassword:self.emailTextField.text andCompany:self.companyTextField.text completion:^(JAFUser *user, NSError *error) {
        
        [SVProgressHUD dismiss];
        if (!error) {
            [SVProgressHUD showSuccessWithStatus:@"You will receive an email with instructions about how to reset your password in a few minutes."];
            
        }else{
            [SVProgressHUD showErrorWithStatus:@"Error reseting password, check your web address and email and try again"];
        }
    }];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField  == self.companyTextField) {
        [self.emailTextField becomeFirstResponder];
    }else{
        [self didSelectPasswordButton:nil];
    }
    return YES;
}
@end
