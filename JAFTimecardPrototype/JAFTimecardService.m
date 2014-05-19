//
//  JAFTimecardService.m
//  JAFTimecardPrototype
//
//  Created by killboy7 on 5/7/14.
//  Copyright (c) 2014 Javier Figueroa. All rights reserved.
//

#import "JAFTimecardService.h"
#import "JAFTimecard.h"
#import "JAFProject.h"
#import "JAFSummary.h"
#import "JAFUser.h"
#import "NSDate+Timecards.h"

static JAFTimecardService *_sharedService = nil;

@interface JAFTimecardService()

@property (nonatomic, strong) JAFTimecard *activeTimecard;
@property (nonatomic, strong) NSMutableArray *projects;

@end


@implementation JAFTimecardService

+ (JAFTimecardService *)service
{
    if (!_sharedService) {
        _sharedService = [[JAFTimecardService alloc] init];
    }
    
    return _sharedService;
}


- (JAFTimecard *)activeTimecard
{
    if (!_activeTimecard) {
        _activeTimecard = [[JAFTimecard alloc] init];
    }
    
    return _activeTimecard;
}

- (BOOL)clockedIn
{
    return self.activeTimecard.timestampIn != nil;
}

- (BOOL)hasProject
{
    return self.activeTimecard.project.ID != (id)[NSNull null];
}


- (NSMutableArray *)projects
{
    if (!_projects) {
        _projects = [[NSMutableArray alloc] init];
    }
    
    return _projects;
}

- (BOOL)hasProjects
{
    return self.projects.count > 0;
}

- (void)getProjectsWithBlock:(void (^)(void))block
{
    [JAFProject getProjectsWithCompletion:^(NSArray *projects, NSError *error) {
        if (!error) {
            self.projects = [NSMutableArray arrayWithArray:projects];
        }
        
        if (block) {
            block();
        }
    }];
}

- (NSArray *)getProjects
{
    return [NSArray arrayWithArray:self.projects];
}

- (NSString*)getProjectName
{
    return self.activeTimecard.project.name;
}

- (NSString*)getTimeValue
{
    NSDate *date = [self clockedIn] ?
        self.activeTimecard.timestampIn :
        self.activeTimecard.timestampOut;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm"];
    return [formatter stringFromDate:date];
}

- (NSString *)getAbbrevValue
{
    NSDate *date = [self clockedIn] ?
    self.activeTimecard.timestampIn :
    self.activeTimecard.timestampOut;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"a"];
    return [formatter stringFromDate:date];
}

- (NSString *)getDayOfTheWeekValue
{
    NSDate *date = [self clockedIn] ?
    self.activeTimecard.timestampIn :
    self.activeTimecard.timestampOut;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    return [dateFormatter stringFromDate:date ? date : [NSDate date]];
}

- (NSString *)getDateValue
{
    NSDate *date = [self clockedIn] ?
    self.activeTimecard.timestampIn :
    self.activeTimecard.timestampOut;
    
    return [self getDateValue: date ? date : [NSDate date]];
}

- (NSString *)getDateValue:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, yyyy"];
    return [dateFormatter stringFromDate:date];
}

- (UIImage *)getAvatar
{
    UIImage *img = [self clockedIn] ?
    self.activeTimecard.photoIn :
    self.activeTimecard.photoOut;
    
    return img ? img : [UIImage imageNamed:@"Profile-Avatar"];
}

- (NSString *)getLoggedTimeValue
{
    NSDate *date = [self clockedIn] ?
    self.activeTimecard.timestampIn :
    self.activeTimecard.timestampOut;
    
    if (!date) {
        return @"";
    }
    
    NSDate *now = [NSDate date];
    return [NSDate timeStringFrom:date to:now];
}

- (void)clearTimecard
{
    self.activeTimecard = nil;
}

- (void)getTimecardWithBlock:(void (^)(JAFTimecard *timecard, NSError *error))block
{
    [JAFTimecard getTodaysTimecardWithCompletion:^(JAFTimecard *timecard, NSError *error) {
        self.activeTimecard = timecard;
        
        if (block) {
            block(self.activeTimecard, error);
        }
    }];
}

- (void)clockWithLocation:(CLLocation*)location picture:(UIImage *)picture andBlock:(void (^)(JAFTimecard *timecard, NSError *error))block
{
    if ([self clockedIn]) {
        [self clockOutWithLocation:location picture:picture andBlock:block];
    }else{
        [self clockInWithLocation:location picture:picture andBlock:block];
    }
}


- (void)clockInWithLocation:(CLLocation*)location picture:(UIImage *)picture andBlock:(void (^)(JAFTimecard *timecard, NSError *error))block
{
    self.activeTimecard.timestampIn = [NSDate date];
    self.activeTimecard.latitudeIn = [NSNumber numberWithDouble:location.coordinate.latitude];
    self.activeTimecard.longitudeIn = [NSNumber numberWithDouble:location.coordinate.longitude];
    self.activeTimecard.photoIn = picture;
    
    [JAFTimecard clockIn:self.activeTimecard completion:^(JAFTimecard *timecard, NSError *error) {
        if (!error) {
            self.activeTimecard = timecard;
        }
        
        if (block) {
            block(self.activeTimecard, error);
        }
    }];
}


- (void)clockOutWithLocation:(CLLocation*)location picture:(UIImage *)picture andBlock:(void (^)(JAFTimecard *timecard, NSError *error))block
{
    self.activeTimecard.timestampOut = [NSDate date];
    self.activeTimecard.latitudeOut = [NSNumber numberWithDouble:location.coordinate.latitude];
    self.activeTimecard.longitudeOut = [NSNumber numberWithDouble:location.coordinate.longitude];
    self.activeTimecard.photoOut = picture;
    
    [JAFTimecard clockOut:self.activeTimecard completion:^(JAFTimecard *timecard, NSError *error) {
        if (!error) {
            self.activeTimecard.timestampIn = nil;
            self.activeTimecard.timestampOut = nil;
        }
        
        if (block) {
            block(self.activeTimecard, error);
        }
    }];
}

- (void)assignProject:(JAFProject *)project andBlock:(void (^)(JAFTimecard *timecard, NSError *error))block
{
    [JAFTimecard assignProject:self.activeTimecard projectID:project.ID completion:^(JAFTimecard *timecard, NSError *error) {
        if (!error) {
            self.activeTimecard = timecard;
        }
        
        if (block) {
            block(self.activeTimecard, error);
        }
    }];
}

- (void)getSummaryFrom:(NSDate *)from to:(NSDate *)to forUserId:(NSString *)userId andCompletion:(void (^)(JAFSummary *, NSError *))block
{
    [JAFTimecard getTimecardsFrom:from to:to forUserId:userId andCompletion:^(NSArray *timecards, JAFSummary *summary, NSError *error) {
        if (!error) {            
            if (block) {
                block(summary, nil);
            }
        }else{
            if (block) {
                block(nil, error);
            }
        }
        
    }];
}

@end
