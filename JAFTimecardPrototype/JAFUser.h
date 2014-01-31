//
//  JAFUser.h
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 7/22/13.
//  Copyright (c) 2013 Javier Figueroa. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@end
