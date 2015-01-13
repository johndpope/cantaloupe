//
//  KHAppDelegate.m
//  Cantaloupe
//
//  Created by Kevin Hwang on 3/17/14.
//  Copyright (c) 2014 Kevin Hwang. All rights reserved.
//

#import "KHAppDelegate.h"
#import "KHSessionController.h"
#import "KHTabBarController.h"
#import "Cantaloupe-Swift.h"

@implementation KHAppDelegate

- (void)dealloc {
    [[KHSessionController sharedInstance] removeObserver:self forKeyPath:@"loggedIn"];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Add analytics
    
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-50979066-1"];
    
#ifdef DEBUG
    
    [GAI sharedInstance].dryRun = YES;
    
#endif
    
    // Create and display view
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    KHSessionController *session = [KHSessionController sharedInstance];
    
    UIViewController *mainController;
    if (session.loggedIn) {
        mainController = [[KHTabBarController alloc] initWithKey:session.key];
    } else {
        mainController = [[LoginViewController alloc] init];
    }
    
    [session addObserver:self forKeyPath:@"loggedIn" options:0 context:nil];
    
    self.window.rootViewController = mainController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - MagicalRecord

- (void)_magicalRecordError:(NSError *)error {
    NSLog(@"Bad stuff: %@", [error description]);
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"loggedIn"]) {
        if (![KHSessionController sharedInstance].loggedIn) {
            // If you logged out, quit everything and get dumped back to the login screen.
            self.window.rootViewController = [[LoginViewController alloc] init];
        }
    }
}

@end
