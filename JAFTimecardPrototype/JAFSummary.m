//
//  JAFSummary.m
//  JAFTimecardPrototype
//
//  Created by killboy7 on 5/18/14.
//  Copyright (c) 2014 Javier Figueroa. All rights reserved.
//

#import "JAFSummary.h"
#import "NSDate+Timecards.h"

@implementation JAFSummary

-(NSString *)getTimeString
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setHour:self.hours];
    [comps setMinute:self.minutes];
    return [NSDate timeStringFromComponents:comps];
}

- (void)addTimeFrom:(NSDate *)from to:(NSDate *)to
{
    if (from && to) {
        self.hours += (int) [NSDate hoursFrom:from to:to];
        self.minutes += (int)[NSDate minutesFrom:from to:to];
    }
}

- (void)addEarningsFrom:(NSDate *)from to:(NSDate *)to wage:(NSNumber *)wage
{
    if (from && to) {
        float earned = 0;
        NSInteger hours = [NSDate hoursFrom:from to:to];
        NSInteger minutes = [NSDate minutesFrom:from to:to];
        
        earned += hours * [wage floatValue];
        earned += minutes * [wage floatValue]/60;
        
        self.earnings = self.earnings + earned;
    }
}

@end
