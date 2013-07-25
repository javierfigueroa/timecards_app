//
//  JAFSummaryViewController.m
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 7/9/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "JAFSummaryViewController.h"
#import "JAFTimecard.h"
#import "SVProgressHUD.h"

@interface JAFSummaryViewController ()

@end

@implementation JAFSummaryViewController

- (BOOL)clockingIn
{
    return !self.timecard.timestampOut;
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
    self.title = @"Summary";
    [self.submitButton setTitle:([self clockingIn] ? @"CLOCK IN" : @"CLOCK OUT") forState:UIControlStateNormal];
    self.photoImageView.image = [self clockingIn] ? self.timecard.photoIn : self.timecard.photoOut;
    self.gpsLabel.text = [self clockingIn] ?
    [NSString stringWithFormat:@"%@, %@", self.timecard.latitudeIn, self.timecard.longitudeIn] :
    [NSString stringWithFormat:@"%@, %@", self.timecard.latitudeOut, self.timecard.longitudeOut];
    
    NSDate *now = [self clockingIn] ? self.timecard.timestampIn : self.timecard.timestampOut;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm a"];
    
    NSString *time = [formatter stringFromDate:now];
    
    [formatter setDateFormat:@"MMM d, yyyy"];
    NSString *date = [formatter stringFromDate:now];
    
    self.timeLabel.text = time;
    self.dateLabel.text = date;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didPressOk:(id)sender {
    [SVProgressHUD showWithStatus:([self clockingIn] ? @"Clocking in..." : @"Clocking out...")];
    if ([self clockingIn]) {
        [JAFTimecard clockIn:self.timecard completion:^(JAFTimecard *timecard, NSError *error) {
            [SVProgressHUD dismiss];
            if (!error) {
                [self.navigationController popViewControllerAnimated:YES];
                [SVProgressHUD showSuccessWithStatus:@"All set!"];
            }else{
                [SVProgressHUD showErrorWithStatus:@"Something went wrong, please try again or contact administrator"];
            }
        }];
    }else{
        [JAFTimecard clockOut:self.timecard completion:^(JAFTimecard *timecard, NSError *error) {
            [SVProgressHUD dismiss];
            if (!error) {
                self.timecard.timestampIn = nil;
                self.timecard.timestampOut = nil;
                [self.navigationController popViewControllerAnimated:YES];
                [SVProgressHUD showSuccessWithStatus:@"All set!"];
            }else{
                [SVProgressHUD showErrorWithStatus:@"Something went wrong, please try again or contact administrator"];
            }
        }];
    }
}
@end
