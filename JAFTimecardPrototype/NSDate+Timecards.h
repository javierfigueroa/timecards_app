//
//  NSDate+Timecards.h
//  JAFTimecardPrototype
//
//  Created by killboy7 on 5/18/14.
//  Copyright (c) 2014 Javier Figueroa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Timecards)

+ (NSString *)timeStringFrom:(NSDate*)from to:(NSDate*)to;

+ (NSInteger)hoursFrom:(NSDate*)from to:(NSDate*)to;

+ (NSInteger)minutesFrom:(NSDate*)from to:(NSDate*)to;

+ (NSString *)timeStringFromComponents:(NSDateComponents*)components;

- (NSDate*)twoWeeksAgo;

- (NSDate*)nextDay;

- (NSDate*)yearToDate;

@end
