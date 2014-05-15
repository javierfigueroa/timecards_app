//
//  JAFTimecard.m
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 7/22/13.
//  Copyright (c) 2013 Javier Figueroa. All rights reserved.
//

#import "JAFTimecard.h"
#import "JAFAPIClient.h"
#import "JAFUser.h"
#import "JAFProject.h"
#import "AFHTTPRequestOperationManager.h"

@implementation JAFTimecard

- (id)initWithAttributes:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ";
        self.ID = [NSNumber numberWithInt:[data[@"id"] intValue]];
        self.timestampIn = [formatter dateFromString:data[@"timestamp_in"]];
        
        if (data[@"project"] && data[@"project"] != (id)[NSNull null]) {
            self.project = [[JAFProject alloc] initWithAttributes:data[@"project"]];
        }else{
            self.project = [[JAFProject alloc] initWithAttributes:@{@"name":@"assign project", @"id": @"0"}];
        }

        self.photoIn = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:data[@"photo_in_url"]]]];

        if (data[@"photo_out_url"] != (id)[NSNull null]) {
            self.photoOut = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:data[@"photo_out_url"]]]];
        }
        
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
    [[JAFAPIClient sharedClient] GET:@"timecards/today.json" parameters:nil  success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
+ (void)assignProject:(JAFTimecard*)timecard projectID:(NSNumber*)ID completion:(void (^)(JAFTimecard *timecard, NSError *error))block
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"timecard[project_id]"] = ID;
    
    
    NSString *url = [NSString stringWithFormat:@"timecards/%@", timecard.ID];
    [[JAFAPIClient sharedClient] PUT:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
#ifdef DEBUG
        NSLog(@"%@", responseObject);
#endif
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *JSON = (NSDictionary*)responseObject;
            JAFTimecard *timecard = [[JAFTimecard alloc] initWithAttributes:JSON];
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
}

+ (void)clockIn:(JAFTimecard*)timecard completion:(void (^)(JAFTimecard *timecard, NSError *error))block
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"timecard[latitude_in]"] = timecard.latitudeIn;
    parameters[@"timecard[longitude_in]"] = timecard.longitudeIn;
    parameters[@"timecard[project_id]"] = @"0";
    
    NSDateComponents *components = [[self class] componentsFromDate:timecard.timestampIn];
    parameters[@"timecard[timestamp_in(1i)]"] = [NSString stringWithFormat:@"%li", (long)components.year];
    parameters[@"timecard[timestamp_in(2i)]"] = [NSString stringWithFormat:@"%li", (long)components.month];
    parameters[@"timecard[timestamp_in(3i)]"] = [NSString stringWithFormat:@"%li", (long)components.day];
    parameters[@"timecard[timestamp_in(4i)]"] = [NSString stringWithFormat:@"%li", (long)components.hour];
    parameters[@"timecard[timestamp_in(5i)]"] = [NSString stringWithFormat:@"%li", (long)components.minute];
    
#ifdef DEBUG
    NSLog(@"%@", parameters);
#endif
    
    AFHTTPRequestOperationManager *manager = [JAFAPIClient sharedClient];
    NSString *url = [[NSURL URLWithString:@"timecards" relativeToURL:manager.baseURL] absoluteString];
    NSMutableURLRequest *request = nil;
    if (!timecard.photoIn) {
        request = [manager.requestSerializer requestWithMethod:@"POST" URLString:url parameters:parameters];
    }else{
        request = [manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(timecard.photoIn, 0)
                                        name:@"timecard[photo_in]"
                                    fileName:@"clock_in.jpeg"
                                    mimeType:@"image/jpeg"];
    #ifdef DEBUG
            NSLog(@"%@", formData);
    #endif
        }];
    }
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
#ifdef DEBUG
        NSLog(@"%@", responseObject);
#endif
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            // response is ok
            JAFTimecard *timecard = [[JAFTimecard alloc] initWithAttributes:responseObject];
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
    [manager.operationQueue addOperation:operation];

}

+ (void)clockOut:(JAFTimecard*)timecard completion:(void (^)(JAFTimecard *timecard, NSError *error))block
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"timecard[latitude_out]"] = timecard.latitudeOut;
    parameters[@"timecard[longitude_out]"] = timecard.longitudeOut;
    
    NSDateComponents *components = [[self class] componentsFromDate:timecard.timestampOut];
    parameters[@"timecard[timestamp_out(1i)"] = [NSString stringWithFormat:@"%li", (long)components.year];
    parameters[@"timecard[timestamp_out(2i)"] = [NSString stringWithFormat:@"%li", (long)components.month];
    parameters[@"timecard[timestamp_out(3i)"] = [NSString stringWithFormat:@"%li", (long)components.day];
    parameters[@"timecard[timestamp_out(4i)"] = [NSString stringWithFormat:@"%li", (long)components.hour];
    parameters[@"timecard[timestamp_out(5i)"] = [NSString stringWithFormat:@"%li", (long)components.minute];
    
#ifdef DEBUG
    NSLog(@"%@", parameters);
#endif
    
    NSString *url = [NSString stringWithFormat:@"timecards/%@", timecard.ID];
    AFHTTPRequestOperationManager *manager = [JAFAPIClient sharedClient];
    url = [[NSURL URLWithString:url relativeToURL:manager.baseURL] absoluteString];
    
    NSMutableURLRequest *request = nil;
    if (!timecard.photoOut) {
        request = [manager.requestSerializer requestWithMethod:@"PUT" URLString:url parameters:parameters];
    }else{
        request = [manager.requestSerializer multipartFormRequestWithMethod:@"PUT" URLString:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(timecard.photoOut, 0)
                                        name:@"timecard[photo_out]"
                                    fileName:@"clock_out.jpeg"
                                    mimeType:@"image/jpeg"];
    #ifdef DEBUG
            NSLog(@"%@", formData);
    #endif
        }];
    }
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
#ifdef DEBUG
        NSLog(@"%@", responseObject);
#endif
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
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
    [manager.operationQueue addOperation:operation];
}

+ (NSDateComponents*)componentsFromDate:(NSDate*)date
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[gregorian setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	NSDateComponents *components = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    return components;
}

@end
