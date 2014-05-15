//
//  JAFSettingsService.h
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 5/13/14.
//  Copyright (c) 2014 Javier Figueroa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


extern NSString *const kStopLocationServicesNotification;
extern NSString *const kStartLocationServicesNotification;
extern NSString *const kLocationDidChangeNotification;

@interface JAFSettingsService : NSObject<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocation *location;

+ (JAFSettingsService *)service;

- (BOOL)isTrackingLocation;

- (BOOL)isPhotoEnabled;

- (void)setPhotoEnabled:(BOOL)value;

- (void)stopLocationServices:(NSNotification *)notification;

- (void)resumeLocationServices:(NSNotificationCenter *)notification;

@end
