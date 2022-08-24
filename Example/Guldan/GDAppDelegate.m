//
//  GDAppDelegate.m
//  Guldan
//
//  Created by Alex023 on 11/11/2021.
//  Copyright (c) 2021 Alex023. All rights reserved.
//

#import "GDAppDelegate.h"
#import "GDNOCMethodTimeProfiler.h"

@implementation GDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [GDNOCMethodTimeProfiler start];
    [self testDelegate];
    return YES;
}

- (void)testDelegate
{
    clock_t start = clock();
    [self delegateM1];
    [self delegateM2];
    clock_t end = clock();
    double cost = (double)(end - start) / CLOCKS_PER_SEC;
    NSLog(@"cost:%f", cost);

}

- (void)delegateM1 {
    sleep(2);
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        
        [self delegateM3];
    });
}

- (void)delegateM2 {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        for (int i = 0; i < 100000; i++) {
//            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
//            [self.window addSubview:v];
//            [v removeFromSuperview];
//        }
//    });
    for (int i = 0; i < 10000; i++) {
        NSLog(@"%d", i * 2);
    }
}

- (void)delegateM3 {
    for (int i = 0; i < 10000; i++) {
        NSLog(@"%d", i * 2);
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
