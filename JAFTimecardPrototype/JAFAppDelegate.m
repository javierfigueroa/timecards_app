//
//  JAFAppDelegate.m
//  JAFTimecardPrototype
//
//  Created by Javier Figueroa on 7/9/13.
//  Copyright (c) 2013 Javier Figueroa. All rights reserved.
//

#import "JAFAppDelegate.h"
#import "JAFLeftMenuViewController.h"
#import "JAFActionsViewController.h"
#import "JAFLoginViewController.h"
#import "JAFSettingsService.h"
#import "JAFTimecardService.h"

@implementation JAFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    JAFUser *user = [[JAFSettingsService service] getLoggedUser];
    if (user != nil) {
        [[JAFTimecardService service] getSummaryForUser:user];
    }
    
    JAFActionsViewController *controller = [JAFActionsViewController controller];
    self.actionsController = [[UINavigationController alloc]initWithRootViewController:controller];
    JAFLeftMenuViewController *leftMenuController = [[JAFLeftMenuViewController alloc] init];
    
    UIColor *backgroundColor = [UIColor colorWithRed:28.0/255.0 green:35.0/255.0 blue:41.0/255.0 alpha:1];
    UIColor *textColor = [UIColor colorWithRed:170.0/255.0 green:179.0/255.0 blue:188.0/255.0 alpha:1];
    [[UINavigationBar appearance] setTintColor:textColor];
    [[UINavigationBar appearance] setBarTintColor:backgroundColor];
    // Create frosted view controller
    //
    REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:self.actionsController menuViewController:leftMenuController];
    frostedViewController.direction = REFrostedViewControllerDirectionLeft;
    frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    frostedViewController.liveBlur = YES;
    frostedViewController.delegate = self;
    
    // Make it a root controller
    //
    self.window.rootViewController = frostedViewController;
    self.window.backgroundColor = [UIColor whiteColor];

    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kStopLocationServicesNotification object:self];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    if ([[JAFSettingsService service] isTrackingLocation]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kStartLocationServicesNotification object:self];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)showLoginController
{
    JAFLoginViewController *loginController = [JAFLoginViewController controller];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginController];
    [self.window.rootViewController presentViewController:navController animated:YES completion:nil];
}

#pragma mark -
#pragma mark RESideMenu Delegate

- (void)frostedViewController:(REFrostedViewController *)frostedViewController didRecognizePanGesture:(UIPanGestureRecognizer *)recognizer
{
    
}

- (void)frostedViewController:(REFrostedViewController *)frostedViewController willShowMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"willShowMenuViewController");
}

- (void)frostedViewController:(REFrostedViewController *)frostedViewController didShowMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"didShowMenuViewController");
}

- (void)frostedViewController:(REFrostedViewController *)frostedViewController willHideMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"willHideMenuViewController");
}

- (void)frostedViewController:(REFrostedViewController *)frostedViewController didHideMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"didHideMenuViewController");
}

@end

// This is a workaround just enables white text colour in status bar in iOS7, iOS7.1
// Dont touch it until things break
// Despite this category says "draw white", colour automatically becomes black on white background w/o additional code
@interface UINavigationController (StatusBarStyle)

@end

@implementation UINavigationController (StatusBarStyle)

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationBar.translucent = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
@end
// Place at the bottom of your AppDelegate.m
// Magic!
