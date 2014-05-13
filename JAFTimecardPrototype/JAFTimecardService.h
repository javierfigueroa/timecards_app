//
//  JAFTimecardService.h
//  JAFTimecardPrototype
//
//  Created by killboy7 on 5/7/14.
//  Copyright (c) 2014 Javier Figueroa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class JAFTimecard, JAFProject;
@interface JAFTimecardService : NSObject


+ (JAFTimecardService *)service;

- (BOOL)clockedIn;

- (BOOL)hasProject;

- (NSString*)getProjectName;

- (NSString*)getTimeValue;

- (NSString *)getAbbrevValue;

- (NSString *)getDayOfTheWeekValue;

- (NSString *)getDateValue;

- (NSString *)getDateValue:(NSDate*)date;

- (UIImage *)getAvatar;

- (NSString *)getLoggedTimeValue;

- (NSString *)getName;

- (BOOL)hasProjects;

- (void)clearTimecard;

- (void)getTimecardWithBlock:(void (^)(JAFTimecard *timecard, NSError *error))block;

- (void)getProjectsWithBlock:(void (^)(void))block;

- (NSArray *)getProjects;

- (void)clockWithLocation:(CLLocation*)location
                  picture:(UIImage *)picture
                 andBlock:(void (^)(JAFTimecard *timecard, NSError *error))block;

- (void)assignProject:(JAFProject *)project
             andBlock:(void (^)(JAFTimecard *timecard, NSError *error))block;
@end
