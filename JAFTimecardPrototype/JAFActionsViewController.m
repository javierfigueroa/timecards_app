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

NSString *const kStartLocationServicesNotification = @"kStartLocationServicesNotification";
NSString *const kStopLocationServicesNotification = @"kStopLocationServicesNotification";
NSString *const kLocationDidChangeNotification = @"kLocationDidChangeNotification";
@interface JAFActionsViewController ()
{
    NSTimer *timer;
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
    self.pickerTitleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:self.pickerTitleLabel.font.pointSize];
    self.pickerAssignButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:self.pickerAssignButton.titleLabel.font.pointSize];
    self.pickerCancelButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:self.pickerCancelButton.titleLabel.font.pointSize];
}

- (void)getTimecard
{
    if ([self clockingIn]) {
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
            if ([self.timecard.projectID intValue] > 0) {
                for(JAFProject *project in projects) {
                    if ([project.ID intValue] == [self.timecard.projectID intValue]) {
                        [self.secondaryActionButton setTitle:project.name forState:UIControlStateNormal];
                        break;
                    }
                }
            }
        }
    }];
}

- (BOOL)clockingIn
{
    return !self.timecard.timestampIn;
}

- (void)showLoginController
{
    JAFLoginViewController *loginController = [JAFLoginViewController controller];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)refreshProjectsPicker {
    [self.projectsPicker reloadAllComponents];
    
    self.pickerContainerView.alpha = 0;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.pickerContainerView.alpha = 1;
        self.pickerContainerView.hidden = NO;
    } completion:nil];
    [self.projectsPicker selectRow:0 inComponent:0 animated:YES];
}

#pragma mark - Actions

- (IBAction)didPressPrimaryAction:(id)sender {
    [self openImagePickerControllerWithType:UIImagePickerControllerSourceTypeCamera inController:self];
}

- (IBAction)didPressSecondaryAction:(id)sender {
    if (self.projects.count == 0) {
        [self getProjects];
    }else{
        [self refreshProjectsPicker];
    }
}


- (IBAction)didPressSignOut:(id)sender {
    self.timecard = nil; //clear timecard
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO forKey:@"logged_in"];
    [self showLoginController];
}

- (IBAction)didPressCancelPicker:(id)sender {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.pickerContainerView.alpha = 0;
    } completion:^(BOOL finished) {
        
        self.pickerContainerView.hidden = YES;
    }];
}

- (IBAction)didAssignProject:(id)sender {
    NSInteger row = [self.projectsPicker selectedRowInComponent:0];
    JAFProject *project = (JAFProject*)self.projects[row];
    
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
	if ((self.location.coordinate.latitude == 0) &&
		(self.location.coordinate.longitude == 0)) {
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Disabled Location Services", @"Disabled Location Services") message:NSLocalizedString(@"Please enable Location Services \n for AnglerTrack, go to: \n Privacy -> Location -> AnglerTrack", @"Please enable Location Services \n for AnglerTrack, go to: \n Privacy -> Location -> AnglerTrack") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil] show];
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
        [SVProgressHUD showWithStatus:([self clockingIn] ? @"Clocking in..." : @"Clocking out...") maskType:SVProgressHUDMaskTypeGradient];
        if ([self clockingIn]) {
            
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
        }else{
            
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
    self.secondaryActionButton.alpha = 0;
    self.primaryActionButton.hidden = NO;
    
    if ([self clockingIn]) {
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
        self.secondaryActionButton.hidden = YES;
        [self.secondaryActionButton setTitle:@"assign project" forState:UIControlStateNormal];
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
            self.secondaryActionButton.alpha = 1;
        } completion:nil];
    }else{
        [self setTimecardValues];
        //show middle view
        self.middleView.hidden = NO;
        self.statusArrowImageView.image = [UIImage imageNamed:@"green-arrow-icon"];
        self.secondaryActionButton.hidden = [self clockingIn] && self.projects && self.projects.count > 0;
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
            self.secondaryActionButton.alpha = 1;
            self.primaryActionButton.alpha = 1;
            self.middleView.alpha = 1;
        } completion:nil];
    }
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
    UIImage *img = ![self clockingIn] ? self.timecard.photoIn : self.timecard.photoOut;
    [self addRoundAvatar:img];
    
    //set time values
    NSDate *date = ![self clockingIn] ? self.timecard.timestampIn : self.timecard.timestampOut;
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
    NSDate *date = ![self clockingIn] ? self.timecard.timestampIn : self.timecard.timestampOut;
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

#pragma mark - UIPicker Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.projects.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    title.backgroundColor = [UIColor clearColor];
    title.textAlignment = NSTextAlignmentCenter;
    NSString *text = [(JAFProject*)self.projects[row] name];
    title.text = text;
    title.font = [UIFont fontWithName:@"OpenSans-Light" size:18];
    title.textColor = [UIColor whiteColor];
    
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"%i", row);
    [pickerView selectRow:row inComponent:component animated:YES];
}

@end
