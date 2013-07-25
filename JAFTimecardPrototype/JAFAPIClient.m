//
//  JAFAPIClient.m
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 7/22/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "JAFAPIClient.h"
#import "AFJSONRequestOperation.h"
#import "JAFUser.h"

@implementation JAFAPIClient

static JAFAPIClient *_sharedClient = nil;

+ (void)resetInstance
{
    _sharedClient = nil;
}

+ (void)setAPIDomain:(NSString*)domain
{
    NSString *url = @"http://10.0.0.7:3000";//[NSString stringWithFormat:@"http://%@.%@", domain, @"timecards.dev:3000"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:url forKey:@"service_url"];
    [[self class] resetInstance];
}

+ (JAFAPIClient *)sharedClient {
    if (!_sharedClient) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *url = [defaults valueForKey:@"service_url"];
        NSAssert(url, @"Service url is empty, calling setAPIDomain first is required");
        _sharedClient = [[JAFAPIClient alloc] initWithBaseURL:[NSURL URLWithString:url]];
    }
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *myEncodedObject = [defaults objectForKey:@"user"];
    JAFUser *user = [NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setAuthorizationHeaderWithUsername:user.username password:user.password];
    
    return self;
}


@end
