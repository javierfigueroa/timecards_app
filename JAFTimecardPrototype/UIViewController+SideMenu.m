//
//  UIViewController+SideMenu.m
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 5/13/14.
//  Copyright (c) 2014 Javier Figueroa. All rights reserved.
//

#import "UIViewController+SideMenu.h"
#import "REFrostedViewController.h"
#import "UIViewController+REFrostedViewController.h"

@implementation UIViewController (SideMenu)

- (void)setSideMenu
{
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(presentLeftMenuViewController:)];
}

- (IBAction)presentLeftMenuViewController:(id)sender
{
    [self.frostedViewController presentMenuViewController];
}


@end
