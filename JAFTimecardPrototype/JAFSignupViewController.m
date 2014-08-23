//
//  JAFSignupViewController.m
//  JAFTimecardPrototype
//
//  Created by killboy7 on 5/4/14.
//  Copyright (c) 2014 Javier Figueroa. All rights reserved.
//

#import "JAFSignupViewController.h"
#import "JAFButton.h"
#import "JAFTextField.h"
#import "SVProgressHUD.h"
#import "JAFUser.h"

@interface JAFSignupViewController ()

@end

@implementation JAFSignupViewController

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
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    
    UIImage *greenButtonImage = [UIImage imageNamed:@"green-btn"];
    UIImage *stretchableGreenButton = [greenButtonImage stretchableImageWithLeftCapWidth:22 topCapHeight:0];
    [self.signupButton setBackgroundImage:stretchableGreenButton forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didPressSignup:(id)sender {
    if (self.companyNameTextField.text.length == 0 ||
        self.firstNameTextField.text.length == 0 ||
        self.lastNameTextField.text.length == 0 ||
        self.emailTextField.text.length == 0 ||
        self.passwordTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"All fields are required"];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Signing up" maskType:SVProgressHUDMaskTypeGradient];
    [JAFUser signupWithUsername:self.emailTextField.text password:self.passwordTextField.text firstName:self.firstNameTextField.text lastName:self.lastNameTextField.text company:self.companyNameTextField.text completion:^(JAFUser *user, NSError *error) {
        
        [SVProgressHUD dismiss];
        if (!error) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:YES forKey:@"logged_in"];
            [self dismissViewControllerAnimated:YES completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification object:nil];
        }else if ([error userInfo]) {
            NSDictionary *errorData = [error userInfo];
            NSMutableString *errorMessage = [[NSMutableString alloc] init];
            
            for (NSString* key in errorData) {
                if ([key isEqualToString:@"base"]) {
                    [errorMessage appendString:[NSString stringWithFormat:@"%@ \n", errorData[key][0]]];
                }else{
                    [errorMessage appendString:[NSString stringWithFormat:@"%@ %@ \n", key, errorData[key][0]]];
                }
            }

            [SVProgressHUD showErrorWithStatus:errorMessage];
        }else{
            [SVProgressHUD showErrorWithStatus:@"Error logging in, check your information and try again"];
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UIView *view = [self.view viewWithTag:textField.tag + 1];
    if (textField != self.companyNameTextField){
        [view becomeFirstResponder];
    }else{
        [self didPressSignup:nil];
        [textField resignFirstResponder];
    }
    
    return YES;
}

@end
