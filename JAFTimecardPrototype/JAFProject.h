//
//  JAFProject.h
//  JAFTimecardPrototype
//
//  Created by killboy7 on 11/10/13.
//  Copyright (c) 2013 Javier Figueroa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAFProject : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *ID;

- (id)initWithAttributes:(NSDictionary *)data;


+ (void)getProjectsWithCompletion:(void (^)(NSArray *projects, NSError *error))block;

@end
