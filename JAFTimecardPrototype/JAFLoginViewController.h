//
//  JAFLoginViewController.h
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 7/9/13.
//  Copyright (c) 2013 Javier Figueroa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAFLoginViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *companyCodeTextField;
@property (weak, nonatomic) IBOutlet UIImageView *companyCodeBg;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *usernameBg;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIImageView *passwordBg;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotButton;

+ (JAFLoginViewController  *)controller;

- (IBAction)didPressGo:(id)sender;
- (IBAction)didPressForgot:(id)sender;
- (IBAction)didPressSignup:(id)sender;

@end
