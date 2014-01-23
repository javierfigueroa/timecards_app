//
//  JAFAPIClient.h
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 7/22/13.
//  Copyright (c) 2013 Javier Figueroa. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface JAFAPIClient : NSObject

+ (AFHTTPRequestOperationManager *)sharedClient;

+ (void)setAPIDomain:(NSString*)domain;

+ (void)resetInstance;

@end
