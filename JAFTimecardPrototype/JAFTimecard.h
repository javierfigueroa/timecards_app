//
//  JAFTimecard.h
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 7/22/13.
//  Copyright (c) 2013 Javier Figueroa. All rights reserved.
//

#import <Foundation/Foundation.h>

//{
//    "timestamp_in": "2013-07-22T07:06:00Z",
//    "photo_in_file_size": 548413,
//    "photo_out_content_type": "image/jpeg",
//    "user_id": 2,
//    "longitude_in": -134234,
//    "updated_at": "2013-07-22T21:07:05Z",
//    "latitude_in": 3241324,
//    "photo_in_content_type": "image/jpeg",
//    "photo_in_url": "http://s3.amazonaws.com/timecards_photos/tenant_1/user_2/photo_in.jpg?1374527225",
//    "photo_out_file_name": "dexter.jpeg",
//    "photo_out_file_size": 548413,
//    "id": 3,
//    "photo_out_updated_at": "2013-07-22T21:07:05Z",
//    "latitude_out": 2343,
//    "longitude_out": -324234,
//    "photo_in_file_name": "dexter.jpeg",
//    "photo_in_updated_at": "2013-07-22T21:07:05Z",
//    "created_at": "2013-07-22T21:07:05Z",
//    "timestamp_out": "2013-07-22T21:06:00Z",
//    "photo_out_url": "http://s3.amazonaws.com/timecards_photos/tenant_1/user_2/photo_out.jpg?1374527225"
//}

@interface JAFTimecard : NSObject

@property (nonatomic, strong) NSDate *timestampIn;
@property (nonatomic, strong) NSDate *timestampOut;
@property (nonatomic, strong) NSNumber *longitudeIn;
@property (nonatomic, strong) NSNumber *longitudeOut;
@property (nonatomic, strong) NSNumber *latitudeIn;
@property (nonatomic, strong) NSNumber *latitudeOut;
@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, strong) NSString *projectID;
@property (nonatomic, strong) UIImage *photoIn;
@property (nonatomic, strong) UIImage *photoOut;

- (id)initWithAttributes:(NSDictionary*)data;

+ (void)assignProject:(JAFTimecard*)timecard projectID:(NSNumber*)ID completion:(void (^)(JAFTimecard *timecard, NSError *error))block;

+ (void)getTodaysTimecardWithCompletion:(void (^)(JAFTimecard *timecard, NSError *error))block;

+ (void)clockIn:(JAFTimecard*)timecard completion:(void (^)(JAFTimecard *timecard, NSError *error))block;

+ (void)clockOut:(JAFTimecard*)timecard completion:(void (^)(JAFTimecard *timecard, NSError *error))block;

@end
