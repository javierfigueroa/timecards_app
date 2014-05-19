//
//  NSDate+Timecards.m
//  JAFTimecardPrototype
//
//  Created by killboy7 on 5/18/14.
//  Copyright (c) 2014 Javier Figueroa. All rights reserved.
//

#import "NSDate+Timecards.h"

@implementation NSDate (Timecards)

- (NSDate*)twoWeeksAgo
{
    NSCalendar *c = [NSCalendar currentCalendar];
    NSDateComponents *components = [c components:(NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
    
    [components setDay:([components day] - 14)];
    return [c dateFromComponents:components];
}

- (NSDate*)yearToDate
{
    NSCalendar *c = [NSCalendar currentCalendar];
    NSDateComponents *components = [c components:(NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:components.year];
    [comps setMonth:1];
    [comps setDay:1];
    [comps setHour:0];
    [comps setMinute:0];
    
    return [c dateFromComponents:comps];
}

+ (NSString *)timeStringFrom:(NSDate*)from to:(NSDate*)to
{
    NSCalendar *c = [NSCalendar currentCalendar];
    NSDateComponents *components = [c components:NSCalendarUnitHour fromDate:from toDate:to options:0];
    NSInteger hours = components.hour;
    components = [c components:NSCalendarUnitMinute fromDate:from toDate:to options:0];
    NSInteger minutes = components.minute - (hours * 60);
    
    return [NSString stringWithFormat:@"%lih:%lim",(long) hours, (long)minutes];
}

+ (NSString *)timeStringFromComponents:(NSDateComponents*)components
{
    NSInteger hours = components.hour;
    NSInteger minutes = components.minute;
    return [NSString stringWithFormat:@"%lih:%lim",(long)  hours, (long)minutes];
}

+ (NSInteger)hoursFrom:(NSDate*)from to:(NSDate*)to
{
    NSCalendar *c = [NSCalendar currentCalendar];
    NSDateComponents *components = [c components:NSCalendarUnitHour fromDate:from toDate:to options:0];
    return components.hour;
}

+ (NSInteger)minutesFrom:(NSDate*)from to:(NSDate*)to
{
    NSCalendar *c = [NSCalendar currentCalendar];
    NSDateComponents *components = [c components:NSCalendarUnitHour fromDate:from toDate:to options:0];
    NSInteger hours = components.hour;
    components = [c components:NSCalendarUnitMinute fromDate:from toDate:to options:0];
    return components.minute - (hours * 60);
}

@end
