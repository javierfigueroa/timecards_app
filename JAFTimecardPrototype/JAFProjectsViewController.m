//
//  UITableViewController+JAFProjectsViewController.m
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 1/23/14.
//  Copyright (c) 2014 Javier Figueroa. All rights reserved.
//

#import "JAFProjectsViewController.h"
#import "JAFActionsViewController.h"
#import "JAFProject.h"

@implementation JAFProjectsViewController



- (id)initWithProjects:(NSArray *)projects
{
    self = [super initWithNibName:@"ProjectsViewController" bundle:nil];
    
    if (self) {
        self.projects = [NSArray arrayWithArray:projects];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - UITableView Protocol

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.projects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ProjectCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    UIColor *textColor = [UIColor colorWithRed:170.0/255.0 green:179.0/255.0 blue:188.0/255.0 alpha:1];
    cell.textLabel.textColor = textColor;
    cell.textLabel.text = [self.projects[indexPath.row] name];
    cell.textLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:18];

    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.actionsController setProject:self.projects[indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
