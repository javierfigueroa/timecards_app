//
//  JAFUser.m
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 7/22/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "JAFUser.h"
#import "JAFAPIClient.h"

@implementation JAFUser

- (id)initWithAttributes:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        self.lastName = data[@"last_name"];
        self.firstName = data[@"first_name"];
        self.authToken = data[@"token"];
        self.username = data[@"email"];
        self.ID = data[@"id"];
    }
    return self;
}


+ (void)login:(NSString*)username andPassword:(NSString*)password completion:(void (^)(JAFUser *user, NSError *error))block
{
    NSDictionary *parameters = @{@"user[email]":username, @"user[password]":password};
    [[JAFAPIClient sharedClient] postPath:@"users/sign_in.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        {
        //            "last_name": "a1",
        //            "id": 2,
        //            "token": "b7bUNK4LLShKkKdR1nU9",
        //            "email": "a1@example.com",
        //            "first_name": "a1"
        //        }
        
        NSDictionary *JSON = (NSDictionary*)responseObject;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        JAFUser *user = [[JAFUser alloc] initWithAttributes:JSON];
        user.password = password;
        
        NSData *myEncodedUser = [NSKeyedArchiver archivedDataWithRootObject:user];
        [defaults setObject:myEncodedUser forKey:@"user"];

        [JAFAPIClient resetInstance];
        
        if (block) {
            block(user, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.firstName forKey:@"first_name"];
    [aCoder encodeObject:self.lastName forKey:@"last_name"];
    [aCoder encodeObject:self.ID forKey:@"id"];
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.password forKey:@"password"];
    [aCoder encodeObject:self.authToken forKey:@"auth_token"];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.firstName = [aDecoder decodeObjectForKey:@"first_name"];
        self.lastName = [aDecoder decodeObjectForKey:@"last_name"];
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.password = [aDecoder decodeObjectForKey:@"password"];
        self.ID = [aDecoder decodeObjectForKey:@"id"];
        self.authToken = [aDecoder decodeObjectForKey:@"auth_token"];
    }
    
    return self;
}


@end