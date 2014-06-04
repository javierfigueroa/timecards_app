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
@property (nonatomic, strong) JAFSummary *thisPeriod;
@property (nonatomic, strong) JAFSummary *yearToDate;
@end

@implementation JAFSummaryViewController


+ (JAFSummaryViewController *)controller
{
    return [[JAFSummaryViewController alloc] initWithNibName:@"JAFSummaryViewController" bundle:nil];
}

- (JAFSummary *)thisPeriod
{
    return [[JAFTimecardService service] thisPeriod];
}

- (JAFSummary *)yearToDate
{
    return [[JAFTimecardService service] yearToDate];
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
   
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(didSelectSegment:)];
    self.navigationItem.rightBarButtonItem = refresh;
    
    if (self.thisPeriod == nil) {
        [self setThisPeriodSummary];
    }else{
        [self setSummaryView:self.thisPeriod];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh
{
    
}

- (IBAction)didSelectSegment:(id)sender {
    BOOL refresh = [sender isKindOfClass:[UIBarButtonItem class]];
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:{
            if (refresh || self.thisPeriod == nil) {
                [self setThisPeriodSummary];
            }else{
                [self setSummaryView:self.thisPeriod];
            }
            break;
        }
        case 1: {
            if (refresh || self.yearToDate == nil) {
                [self setYearToDateSummary];
            }else{
                [self setSummaryView:self.yearToDate];
            }
            break;
        }
        default:
            break;
    }
}

- (void)setThisPeriodSummary
{
    NSDate *now = [[NSDate new] nextDay];
    NSDate *twoWeeksAgo = [now twoWeeksAgo];
    JAFUser *user = [[JAFSettingsService service] getLoggedUser];
    
    [self getSummaryFrom:twoWeeksAgo to:now forUser:user andCompletion:^(JAFSummary *summary) {
        self.thisPeriod = summary;
    }];
}

- (void)setYearToDateSummary
{
    
    NSDate *now = [[NSDate new] nextDay];
    NSDate *yearStart = [now yearToDate];
    JAFUser *user = [[JAFSettingsService service] getLoggedUser];
    
    [self getSummaryFrom:yearStart to:now forUser:user andCompletion:^(JAFSummary *summary) {
        self.yearToDate = summary;
    }];

}

- (void)getSummaryFrom:(NSDate *)from to:(NSDate *)to forUser:(JAFUser *)user andCompletion:(void (^)(JAFSummary *))block
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [[JAFTimecardService service] getSummaryFrom:from to:to forUserId:user.ID andCompletion:^(JAFSummary *summary, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            summary.from = from;
            summary.to = to;
            [self setSummaryView:summary];
            if(block) {
                block(summary);
            }
        }
        
    }];
}

- (void)setSummaryView:(JAFSummary*)summary
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yy"];
    
    self.fromLabel.text = [formatter stringFromDate:summary.from];
    self.toLabel.text = [formatter stringFromDate:summary.to];
    self.hoursLabel.text = [summary getTimeString];
    self.earningsLabel.text = [NSString stringWithFormat:@"%.02f", summary.earnings];
}

@end
