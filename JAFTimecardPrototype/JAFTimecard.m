//
//  JAFTimecard.m
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 7/22/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "JAFTimecard.h"
#import "JAFAPIClient.h"
#import "JAFUser.h"
#import "AFJSONRequestOperation.h"

@implementation JAFTimecard

- (id)initWithAttributes:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZ";
        self.ID = [NSNumber numberWithInt:[data[@"id"] intValue]];
        self.timestampIn = [formatter dateFromString:data[@"timestamp_in"]];
        
        if (data[@"timestamp_out"] != (id)[NSNull null]) {
            self.timestampOut = [formatter dateFromString:data[@"timestamp_out"]];
        }
        
        self.latitudeIn = [NSNumber numberWithDouble:[data[@"latitude_in"] doubleValue]];
        
        if (data[@"latitude_out"] != (id)[NSNull null]) {
            self.latitudeOut = [NSNumber numberWithDouble:[data[@"latitude_out"] doubleValue]];
        }
        
        self.longitudeIn = [NSNumber numberWithDouble:[data[@"longitude_in"] doubleValue]];
        
        if (data[@"longitude_out"] != (id)[NSNull null]) {
            self.longitudeOut = [NSNumber numberWithDouble:[data[@"longitude_out"] doubleValue]];
        }
    }
    return self;
}


+ (void)getTodaysTimecardWithCompletion:(void (^)(JAFTimecard *timecard, NSError *error))block
{
    [[JAFAPIClient sharedClient] getPath:@"timecards/today" parameters:nil  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        
        NSDictionary *JSON = (NSDictionary*)responseObject;
        if (!JSON[@"id"]) {
            if (block) {
                block(nil, nil);
            }
        }else{
            JAFTimecard *timecard = [[JAFTimecard alloc] initWithAttributes:JSON];
            if (block) {
                block(timecard, nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
        
    }];
}


+ (void)clockIn:(JAFTimecard*)timecard completion:(void (^)(JAFTimecard *timecard, NSError *error))block
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"timecard[latitude_in]"] = timecard.latitudeIn;
    parameters[@"timecard[longitude_in]"] = timecard.longitudeIn;
    
    NSDateComponents *components = [[self class] componentsFromDate:timecard.timestampIn];
    parameters[@"timecard[timestamp_in(1i)"] = [NSString stringWithFormat:@"%i", components.year];
    parameters[@"timecard[timestamp_in(2i)"] = [NSString stringWithFormat:@"%i", components.month];
    parameters[@"timecard[timestamp_in(3i)"] = [NSString stringWithFormat:@"%i", components.day];
    parameters[@"timecard[timestamp_in(4i)"] = [NSString stringWithFormat:@"%i", components.hour];
    parameters[@"timecard[timestamp_in(5i)"] = [NSString stringWithFormat:@"%i", components.minute];
    
#ifdef DEBUG
    NSLog(@"%@", parameters);
#endif
    NSMutableURLRequest *request = [[JAFAPIClient sharedClient] multipartFormRequestWithMethod:@"POST" path:@"timecards" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(timecard.photoIn, 0)
                                    name:@"timecard[photo_in]"
                                fileName:@"clock_in.jpeg"
                                mimeType:@"image/jpeg"];
#ifdef DEBUG
        NSLog(@"%@", formData);
#endif 
    }];
    
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON =  [(AFJSONRequestOperation*)operation responseJSON];
#ifdef DEBUG
        NSLog(@"%@", JSON);
#endif
        if ([JSON isKindOfClass:[NSDictionary class]]) {
            // response is ok
            
            
            if (block) {
                block(timecard, nil);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (block) {
            block(nil, [NSError errorWithDomain:[error localizedDescription] code:operation.response.statusCode userInfo:nil]);
        }
    }];
    
    [[JAFAPIClient sharedClient] enqueueHTTPRequestOperation:operation];
}

+ (void)clockOut:(JAFTimecard*)timecard completion:(void (^)(JAFTimecard *timecard, NSError *error))block
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"timecard[latitude_out]"] = timecard.latitudeOut;
    parameters[@"timecard[longitude_out]"] = timecard.longitudeOut;
    
    NSDateComponents *components = [[self class] componentsFromDate:timecard.timestampOut];
    parameters[@"timecard[timestamp_out(1i)"] = [NSString stringWithFormat:@"%i", components.year];
    parameters[@"timecard[timestamp_out(2i)"] = [NSString stringWithFormat:@"%i", components.month];
    parameters[@"timecard[timestamp_out(3i)"] = [NSString stringWithFormat:@"%i", components.day];
    parameters[@"timecard[timestamp_out(4i)"] = [NSString stringWithFormat:@"%i", components.hour];
    parameters[@"timecard[timestamp_out(5i)"] = [NSString stringWithFormat:@"%i", components.minute];
    
#ifdef DEBUG
    NSLog(@"%@", parameters);
#endif
    NSString *url = [NSString stringWithFormat:@"timecards/%@", timecard.ID];
    NSMutableURLRequest *request = [[JAFAPIClient sharedClient] multipartFormRequestWithMethod:@"PUT" path:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(timecard.photoOut, 0)
                                    name:@"timecard[photo_out]"
                                fileName:@"clock_out.jpeg"
                                mimeType:@"image/jpeg"];
#ifdef DEBUG
        NSLog(@"%@", formData);
#endif
    }];
    
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *JSON =  [(AFJSONRequestOperation*)operation responseJSON];
#ifdef DEBUG
        NSLog(@"%@", JSON);
#endif
        if ([JSON isKindOfClass:[NSDictionary class]]) {
            // response is ok
            
            
            if (block) {
                block(timecard, nil);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (block) {
            block(nil, [NSError errorWithDomain:[error localizedDescription] code:operation.response.statusCode userInfo:nil]);
        }
    }];
    
    [[JAFAPIClient sharedClient] enqueueHTTPRequestOperation:operation];
}

+ (NSDateComponents*)componentsFromDate:(NSDate*)date
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[gregorian setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	NSDateComponents *components = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    return components;
}

@end
