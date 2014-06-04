//
//  JAFTimecardService.h
//  JAFTimecardPrototype
//
//  Created by killboy7 on 5/7/14.
//  Copyright (c) 2014 Javier Figueroa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class JAFTimecard, JAFProject, JAFSummary, JAFUser;
@interface JAFTimecardService : NSObject

@property (nonatomic, strong) JAFSummary *thisPeriod;
@property (nonatomic, strong) JAFSummary *yearToDate;

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

- (BOOL)hasProjects;

- (void)clearTimecard;

- (void)getTimecardWithBlock:(void (^)(JAFTimecard *timecard, NSError *error))block;

- (void)getProjectsWithBlock:(void (^)(void))block;

- (NSArray *)getProjects;

- (void)getSummaryFrom:(NSDate*)from to:(NSDate*)to forUserId:(NSString*)userId andCompletion:(void (^)(JAFSummary *summary, NSError *error))block;

- (void)clockWithLocation:(CLLocation*)location
                  picture:(UIImage *)picture
                 andBlock:(void (^)(JAFTimecard *timecard, NSError *error))block;

- (void)assignProject:(JAFProject *)project
             andBlock:(void (^)(JAFTimecard *timecard, NSError *error))block;

- (void)getSummaryForUser:(JAFUser*)user;
@end
