//
//  JAFActionsViewController.m
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 7/9/13.
//  Copyright (c) 2013 Javier Figueroa. All rights reserved.
//

#import "JAFActionsViewController.h"
#import "JAFLoginViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "JAFTimecard.h"
#import "SVProgressHUD.h"
#import "JAFUser.h"
#import "JAFProject.h"
#import "JAFProjectsViewController.h"
#import "JAFTimecardService.h"
#import "REFrostedViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "JAFAppDelegate.h"

NSString *const kStartLocationServicesNotification = @"kStartLocationServicesNotification";
NSString *const kStopLocationServicesNotification = @"kStopLocationServicesNotification";
NSString *const kLocationDidChangeNotification = @"kLocationDidChangeNotification";
@interface JAFActionsViewController ()
{
    NSTimer *timer;
    UIAlertView *_locationServicesAlert;
}

@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) JAFTimecardService *timecardService;

@end


@implementation JAFActionsViewController

+ (JAFActionsViewController*)controller
{
    return [[JAFActionsViewController alloc] initWithNibName:@"TimecardViewController" bundle:nil];
}

- (JAFTimecardService *)timecardService
{
    return [JAFTimecardService service];
}

- (void)setProject:(JAFProject *)project
{
    [self.timecardService assignProject:project andBlock:^(JAFTimecard *timecard, NSError *error) {
        if (!error) {
            [SVProgressHUD showSuccessWithStatus:@"Project assigned"];
            [self configureSecondaryButton];
        }else{
            [SVProgressHUD showErrorWithStatus:@"Something went wrong, try again later"];
        }
    }];
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
    self.location = self.locationManager.location;
    [self configureView];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isLoggedIn = [userDefaults boolForKey:@"logged_in"];
    if (!isLoggedIn) {
        [self showLoginController];
    }else{
        [self getTimecard];
        [self startTimer];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTimecard) name:kUserLoggedInNotification object:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getProjects];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)configureView
{
    [self.navigationItem setTitleView:self.userDetailsView];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(presentLeftMenuViewController:)];
    
    UIImage *greenButtonImage = [UIImage imageNamed:@"green-btn"];
    UIImage *stretchableGreenButton = [greenButtonImage stretchableImageWithLeftCapWidth:22 topCapHeight:0];
    [self.primaryActionButton setBackgroundImage:stretchableGreenButton forState:UIControlStateNormal];
    [self addRoundAvatar:self.avatarImageView.image];
    
    UIImage *whiteButtonImage = [UIImage imageNamed:@"white-btn-left"];
    UIImage *stretchableWhiteButton = [whiteButtonImage stretchableImageWithLeftCapWidth:22 topCapHeight:0];
    [self.secondaryActionButton setBackgroundImage:stretchableWhiteButton forState:UIControlStateNormal];
    self.secondaryActionButton.hidden = YES;
    self.secondaryActionButton.alpha = 0;
    
    UIImage *greenOutlinedButtonImage = [UIImage imageNamed:@"green-outlined-btn"];
    UIImage *stretchableOutlinedGreenButton = [greenOutlinedButtonImage stretchableImageWithLeftCapWidth:22 topCapHeight:0];
    [self.timeLoggedBackgroundImage setImage:stretchableOutlinedGreenButton];
    self.dateLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:self.dateLabel.font.pointSize];
    self.dayOfTheWeekLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:self.dayOfTheWeekLabel.font.pointSize];
    self.nameLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:self.nameLabel.font.pointSize];
    self.amPmLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:self.amPmLabel.font.pointSize];
    self.coachLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:self.coachLabel.font.pointSize];
    self.timeLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:self.timeLabel.font.pointSize];
    self.timeLoggedLabel.font = [UIFont fontWithName:@"OpenSans" size:self.timeLoggedLabel.font.pointSize];
}

- (void)getTimecard
{
    if (![self.timecardService clockedIn]) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    }
    
    [self.timecardService getTimecardWithBlock:^(JAFTimecard *timecard, NSError *error) {
        [SVProgressHUD dismiss];
        [self setState];
    }];
}

- (void)getProjects
{
    [self.timecardService getProjectsWithBlock:^{
        [self configureSecondaryButton];
    }];
}

