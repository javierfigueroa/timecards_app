//
//  JAFSummaryViewController.h
//  JAFTimecardPrototype
//
//  Created by killboy7 on 5/18/14.
//  Copyright (c) 2014 Javier Figueroa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JAFTitleLabel;
@interface JAFSummaryViewController : UIViewController

@property (weak, nonatomic) IBOutlet JAFTitleLabel *hoursLabel;
@property (weak, nonatomic) IBOutlet JAFTitleLabel *earningsLabel;

@property (weak, nonatomic) IBOutlet JAFTitleLabel *toLabel;
@property (weak, nonatomic) IBOutlet JAFTitleLabel *fromLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)didSelectSegment:(id)sender;
+ (JAFSummaryViewController*)controller;

@end
