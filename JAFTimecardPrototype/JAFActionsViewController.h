//
//  JAFActionsViewController.h
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 7/9/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

extern NSString *const kStopLocationServicesNotification;
extern NSString *const kStartLocationServicesNotification;
extern NSString *const kLocationDidChangeNotification;

@interface JAFActionsViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *clockInButton;
@property (weak, nonatomic) IBOutlet UIButton *clockOutButton;

- (IBAction)didPressClockIn:(id)sender;
- (IBAction)didPressClockOut:(id)sender;
- (IBAction)didPressSignOut:(id)sender;


@end
