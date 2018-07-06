//
//  JTSAppDelegate.m
//  JTSLocalizable
//
//  Created by jtans@qq.com on 07/06/2018.
//  Copyright (c) 2018 jtans@qq.com. All rights reserved.
//

#import "JTSAppDelegate.h"
#import <AFNetworking/AFNetworking.h>

@implementation JTSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //1,set download handler
    [JTSLocalizable registerDownloadHandler:^NSDictionary *(NSString *url) {
        __block id response = nil;
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [AFHTTPSessionManager.manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
                NSLog(@"download progress %lld/%lld", downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                response = responseObject;
                dispatch_semaphore_signal(sem);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"download error %@", error);
                dispatch_semaphore_signal(sem);
            }];
        });
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        return response;
    }];
    
    //2,set delegate to provide url
    [JTSLocalizable setDelegate:self];
    
    //3,check update localizable strings complete.
    [JTSLocalizable updateIfNeed:^{
        NSLog(@"JTSLocalizableString title 😆=%@", JTSLocalizableString(@"title", @""));
    }];
    
    return YES;
}
    
#pragma mark - JTSLocalizableDelegate
- (NSString *)jts_urlVersion {
    return [NSString stringWithFormat:@"http://7fvjpr.com1.z0.glb.clouddn.com/JTSLocalizable_version.json?v=%f",[NSDate timeIntervalSinceReferenceDate]];
}
    
- (NSString *)jts_urlLocalizable:(NSLocale *)currentLocale {
    return [NSString stringWithFormat:@"http://7fvjpr.com1.z0.glb.clouddn.com/Localizable_en.json?v=%f",[NSDate timeIntervalSinceReferenceDate]];
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
