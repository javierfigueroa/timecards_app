//
//  JAFUser.h
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 7/22/13.
//  Copyright (c) 2013 Javier Figueroa. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kUserLoggedInNotification @"timecards.io.loggedin"


@interface JAFUser : NSObject<NSCoding>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *company;

- (id)initWithAttributes:(NSDictionary*)data;

+ (void)login:(NSString*)username andPassword:(NSString*)password andCompany:(NSString*)company completion:(void (^)(JAFUser *user, NSError *error))block;

+ (void)signupWithUsername:(NSString*)username password:(NSString*)password firstName:(NSString *)firstName lastName:(NSString *)lastName company:(NSString *)company completion:(void (^)(JAFUser *, NSError *))block;

+ (void)updateWithPassword:(NSString*)password newPassword:(NSString*)newPassword firstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email completion:(void (^)(JAFUser *, NSError *))block;

+ (void)resetPassword:(NSString*)username andCompany:(NSString *)company completion:(void (^)(JAFUser *, NSError *))block;

@end
