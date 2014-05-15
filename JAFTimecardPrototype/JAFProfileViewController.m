//
//  JAFProfileViewController.m
//  JAFTimecardPrototype
//
//  Created by killboy7 on 5/14/14.
//  Copyright (c) 2014 Javier Figueroa. All rights reserved.
//

#import "JAFProfileViewController.h"
#import "JAFButton.h"
#import "JAFTextField.h"
#import "JAFUser.h"

@interface JAFProfileViewController ()

@end

@implementation JAFProfileViewController

+ (JAFProfileViewController *)controller
{
    return [[JAFProfileViewController alloc] initWithNibName:@"JAFProfileViewController" bundle:nil];
}

- (JAFUser *)user
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *myEncodedObject = [userDefaults objectForKey:@"user"];
    return [NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
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
    
    [self.navigationItem setTitleView:self.profileTitle];
    UIImage *greenButtonImage = [UIImage imageNamed:@"green-btn"];
    UIImage *stretchableGreenButton = [greenButtonImage stretchableImageWithLeftCapWidth:22 topCapHeight:0];
    [self.saveButton setBackgroundImage:stretchableGreenButton forState:UIControlStateNormal];
    
    
    JAFUser *user = [self user];
    self.firstNameTextField.text = user.firstName;
    self.lastNameTextField.text = user.lastName;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)didPressSave:(id)sender {
    
    JAFUser *user = [self user];
    [JAFUser updateWithPassword:self.passwordTextField.text newPassword:self.updatePasswordTextField.text firstName:self.firstNameTextField.text lastName:self.lastNameTextField.text email:user.username completion:^(JAFUser *user, NSError *error) {
        
        
    }];
}
@end
