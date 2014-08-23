//
//  JAFSummary.h
//  JAFTimecardPrototype
//
//  Created by killboy7 on 5/18/14.
//  Copyright (c) 2014 Javier Figueroa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAFSummary : NSObject

@property (nonatomic, strong) NSDate *from;
@property (nonatomic, strong) NSDate *to;
@property (nonatomic) float earnings;
@property (nonatomic) int hours;
@property (nonatomic) int minutes;

- (NSString*)getTimeString;

- (void)addTimeFrom:(NSDate*)from to:(NSDate*)to;

- (void)addEarningsFrom:(NSDate*)from to:(NSDate*)to wage:(NSNumber*)wage;


@end