- (void)configureSecondaryButton
{
    if ([self.timecardService clockedIn] && [self.timecardService hasProjects]) {
        self.secondaryActionButton.hidden = NO;
        self.secondaryActionButton.alpha = 1;
    }
    
    if ([self.timecardService hasProject]) {
        [self.secondaryActionButton setTitle:[self.timecardService getProjectName]
                                    forState:UIControlStateNormal];
    }
}

- (void)showLoginController
{
    JAFAppDelegate *appDelegate = (JAFAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate showLoginController];
}

#pragma mark - Actions

- (IBAction)didPressPrimaryAction:(id)sender {
    [self openImagePickerControllerWithType:UIImagePickerControllerSourceTypeCamera inController:self];
}

- (IBAction)didPressSecondaryAction:(id)sender {
    if (![self.timecardService hasProjects]) {
        [self getProjects];
    }else{
        JAFProjectsViewController *projectsController = [[JAFProjectsViewController alloc]
                                                         initWithProjects:[self.timecardService getProjects]];
        projectsController.actionsController = self;
        [self.navigationController pushViewController:projectsController animated:YES];
    }
}

- (IBAction)presentLeftMenuViewController:(id)sender
{
    [self.frostedViewController presentMenuViewController];
}

#pragma mark - Accessors

- (CLLocationManager *)locationManager
{
    if (!_locationManager && [CLLocationManager locationServicesEnabled]) {
		_locationManager = [[CLLocationManager alloc] init];
		[_locationManager setDelegate:self];
		[_locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopLocationServices:) name:kStopLocationServicesNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeLocationServices:) name:kStartLocationServicesNotification object:nil];
        
		NSAssert(_locationManager != nil, @"Datasource should have a location manager if location services are enabled");
	}
    
    return _locationManager;
}

#pragma mark - CLLocation Manage Delegate

- (void)stopLocationServices:(NSNotification *)notification
{
	NSLog(@"Stopping location services");
	[self.locationManager stopMonitoringSignificantLocationChanges];
}

- (void)resumeLocationServices:(NSNotificationCenter *)notification
{
	NSLog(@"Resuming location services");
	[self.locationManager startMonitoringSignificantLocationChanges];
    
	NSLog(@"%@", self.locationManager.location);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	self.location = newLocation;
    
    if (_locationServicesAlert) {
        [_locationServicesAlert dismissWithClickedButtonIndex:0 animated:YES];
        _locationServicesAlert = nil;
    }
    
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    [userInfo setObject:[NSNumber numberWithDouble:self.location.coordinate.latitude] forKey:@"latitude"];
    [userInfo setObject:[NSNumber numberWithDouble:self.location.coordinate.longitude] forKey:@"longitude"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationDidChangeNotification object:self userInfo:userInfo];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	if (error.code == kCLErrorDenied) {
		[self showLocationServicesDisabledAlert];
	}
}

- (void)showLocationServicesDisabledAlert
{
	if ((self.locationManager.location.coordinate.latitude == 0) &&
		(self.locationManager.location.coordinate.longitude == 0)) {
        NSString *app = NSBundle.mainBundle.infoDictionary  [@"CFBundleDisplayName"];
        NSString *message = [NSString stringWithFormat:@"Please enable Location \n Services for %@, go to: \n Privacy -> Location -> %@", app, app];
        
		_locationServicesAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Disabled Location Services", @"Disabled Location Services") message:NSLocalizedString(message, message) delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [_locationServicesAlert show];
	}
}

- (void)openImagePickerControllerWithType:(UIImagePickerControllerSourceType)type inController:(UIViewController*)controller
{
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
		[imagePicker setSourceType:type];
        imagePicker.cameraDevice=UIImagePickerControllerCameraDeviceFront;
		[imagePicker setAllowsEditing:YES];
		[imagePicker setDelegate:self];
        
		[controller presentViewController:imagePicker animated:YES completion:nil];
	}
}

#pragma mark - Image Picker Delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get images
    UIImage *image	= info[UIImagePickerControllerEditedImage];
    
    // Remove views
    [picker dismissViewControllerAnimated:YES completion:^{
        [SVProgressHUD showWithStatus:([self.timecardService clockedIn] ? @"Clocking out..." : @"Clocking in...") maskType:SVProgressHUDMaskTypeGradient];
        
        [self.timecardService clockWithLocation:self.location picture:image andBlock:^(JAFTimecard *timecard, NSError *error) {
            if (!error) {
                [SVProgressHUD showSuccessWithStatus:@"All set!"];
                
                [self setState];
                
                if (timer) {
                    [timer invalidate];
                }else{
                    [self startTimer];
                }
            }else{
                [SVProgressHUD showErrorWithStatus:@"Something went wrong, please try again or contact administrator"];
            }
        }];
    }];
}

