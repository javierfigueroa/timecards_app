//
//  JAFSignupViewController.h
//  JAFTimecardPrototype
//
//  Created by killboy7 on 5/4/14.
//  Copyright (c) 2014 Javier Figueroa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JAFButton;
@class JAFTextField;

@interface JAFSignupViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet JAFButton *signupButton;
@property (weak, nonatomic) IBOutlet JAFTextField *companyNameTextField;
@property (weak, nonatomic) IBOutlet JAFTextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet JAFTextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet JAFTextField *emailTextField;
@property (weak, nonatomic) IBOutlet JAFTextField *passwordTextField;


- (IBAction)didPressSignup:(id)sender;

@end
