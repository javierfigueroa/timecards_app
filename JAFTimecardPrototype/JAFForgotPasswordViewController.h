//
//  JAFForgotPasswordViewController.h
//  JAFTimecardPrototype
//
//  Created by killboy7 on 5/4/14.
//  Copyright (c) 2014 Javier Figueroa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JAFButton;
@class JAFTextField;

@interface JAFForgotPasswordViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet JAFTextField *emailTextField;

@property (weak, nonatomic) IBOutlet JAFTextField *companyTextField;
@property (weak, nonatomic) IBOutlet JAFButton *forgotPasswordButton;
- (IBAction)didSelectPasswordButton:(id)sender;
@end
