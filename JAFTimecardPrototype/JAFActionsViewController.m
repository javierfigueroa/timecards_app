//
//  JAFActionsViewController.m
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 7/9/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "JAFActionsViewController.h"
#import "JAFLoginViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "JAFSummaryViewController.h"
#import "JAFTimecard.h"
#import "SVProgressHUD.h"

NSString *const kStartLocationServicesNotification = @"kStartLocationServicesNotification";
NSString *const kStopLocationServicesNotification = @"kStopLocationServicesNotification";
NSString *const kLocationDidChangeNotification = @"kLocationDidChangeNotification";
@interface JAFActionsViewController ()
{
    
}
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) JAFTimecard *timecard;

@end

@implementation JAFActionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)showLoginController
{
    JAFLoginViewController *loginController = [[JAFLoginViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.timecard = [[JAFTimecard alloc] init];
    self.location = self.locationManager.location;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isLoggedIn = [userDefaults boolForKey:@"logged_in"];
    if (!isLoggedIn) {
        [self showLoginController];
    }
}

- (void)setButtonStates:(JAFTimecard *)timecard
{
    if (!timecard.timestampIn) {
        [self.clockInButton setTitle:@"CLOCK IN" forState:UIControlStateNormal];
        self.clockInButton.enabled = YES;
        self.clockOutButton.enabled = NO;
    }else{
        [self.clockInButton setTitle:@"YOU'RE ON THE CLOCK!" forState:UIControlStateNormal];
        self.clockInButton.enabled = NO;
        self.clockOutButton.enabled = YES;
    }
}

- (void)getTimecard
{
    if (!self.timecard.timestampIn) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    }
    
    [JAFTimecard getTodaysTimecardWithCompletion:^(JAFTimecard *timecard, NSError *error) {
        [SVProgressHUD dismiss];
        if (!timecard) {
            timecard = [[JAFTimecard alloc] init];
        }
        
        self.timecard = timecard;
        [self setButtonStates:timecard];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isLoggedIn = [userDefaults boolForKey:@"logged_in"];
    if (isLoggedIn) {
        [self getTimecard];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didPressClockIn:(id)sender {
    [self openImagePickerControllerWithType:UIImagePickerControllerSourceTypeCamera inController:self];
}

- (IBAction)didPressClockOut:(id)sender {
    [self openImagePickerControllerWithType:UIImagePickerControllerSourceTypeCamera inController:self];
}

- (IBAction)didPressSignOut:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO forKey:@"logged_in"];
    [self showLoginController];
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
        
        if (!self.timecard.timestampIn) {
            self.timecard.timestampIn = [NSDate date];
            self.timecard.latitudeIn = [NSNumber numberWithDouble:self.location.coordinate.latitude];
            self.timecard.longitudeIn = [NSNumber numberWithDouble:self.location.coordinate.longitude];
            self.timecard.photoIn = image;
        }else{
            self.timecard.timestampOut = [NSDate date];
            self.timecard.latitudeOut = [NSNumber numberWithDouble:self.location.coordinate.latitude];
            self.timecard.longitudeOut = [NSNumber numberWithDouble:self.location.coordinate.longitude];
            self.timecard.photoOut = image;
        }
        
        
        JAFSummaryViewController *summary = [[JAFSummaryViewController alloc] initWithNibName:@"JAFSummaryViewController" bundle:nil];
        summary.timecard = self.timecard;
        [self.navigationController pushViewController:summary animated:YES];       
    }];
}

@end
