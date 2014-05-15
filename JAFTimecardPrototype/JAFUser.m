//
//  JAFUser.m
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 7/22/13.
//  Copyright (c) 2013 Javier Figueroa. All rights reserved.
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

+ (void)login:(NSString*)username andPassword:(NSString*)password andCompany:(NSString *)company completion:(void (^)(JAFUser *, NSError *))block
{
    
    NSString *cleanDomain = [company stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [JAFAPIClient setAPIDomain:cleanDomain];
    
    NSDictionary *parameters = @{@"user[email]":username, @"user[password]":password};
    [[JAFAPIClient sharedClient] POST:@"users/sign_in.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *JSON = (NSDictionary*)responseObject;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        JAFUser *user = [[JAFUser alloc] initWithAttributes:JSON];
        user.password = password;
        user.company = cleanDomain;
        
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

+ (void)signupWithUsername:(NSString*)username password:(NSString*)password firstName:(NSString *)firstName lastName:(NSString *)lastName company:(NSString *)company completion:(void (^)(JAFUser *, NSError *))block
{
    [JAFAPIClient setAPIDomain:@"www"];
    
    NSDictionary *parameters = @{@"user[email]":username,
                                 @"user[password]":password,
                                 @"user[first_name]":firstName,
                                 @"user[last_name]":lastName,
                                 @"user[company_name]":company};
    
    [[JAFAPIClient sharedClient] POST:@"users?plan=silver" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *JSON = (NSDictionary*)responseObject;
        
        
        NSError *error = nil;
        JAFUser *user = nil;
        
        if (JSON[@"errors"]) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary: JSON[@"errors"]];
            error = [[NSError alloc] initWithDomain:@"" code:400 userInfo:userInfo];
        }else{
            
            NSString *cleanDomain = [company stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [JAFAPIClient setAPIDomain:cleanDomain];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            JAFUser *user = [[JAFUser alloc] initWithAttributes:JSON];
            user.password = password;
            user.company = cleanDomain;
            
            NSData *myEncodedUser = [NSKeyedArchiver archivedDataWithRootObject:user];
            [defaults setObject:myEncodedUser forKey:@"user"];
        }
        
        [JAFAPIClient resetInstance];
        
        if (block) {
            block(user, error);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}


+ (void)updateWithPassword:(NSString*)password newPassword:(NSString*)newPassword firstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email completion:(void (^)(JAFUser *, NSError *))block
{
//    [JAFAPIClient setAPIDomain:@"www"];
    
    NSDictionary *parameters = @{@"user[email]":email,
                                 @"user[password]":newPassword,
                                 @"user[password_confirmation]":newPassword,
                                 @"user[current_password]":password,
                                 @"user[first_name]":firstName,
                                 @"user[last_name]":lastName};
    
//    NSString *url = [NSString stringWithFormat:@"users", ID];
    [[JAFAPIClient sharedClient] PUT:@"users" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *JSON = (NSDictionary*)responseObject;
        
        
        NSError *error = nil;
        JAFUser *user = nil;
        
        if (JSON[@"errors"]) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary: JSON[@"errors"]];
            error = [[NSError alloc] initWithDomain:@"" code:400 userInfo:userInfo];
        }else{
            
//            NSString *cleanDomain = [company stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//            [JAFAPIClient setAPIDomain:cleanDomain];
//            
//            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            JAFUser *user = [[JAFUser alloc] initWithAttributes:JSON];
//            user.password = password;
//            user.company = cleanDomain;
//            
//            NSData *myEncodedUser = [NSKeyedArchiver archivedDataWithRootObject:user];
//            [defaults setObject:myEncodedUser forKey:@"user"];
        }
        
//        [JAFAPIClient resetInstance];
        
        if (block) {
            block(user, error);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}


+ (void)resetPassword:(NSString*)username andCompany:(NSString *)company completion:(void (^)(JAFUser *, NSError *))block
{
    NSString *cleanDomain = [company stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [JAFAPIClient setAPIDomain:cleanDomain];
    
    NSDictionary *parameters = @{@"user[email]":username, @"user[company_name]":company};
    [[JAFAPIClient sharedClient] POST:@"users/password" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [JAFAPIClient resetInstance];
        
        if (block) {
            block(nil, nil);
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
    [aCoder encodeObject:self.company forKey:@"company"];
    
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
        self.company = [aDecoder decodeObjectForKey:@"company"];
    }
    
    return self;
}


@end
