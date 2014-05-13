//
//  JAFActionsViewController.h
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 7/9/13.
//  Copyright (c) 2013 Javier Figueroa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JAFProject;
@interface JAFActionsViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayOfTheWeekLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *amPmLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLoggedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusArrowImageView;
@property (weak, nonatomic) IBOutlet UILabel *counterLabel;
@property (weak, nonatomic) IBOutlet UIButton *primaryActionButton;
@property (weak, nonatomic) IBOutlet UIButton *secondaryActionButton;
@property (weak, nonatomic) IBOutlet UIImageView *timeLoggedBackgroundImage;
@property (strong, nonatomic) IBOutlet UILabel *coachLabel;
@property (weak, nonatomic) IBOutlet UIImageView *calendarIcon;

@property (strong, nonatomic) IBOutlet UIView *userDetailsView;
@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet UIView *middleView;

+ (JAFActionsViewController*)controller;

- (IBAction)didPressPrimaryAction:(id)sender;
- (IBAction)didPressSecondaryAction:(id)sender;

- (void)setProject:(JAFProject *)project;


@end