#pragma mark - Interface Manipulation

- (void)setState
{
    self.nameLabel.text = [self.timecardService getName];
    
    //make invisible
    self.coachLabel.alpha = 0;
    self.calendarIcon.hidden = NO;
    
    [self setTimecardValues];
    
    if ([self.timecardService clockedIn]) {
        //show middle view
        self.statusArrowImageView.image = [UIImage imageNamed:@"green-arrow-icon"];
        self.secondaryActionButton.hidden = ![self.timecardService hasProjects];
        [self.secondaryActionButton setTitle:@"assign project" forState:UIControlStateNormal];
        [self.primaryActionButton setTitle:@"clock out" forState:UIControlStateNormal];
        UIImage *greenButtonImage = [UIImage imageNamed:@"red-btn"];
        UIImage *stretchableGreenButton = [greenButtonImage
                                           stretchableImageWithLeftCapWidth:22 topCapHeight:0];
        [self.primaryActionButton setBackgroundImage:stretchableGreenButton
                                            forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.coachLabel.alpha = 0;
            //make visible
            self.middleView.alpha = 1;
            self.primaryActionButton.hidden = NO;
            self.userDetailsView.hidden = NO;
            self.dateView.hidden = NO;
            self.middleView.hidden = NO;
        } completion:nil];
    }else{
        //Add coach elements if not existent
        if (![self.view.subviews containsObject:self.coachLabel]) {
            [self.view addSubview:self.coachLabel];
        }
        
        self.middleView.hidden = YES;
        self.secondaryActionButton.hidden =  YES;
        self.statusArrowImageView.image = [UIImage imageNamed:@"red-arrow-icon"];
        UIImage *greenButtonImage = [UIImage imageNamed:@"green-btn"];
        UIImage *stretchableGreenButton = [greenButtonImage
                                           stretchableImageWithLeftCapWidth:22 topCapHeight:0];
        [self.primaryActionButton setTitle:@"clock in" forState:UIControlStateNormal];
        [self.primaryActionButton setBackgroundImage:stretchableGreenButton
                                            forState:UIControlStateNormal];
        
        //show coach elements below date
        CGRect middleFrame = self.middleView.frame;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        //set label in the middle of the screen
        CGRect labelFrame = CGRectMake((screenRect.size.width / 2) - (self.coachLabel.frame.size.width/2), middleFrame.origin.y, self.coachLabel.frame.size.width, self.coachLabel.frame.size.height);
        self.coachLabel.frame = labelFrame;
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            //hide time view
            self.middleView.alpha = 0;
            //make visible
            self.coachLabel.alpha = 1;
            self.primaryActionButton.alpha = 1;
            self.primaryActionButton.hidden = NO;
            self.userDetailsView.hidden = NO;
            self.dateView.hidden = NO;
        } completion:nil];
    }
    
    [self configureSecondaryButton];
}

- (void)addRoundAvatar:(UIImage *)img
{
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContextWithOptions(self.avatarImageView.bounds.size, NO, 0.0);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:self.avatarImageView.bounds
                                cornerRadius:20.0] addClip];
    // Draw your image
    [img drawInRect:self.avatarImageView.bounds];
    
    // Get the image, here setting the UIImageView image
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    self.avatarImageView.image = img;
}

- (void)setTimecardValues
{
    //set avatar image
    [self addRoundAvatar:[self.timecardService getAvatar]];
    
    //set time values
    self.timeLabel.text = [self.timecardService getTimeValue];
    self.amPmLabel.text = [self.timecardService getAbbrevValue];
    
    //set date value
    self.dayOfTheWeekLabel.text = [self.timecardService getDayOfTheWeekValue];
    self.dateLabel.text = [self.timecardService getDateValue];
    [self setTimeCounter];
}


-(void)setTimeCounter
{
    self.counterLabel.text = [self.timecardService getLoggedTimeValue];
}

- (void)startTimer
{
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(setTimeCounter) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}
@end
