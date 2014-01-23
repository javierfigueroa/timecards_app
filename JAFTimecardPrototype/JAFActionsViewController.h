//
//  JAFActionsViewController.h
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 7/9/13.
//  Copyright (c) 2013 Javier Figueroa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

extern NSString *const kStopLocationServicesNotification;
extern NSString *const kStartLocationServicesNotification;
extern NSString *const kLocationDidChangeNotification;

@interface JAFActionsViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayOfTheWeekLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *middleView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *amPmLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLoggedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusArrowImageView;
@property (weak, nonatomic) IBOutlet UILabel *counterLabel;
@property (weak, nonatomic) IBOutlet UIButton *primaryActionButton;
@property (weak, nonatomic) IBOutlet UIButton *secondaryActionButton;
@property (weak, nonatomic) IBOutlet UIImageView *timeLoggedBackgroundImage;

@property (strong, nonatomic) IBOutlet UILabel *coachLabel;
@property (strong, nonatomic) IBOutlet UIImageView *coachImageView;
@property (weak, nonatomic) IBOutlet UIPickerView *projectsPicker;
@property (weak, nonatomic) IBOutlet UIView *pickerContainerView;
@property (weak, nonatomic) IBOutlet UILabel *pickerTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *pickerCancelButton;
@property (weak, nonatomic) IBOutlet UIButton *pickerAssignButton;

+ (JAFActionsViewController*)controller;

- (IBAction)didPressPrimaryAction:(id)sender;
- (IBAction)didPressSecondaryAction:(id)sender;
- (IBAction)didPressSignOut:(id)sender;
- (IBAction)didPressCancelPicker:(id)sender;
- (IBAction)didAssignProject:(id)sender;


@end
