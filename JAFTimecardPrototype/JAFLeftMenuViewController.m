//
//  JAFLeftMenuViewController.m
//  JAFTimecardPrototype
//
//  Created by killboy7 on 5/10/14.
//  Copyright (c) 2014 Javier Figueroa. All rights reserved.
//

#import "JAFLeftMenuViewController.h"
#import "JAFActionsViewController.h"
#import "REFrostedViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "JAFTimecardService.h"
#import "JAFLoginViewController.h"
#import "JAFAppDelegate.h"
#import "JAFSettingsTableViewController.h"

@interface JAFLeftMenuViewController ()

//@property (strong, readwrite, nonatomic) UITableView *tableView;

@end

@implementation JAFLeftMenuViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 184.0f)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        imageView.image = [[JAFTimecardService service] getAvatar];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 50.0;
        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        imageView.layer.borderWidth = 3.0f;
        imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        imageView.layer.shouldRasterize = YES;
        imageView.clipsToBounds = YES;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 0, 24)];
        label.text = [[JAFTimecardService service] getName];
        label.font = [UIFont fontWithName:@"OpenSans-Bold" size:21];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
        [label sizeToFit];
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [view addSubview:imageView];
        [view addSubview:label];
        view;
    });
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:34/255.0f green:44/255.0f blue:51/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"OpenSans-Regular" size:17];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return nil;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 34)];
    view.backgroundColor = [UIColor colorWithRed:167/255.0f green:167/255.0f blue:167/255.0f alpha:0.6f];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 0, 0)];
    label.text = @"Friends Online";
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return 0;
    
    return 34;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:{
            //timecard
            JAFAppDelegate *appDelegate = (JAFAppDelegate*)[[UIApplication sharedApplication] delegate];
            self.frostedViewController.contentViewController = appDelegate.actionsController;
            [self.frostedViewController hideMenuViewController];
            break;
        }
        case 1:
            //history
            [self.frostedViewController hideMenuViewController];
            break;
        case 2:{
            //settings
            UINavigationController *settingsController = [[UINavigationController alloc] initWithRootViewController:[[JAFSettingsTableViewController alloc] init]];
            self.frostedViewController.contentViewController = settingsController;
            [self.frostedViewController hideMenuViewController];
            break;
        }
        case 3:
            //sign out
            [self.frostedViewController hideMenuViewController];
            [self didPressSignOut];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSArray *titles = @[@"Timecard", @"History", @"Settings", @"Sign out"];
    NSArray *images = @[@"IconHome", @"IconCalendar", @"IconSettings", @"IconEmpty"];
    cell.textLabel.text = titles[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:images[indexPath.row]];
    
    return cell;
}


#pragma mark -
#pragma mark - UIAlert delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: {//sign out
            [[JAFTimecardService service] clearTimecard];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:NO forKey:@"logged_in"];
            [self showLoginController];
            break;
        }
        default:
            break;
    }
}

- (IBAction)didPressSignOut
{
    UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Sign Out", nil) otherButtonTitles:nil];
    [alert showInView:self.frostedViewController.contentViewController.view];
}

- (void)showLoginController
{
    JAFAppDelegate *appDelegate = (JAFAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate showLoginController];
}

@end
