//
//  UITableViewController+JAFProjectsViewController.h
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 1/23/14.
//  Copyright (c) 2014 Javier Figueroa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JAFActionsViewController;

@interface JAFProjectsViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *projects;
@property (nonatomic, weak) JAFActionsViewController *actionsController;

- (id)initWithProjects:(NSArray *)projects;

@end
