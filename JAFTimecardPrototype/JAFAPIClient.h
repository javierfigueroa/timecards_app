//
//  JAFAPIClient.h
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 7/22/13.
//  Copyright (c) 2013 Mainloop LLC. All rights reserved.
//

#import "AFHTTPClient.h"

@interface JAFAPIClient : AFHTTPClient

+ (JAFAPIClient *)sharedClient;

+ (void)setAPIDomain:(NSString*)domain;

+ (void)resetInstance;

@end
