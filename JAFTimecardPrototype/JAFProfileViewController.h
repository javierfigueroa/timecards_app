//
//  JAFProfileViewController.h
//  JAFTimecardPrototype
//
//  Created by killboy7 on 5/14/14.
//  Copyright (c) 2014 Javier Figueroa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JAFButton;
@class JAFTextField;

@interface JAFProfileViewController : UIViewController

+ (JAFProfileViewController *)controller;

@property (strong, nonatomic) IBOutlet UILabel *profileTitle;
@property (weak, nonatomic) IBOutlet JAFButton *saveButton;
@property (weak, nonatomic) IBOutlet JAFTextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet JAFTextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet JAFTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet JAFTextField *updatePasswordTextField;

- (IBAction)didPressSave:(id)sender;

@end
