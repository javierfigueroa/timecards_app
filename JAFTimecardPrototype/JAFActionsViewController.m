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
@property (nonatomic, strong) JAFTimecard *timecard;
@property (nonatomic, strong) NSArray *projects;

@end


@implementation JAFActionsViewController

+ (JAFActionsViewController*)controller
{
    return [[JAFActionsViewController alloc] initWithNibName:@"TimecardViewController" bundle:nil];
}

- (void)setProject:(JAFProject *)project
{
    _project = project;
    
    [JAFTimecard assignProject:self.timecard projectID:project.ID completion:^(JAFTimecard *timecard, NSError *error) {
        if (!error) {
            [SVProgressHUD showSuccessWithStatus:@"Project assigned"];
            [self.secondaryActionButton setTitle:project.name forState:UIControlStateNormal];
            [self didPressCancelPicker:nil];
        }else{
            [[[UIAlertView alloc] initWithTitle:@"Project not assigned" message:@"Something went wrong, try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
    self.timecard = [[JAFTimecard alloc] init];
    self.location = self.locationManager.location;
    
    [self configureView];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isLoggedIn = [userDefaults boolForKey:@"logged_in"];
    if (!isLoggedIn) {
        [self showLoginController];
    }else{
        [self getTimecard];
        [self getProjects];
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
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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
    if (![self isClockedIn] && self.timecard) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    }
    
    [JAFTimecard getTodaysTimecardWithCompletion:^(JAFTimecard *timecard, NSError *error) {
        [SVProgressHUD dismiss];
        
        if (error) {
            [SVProgressHUD showErrorWithStatus:@"Server unavailable, try again later"];
        }
        
        if (!timecard) {
            self.timecard = [[JAFTimecard alloc] init];
        }else{
            self.timecard = timecard;
        }
        
        [self setState];
    }];
}

- (void)getProjects
{
    [JAFProject getProjectsWithCompletion:^(NSArray *projects, NSError *error) {
        if (!error) {
            self.projects = [NSArray arrayWithArray:projects];
            [self configureSecondaryButton];
        }
    }];
}

- (void)configureSecondaryButton
{
    if ([self isClockedIn] && self.projects.count > 0) {
        self.secondaryActionButton.hidden = NO;
        self.secondaryActionButton.alpha = 1;
    }
    
    if (self.timecard.projectID != (id)[NSNull null] && [self.timecard.projectID intValue] > 0) {
        for(JAFProject *project in self.projects) {
            BOOL exists = self.project ? [project.ID intValue] == [self.project.ID intValue] : [project.ID intValue] == [self.timecard.projectID intValue];
            if (exists) {
                [self.secondaryActionButton setTitle:project.name forState:UIControlStateNormal];
                break;
            }
        }
    }
}

- (BOOL)isClockedIn
{
    return self.timecard.timestampIn != nil;
}

- (void)showLoginController
{
    JAFLoginViewController *loginController = [JAFLoginViewController controller];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginController];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - Actions

- (IBAction)didPressPrimaryAction:(id)sender {
    [self openImagePickerControllerWithType:UIImagePickerControllerSourceTypeCamera inController:self];
}

- (IBAction)didPressSecondaryAction:(id)sender {
    if (self.projects.count == 0) {
        [self getProjects];
    }else{
        JAFProjectsViewController *projectsController = [[JAFProjectsViewController alloc] initWithProjects:self.projects];
        projectsController.actionsController = self;
        [self.navigationController pushViewController:projectsController animated:YES];
    }
}


- (IBAction)didPressSignOut:(id)sender {
    UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Sign Out", nil) otherButtonTitles:nil];
    [alert showInView:self.view];
}

- (IBAction)didPressCancelPicker:(id)sender {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.pickerContainerView.alpha = 0;
    } completion:^(BOOL finished) {
        
        self.pickerContainerView.hidden = YES;
    }];
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
        [SVProgressHUD showWithStatus:([self isClockedIn] ? @"Clocking out..." : @"Clocking in...") maskType:SVProgressHUDMaskTypeGradient];
        if ([self isClockedIn]) {
            self.timecard.timestampOut = [NSDate date];
            self.timecard.latitudeOut = [NSNumber numberWithDouble:self.location.coordinate.latitude];
            self.timecard.longitudeOut = [NSNumber numberWithDouble:self.location.coordinate.longitude];
            self.timecard.photoOut = image;
            
            [JAFTimecard clockOut:self.timecard completion:^(JAFTimecard *timecard, NSError *error) {
                [SVProgressHUD dismiss];
                if (!error) {
                    self.timecard.timestampIn = nil;
                    self.timecard.timestampOut = nil;
                    [SVProgressHUD showSuccessWithStatus:@"All set!"];
                    [self setState];
                    if (timer) {
                        [timer invalidate];
                    }
                }else{
                    [SVProgressHUD showErrorWithStatus:@"Something went wrong, please try again or contact administrator"];
                }
            }];
        }else{
            self.timecard.timestampIn = [NSDate date];
            self.timecard.latitudeIn = [NSNumber numberWithDouble:self.location.coordinate.latitude];
            self.timecard.longitudeIn = [NSNumber numberWithDouble:self.location.coordinate.longitude];
            self.timecard.photoIn = image;
            
            [JAFTimecard clockIn:self.timecard completion:^(JAFTimecard *timecard, NSError *error) {
                [SVProgressHUD dismiss];
                if (!error) {
                    self.timecard = timecard;
                    [SVProgressHUD showSuccessWithStatus:@"All set!"];
                    [self setState];
                    [self startTimer];
                    
                }else{
                    [SVProgressHUD showErrorWithStatus:@"Something went wrong, please try again or contact administrator"];
                }
            }];
        }
    }];
}

#pragma mark - Interface Manipulation

- (void)setState
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *myEncodedObject = [userDefaults objectForKey:@"user"];
    JAFUser *user = [NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    
    int xOffset = 600;
    int yOffset = 800;
    
    //make invisible
    self.coachLabel.alpha = 0;
    self.coachImageView.alpha = 0;
    self.primaryActionButton.alpha = 0;
    self.primaryActionButton.hidden = NO;
    
    if ([self isClockedIn]) {
        [self setTimecardValues];
        //show middle view
        self.middleView.hidden = NO;
        self.statusArrowImageView.image = [UIImage imageNamed:@"green-arrow-icon"];
        self.secondaryActionButton.hidden = self.projects.count == 0;
        [self.secondaryActionButton setTitle:@"assign project" forState:UIControlStateNormal];
        [self.primaryActionButton setTitle:@"clock out" forState:UIControlStateNormal];
        UIImage *greenButtonImage = [UIImage imageNamed:@"red-btn"];
        UIImage *stretchableGreenButton = [greenButtonImage
                                           stretchableImageWithLeftCapWidth:22 topCapHeight:0];
        [self.primaryActionButton setBackgroundImage:stretchableGreenButton
                                            forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            //hide coach element outside view
            self.coachLabel.frame = CGRectOffset(self.coachLabel.frame, -xOffset, 0);
            self.coachImageView.frame = CGRectOffset(self.coachImageView.frame, 0, yOffset);
            self.coachLabel.alpha = 0;
            self.coachImageView.alpha = 0;
            
            //make visible
            self.primaryActionButton.alpha = 1;
            self.middleView.alpha = 1;
        } completion:nil];
    }else{
        //set date value
        [self setDateTime:[NSDate date]];
        
        //Add coach elements if not existent
        if (![self.view.subviews containsObject:self.coachLabel]) {
            [self.view addSubview:self.coachLabel];
            [self.view addSubview:self.coachImageView];
        }
        
        //set label off screen to the left
        CGRect middleFrame = self.middleView.frame;
        CGRect labelFrame = CGRectMake(-xOffset, middleFrame.origin.y, self.coachLabel.frame.size.width, self.coachLabel.frame.size.height);
        self.coachLabel.frame = labelFrame;
        
        //set image off screen to the top
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        self.coachImageView.frame = CGRectMake((screenRect.size.width / 2) - (self.coachImageView.frame.size.width/2), -yOffset, self.coachImageView.frame.size.width, self.coachImageView.frame.size.height);
        
        
        self.middleView.hidden = YES;
        self.secondaryActionButton.hidden =  YES;
        self.statusArrowImageView.image = [UIImage imageNamed:@"red-arrow-icon"];
        UIImage *greenButtonImage = [UIImage imageNamed:@"green-btn"];
        UIImage *stretchableGreenButton = [greenButtonImage
                                           stretchableImageWithLeftCapWidth:22 topCapHeight:0];
        [self.primaryActionButton setTitle:@"clock in" forState:UIControlStateNormal];
        [self.primaryActionButton setBackgroundImage:stretchableGreenButton
                                            forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            //hide time view
            self.middleView.alpha = 0;
            
            //show coach elements below date
            CGRect middleFrame = self.middleView.frame;
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            
            //set label in the middle of the screen
            CGRect labelFrame = CGRectMake((screenRect.size.width / 2) - (self.coachLabel.frame.size.width/2), middleFrame.origin.y, self.coachLabel.frame.size.width, self.coachLabel.frame.size.height);
            self.coachLabel.frame = labelFrame;
            
            //set image in the middle of the screen
            self.coachImageView.frame = CGRectMake((screenRect.size.width / 2) - (self.coachImageView.frame.size.width/2), labelFrame.origin.y + labelFrame.size.height + 20, self.coachImageView.frame.size.width, self.coachImageView.frame.size.height);
            
            //make visible
            self.coachLabel.alpha = 1;
            self.coachImageView.alpha = 1;
            self.primaryActionButton.alpha = 1;
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
    UIImage *img = [self isClockedIn] ? self.timecard.photoIn : self.timecard.photoOut;
    [self addRoundAvatar:img];
    
    //set time values
    NSDate *date = [self isClockedIn] ? self.timecard.timestampIn : self.timecard.timestampOut;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm"];
    self.timeLabel.text = [formatter stringFromDate:date];
    [formatter setDateFormat:@"a"];
    self.amPmLabel.text = [formatter stringFromDate:date];
    
    //set date value
    [self setDateTime:date];
    [self setTimeCounter];
}

- (void)setDateTime:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    self.dayOfTheWeekLabel.text = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"MMM d, yyyy"];
    self.dateLabel.text = [dateFormatter stringFromDate:date];
}

-(void)setTimeCounter
{
    //set counter value
    NSDate *date = [self isClockedIn] ? self.timecard.timestampIn : self.timecard.timestampOut;
    if (date) {
        NSDate *now = [NSDate date];
        NSCalendar *c = [NSCalendar currentCalendar];
        NSDateComponents *components = [c components:NSCalendarUnitHour fromDate:date toDate:now options:0];
        NSInteger hours = components.hour;
        components = [c components:NSCalendarUnitMinute fromDate:date toDate:now options:0];
        NSInteger minutes = components.minute - (hours * 60);
        
        self.counterLabel.text = [NSString stringWithFormat:@"%ih:%im", hours, minutes];
    }
}

- (void)startTimer
{
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(setTimeCounter) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}

#pragma mark UIAlert delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: {//sign out
            self.timecard = nil; //clear timecard
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:NO forKey:@"logged_in"];
            [self showLoginController];
            break;
        }
        default:
            break;
    }
}

@end
