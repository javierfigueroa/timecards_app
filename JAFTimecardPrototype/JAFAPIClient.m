//
//  JAFAPIClient.m
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 7/22/13.
//  Copyright (c) 2013 Javier Figueroa. All rights reserved.
//

#import "JAFAPIClient.h"
#import "JAFUser.h"

@implementation JAFAPIClient

static AFHTTPRequestOperationManager *_sharedClient = nil;

+ (void)resetInstance
{
    _sharedClient = nil;
}

+ (void)setAPIDomain:(NSString*)domain
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *baseUrl = @"timecards.dev:3000";// [defaults valueForKey:@"server"];
    NSString *url = [NSString stringWithFormat:@"http://%@.%@", domain, baseUrl ? baseUrl : @"timecards.io"];
    [defaults setValue:url forKey:@"service_url"];
    [[self class] resetInstance];
}

+ (AFHTTPRequestOperationManager *)sharedClient {
    if (!_sharedClient) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *url = [defaults valueForKey:@"service_url"];
        NSAssert(url, @"Service url is empty, calling setAPIDomain first is required");
        _sharedClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:url]];
        
        [_sharedClient setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        [_sharedClient.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];

        NSData *myEncodedObject = [defaults objectForKey:@"user"];
        JAFUser *user = [NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];

        [_sharedClient.requestSerializer setAuthorizationHeaderFieldWithUsername:user.username
                                                                        password:user.password];
    }
    
    return _sharedClient;
}
//
//- (id)initWithBaseURL:(NSURL *)url {
//    self = [super init];
//    if (!self) {
//        return nil;
//    }
//
//    self.
//    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
//	[self setDefaultHeader:@"Accept" value:@"application/json"];
//    [self setAuthorizationHeaderWithUsername:user.username password:user.password];
//    
//    return self;
//}


@end
