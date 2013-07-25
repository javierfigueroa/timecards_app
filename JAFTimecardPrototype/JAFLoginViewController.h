//
//  JAFLoginViewController.h
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 7/9/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAFLoginViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *companyCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)didPressGo:(id)sender;
@end
