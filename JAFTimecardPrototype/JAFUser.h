//
//  JAFUser.h
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 7/22/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAFUser : NSObject<NSCoding>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) NSString *password;

- (id)initWithAttributes:(NSDictionary*)data;

+ (void)login:(NSString*)username andPassword:(NSString*)password completion:(void (^)(JAFUser *user, NSError *error))block;

@end
