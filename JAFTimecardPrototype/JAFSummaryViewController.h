//
//  JAFSummaryViewController.h
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 7/9/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JAFTimecard;
@interface JAFSummaryViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *gpsLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) JAFTimecard *timecard;
- (IBAction)didPressOk:(id)sender;

@end
