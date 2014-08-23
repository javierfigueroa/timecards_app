//
//  JAFSettingsTableViewController.m
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 5/13/14.
//  Copyright (c) 2014 Javier Figueroa. All rights reserved.
//

#import "JAFSettingsTableViewController.h"
#import "UIViewController+SideMenu.h"
#import "JAFSettingsCell.h"
#import "JAFSettingsService.h"
#import "JAFProfileViewController.h"

@interface JAFSettingsTableViewController ()

@end

@implementation JAFSettingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setSideMenu];
    
    [self.navigationItem setTitleView:self.settingsTitle];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kStopLocationServicesNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self.tableView reloadData];        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 1:
            return 2;
            break;
        default:
            break;
    };
    
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    JAFSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[JAFSettingsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"Edit my profile", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 1: {
            switch (indexPath.row) {
                case 0:{
                    cell.textLabel.text = NSLocalizedString(@"GPS tracking", nil);
                    UISwitch *gpsSwitch = [[UISwitch alloc] init];
                    [gpsSwitch setOn:[[JAFSettingsService service] isTrackingLocation]];
                    [gpsSwitch addTarget:self action:@selector(didSwitchGPS:) forControlEvents:UIControlEventValueChanged];
                    cell.accessoryView = gpsSwitch;
                    break;
                }
                case 1: {
                    cell.textLabel.text = NSLocalizedString(@"Photo", nil);
                    UISwitch *photoSwitch = [[UISwitch alloc] init];
                    [photoSwitch setOn:[[JAFSettingsService service] isPhotoEnabled]];
                    [photoSwitch addTarget:self action:@selector(didSwitchPhoto:) forControlEvents:UIControlEventValueChanged];
                    cell.accessoryView = photoSwitch;
                    break;
                }
                default:
                    break;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return NSLocalizedString(@"Profile Settings", nil);
            break;
        case 1:
            return NSLocalizedString(@"Account & Privacy Settings", nil);
            break;
        default:
            break;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        JAFProfileViewController *profileController = [JAFProfileViewController controller];
        [self.navigationController pushViewController:profileController animated:YES];
    }
}

- (IBAction)didSwitchGPS:(id)sender
{
    UISwitch *gpsSwitch = (UISwitch *)sender;
    if ([gpsSwitch isOn]) {
        [[JAFSettingsService service] resumeLocationServices:nil];
    }else{
        [[JAFSettingsService service] stopLocationServices:nil];
    }
}

- (IBAction)didSwitchPhoto:(id)sender
{
    UISwitch *photoSwitch = (UISwitch *)sender;
    if ([photoSwitch isOn]) {
        [[JAFSettingsService service] setPhotoEnabled:YES];
    }else{
        [[JAFSettingsService service] setPhotoEnabled:NO];
    }
}

@end
