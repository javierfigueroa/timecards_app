//
//  JAFProject.m
//  JAFTimecardPrototype
//
//  Created by killboy7 on 11/10/13.
//  Copyright (c) 2013 Javier Figueroa. All rights reserved.
//

#import "JAFProject.h"
#import "JAFAPIClient.h"

@implementation JAFProject

- (id)initWithAttributes:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        self.name = data[@"name"];
        self.ID = data[@"id"];
    }
    return self;
}

+ (void)getProjectsWithCompletion:(void (^)(NSArray *projects, NSError *))block
{
    [[JAFAPIClient sharedClient] GET:@"projects" parameters:nil  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        
        NSArray *JSON = (NSArray*)responseObject;
        NSMutableArray *projects = [[NSMutableArray alloc] initWithCapacity:JSON.count];
        
        JAFProject *none = [[JAFProject alloc] init];
        none.ID = [NSNumber numberWithInt:0];
        none.name = @"Unassigned";
        
        for (NSDictionary *projectJSON in JSON) {
            [projects addObject:[[JAFProject alloc] initWithAttributes:projectJSON]];
        }
        
        if (projects.count > 0) {
            [projects insertObject:none atIndex:0];
        }
        
        if (block) {
            block(projects, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
        
    }];
}

@end
