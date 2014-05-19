//
//  JAFSummaryViewController.m
//  JAFTimecardPrototype
//
//  Created by killboy7 on 5/18/14.
//  Copyright (c) 2014 Javier Figueroa. All rights reserved.
//

#import "JAFSummaryViewController.h"
#import "UIViewController+SideMenu.h"
#import "JAFTimecard.h"
#import "JAFTimecardService.h"
#import "JAFTitleLabel.h"
#import "JAFSummary.h"
#import "NSDate+Timecards.h"
#import "JAFSettingsService.h"
#import "JAFUser.h"

@interface JAFSummaryViewController ()

@end

@implementation JAFSummaryViewController


+ (JAFSummaryViewController *)controller
{
    return [[JAFSummaryViewController alloc] initWithNibName:@"JAFSummaryViewController" bundle:nil];
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
    // Do any additional setup after loading the view.
    [self setSideMenu];
    self.navigationItem.titleView = self.segmentedControl;
   
    [self setThisPeriodSummary];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)didSelectSegment:(id)sender {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:{
            [self setThisPeriodSummary];
            break;
        }
        case 1: {
            [self setYearToDateSummary];
            break;
        }
        default:
            break;
    }
}

- (void)setThisPeriodSummary
{
    NSDate *now = [NSDate new];
    NSDate *twoWeeksAgo = [now twoWeeksAgo];
    JAFUser *user = [[JAFSettingsService service] getLoggedUser];
    [self getSummaryFrom:now to:twoWeeksAgo forUser:user];
}

- (void)setYearToDateSummary
{
    
    NSDate *now = [NSDate new];
    NSDate *yearStart = [now yearToDate];
    JAFUser *user = [[JAFSettingsService service] getLoggedUser];
    
    [self getSummaryFrom:now to:yearStart forUser:user];

}

- (void)getSummaryFrom:(NSDate *)from to:(NSDate *)to forUser:(JAFUser *)user
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [[JAFTimecardService service] getSummaryFrom:to to:from forUserId:user.ID andCompletion:^(JAFSummary *summary, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM/dd/yy"];
            
            self.fromLabel.text = [formatter stringFromDate:to];
            self.toLabel.text = [formatter stringFromDate:from];
            self.hoursLabel.text = [summary getTimeString];
            self.earningsLabel.text = [NSString stringWithFormat:@"%.02f", summary.earnings];
        }
        
    }];
}

@end
