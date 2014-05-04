//
//  JAFLoginViewController.m
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 7/9/13.
//  Copyright (c) 2013 Javier Figueroa. All rights reserved.
//

#import "JAFLoginViewController.h"
#import "SVProgressHUD.h"
#import "JAFAPIClient.h"
#import "JAFUser.h"
#import "JAFForgotPasswordViewController.h"

@interface JAFLoginViewController ()

@property (nonatomic) CGRect originalCompanyTextFrame;
@property (nonatomic) CGRect originalUsernameTextFrame;
@property (nonatomic) CGRect originalPasswordTextFrame;

@end

@implementation JAFLoginViewController

+ (JAFLoginViewController *)controller
{
    return [[JAFLoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
}

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
    
    self.navigationController.navigationBarHidden = YES;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *myEncodedObject = [userDefaults objectForKey:@"user"];
    JAFUser *user = [NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
    if (user) {
        self.companyCodeTextField.text = user.company;
        self.usernameTextField.text = user.username;
    }
    
    [self registerForKeyboardNotifications];
    
    UIImage *greenButtonImage = [UIImage imageNamed:@"green-btn"];
    UIImage *stretchableGreenButton = [greenButtonImage stretchableImageWithLeftCapWidth:22 topCapHeight:0];
    [self.signInButton setBackgroundImage:stretchableGreenButton forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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

- (IBAction)didPressGo:(id)sender {
    if (self.companyCodeTextField.text.length == 0 ||
        self.usernameTextField.text.length == 0 ||
        self.passwordTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"All fields are required"];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Logging in" maskType:SVProgressHUDMaskTypeGradient];
    [JAFUser login:self.usernameTextField.text andPassword:self.passwordTextField.text andCompany:self.companyCodeTextField.text completion:^(JAFUser *user, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:YES forKey:@"logged_in"];
            [self dismissViewControllerAnimated:YES completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification object:nil];
            
        }else{
            [SVProgressHUD showErrorWithStatus:@"Error logging in, check your username and password and try again"];
        }
    }];
    
    
}

- (IBAction)didPressForgot:(id)sender {
    JAFForgotPasswordViewController *passwordController = [[JAFForgotPasswordViewController alloc] initWithNibName:@"JAFForgotPasswordViewController" bundle:nil];
    [self.navigationController pushViewController:passwordController animated:YES];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self slideTextFieldsUp:kbSize.height];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self slideDownTextFields:kbSize.height];
}

- (void)slideTextFieldsUp:(int)offset
{
    if (CGRectEqualToRect(CGRectZero, self.originalCompanyTextFrame)) {
        self.originalCompanyTextFrame = self.companyCodeTextField.frame;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveLinear | UIViewAnimationOptionCurveEaseIn animations:^{
            int padding = self.titleLabel.frame.size.height + 30;
            self.companyCodeTextField.frame = CGRectOffset(self.companyCodeTextField.frame, 0, -offset + padding);
            self.usernameTextField.frame = CGRectOffset(self.usernameTextField.frame, 0, -offset + padding);
            self.passwordTextField.frame = CGRectOffset(self.passwordTextField.frame, 0, -offset + padding);
            self.logoImageView.frame = CGRectOffset(self.logoImageView.frame, 0, -offset + padding);
            
            self.companyCodeBg.frame = CGRectOffset(self.companyCodeBg.frame, 0, -offset + padding);
            self.usernameBg.frame = CGRectOffset(self.usernameBg.frame, 0, -offset + padding);
            self.passwordBg.frame = CGRectOffset(self.passwordBg.frame, 0, -offset + padding);
            self.titleLabel.frame = CGRectOffset(self.titleLabel.frame, 0, -offset + padding);
            
//            self.logoImageView.alpha = 0;
            self.signInButton.alpha = 0;
            self.forgotButton.alpha = 0;
            
        } completion:^(BOOL finished) {
//            self.logoImageView.hidden = YES;
            self.signInButton.hidden = YES;
            self.forgotButton.hidden = YES;
        }];
    }
}

- (void)slideDownTextFields:(int)offset
{
    if (!CGRectEqualToRect(CGRectZero, self.originalCompanyTextFrame)) {
        self.originalCompanyTextFrame = CGRectZero;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            int padding = self.titleLabel.frame.size.height + 30;
            self.companyCodeTextField.frame = CGRectOffset(self.companyCodeTextField.frame, 0, offset - padding);
            self.usernameTextField.frame = CGRectOffset(self.usernameTextField.frame, 0, offset - padding);
            self.passwordTextField.frame = CGRectOffset(self.passwordTextField.frame, 0, offset - padding);
            self.companyCodeBg.frame = CGRectOffset(self.companyCodeBg.frame, 0, offset - padding);
            self.logoImageView.frame = CGRectOffset(self.logoImageView.frame, 0, offset - padding);
            self.usernameBg.frame = CGRectOffset(self.usernameBg.frame, 0, offset - padding);
            self.passwordBg.frame = CGRectOffset(self.passwordBg.frame, 0, offset - padding);
            self.titleLabel.frame = CGRectOffset(self.titleLabel.frame, 0, offset - padding);
            
//            self.logoImageView.alpha = 1;
            self.signInButton.alpha = 1;
            self.forgotButton.alpha = 1;
            
        } completion:^(BOOL finished) {
//            self.logoImageView.hidden = NO;
            self.signInButton.hidden = NO;
            self.forgotButton.hidden = NO;
        }];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return  YES;
}

@end
