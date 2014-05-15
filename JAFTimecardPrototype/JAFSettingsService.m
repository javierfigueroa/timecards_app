//
//  JAFSettingsService.m
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 5/13/14.
//  Copyright (c) 2014 Javier Figueroa. All rights reserved.
//

#import "JAFSettingsService.h"


NSString *const kStartLocationServicesNotification = @"kStartLocationServicesNotification";
NSString *const kStopLocationServicesNotification = @"kStopLocationServicesNotification";
NSString *const kLocationDidChangeNotification = @"kLocationDidChangeNotification";

static JAFSettingsService *_sharedService = nil;

@interface JAFSettingsService()
{
    UIAlertView *_locationServicesAlert;
}

@property (nonatomic, strong) CLLocationManager *locationManager;

@end


@implementation JAFSettingsService

+ (JAFSettingsService *)service
{
    if (!_sharedService) {
        _sharedService = [[JAFSettingsService alloc] init];
        [_sharedService locationManager];
    }
    
    return _sharedService;
}

- (BOOL)isPhotoEnabled
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"photo_enabled"];
}

- (void)setPhotoEnabled:(BOOL)value
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:value forKey:@"photo_enabled"];
    [defaults synchronize];
}

- (BOOL)isTrackingLocation
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL locationEnabled = [defaults boolForKey:@"location_enabled"];
    return [CLLocationManager locationServicesEnabled] && locationEnabled;
}

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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"location_enabled"];
    [defaults synchronize];
    
    self.location = nil;
}

- (void)resumeLocationServices:(NSNotificationCenter *)notification
{
	NSLog(@"Resuming location services");
	[self.locationManager startMonitoringSignificantLocationChanges];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"location_enabled"];
    [defaults synchronize];
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
	if ((self.locationManager.location.coordinate.latitude == 0) &&
		(self.locationManager.location.coordinate.longitude == 0)) {
        NSString *app = NSBundle.mainBundle.infoDictionary  [@"CFBundleDisplayName"];
        NSString *message = [NSString stringWithFormat:@"Please enable Location \n Services for %@, go to: \n Privacy -> Location -> %@", app, app];
        
		_locationServicesAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Disabled Location Services", @"Disabled Location Services") message:NSLocalizedString(message, message) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [_locationServicesAlert show];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kStopLocationServicesNotification object:self userInfo:nil];
	}
}




@end
