//
//  JTSLocalizable.m
//  JTSLocalizable
//
//  Created by tansheng on 2018/7/4.
//  Copyright © 2018年 znfox. All rights reserved.
//

#import "JTSLocalizable.h"

static NSString *kJTSLocalizableVersion = @"kJTSLocalizableVersion";

@interface JTSLocalizable()

@property(nonatomic, copy) NSDictionary* (^downloadHandler)(NSString *url);

@property(nonatomic, weak) id<JTSLocalizableDelegate> delegate;

@property(nonatomic, strong) NSDictionary *localizables;

@end

@implementation JTSLocalizable

+ (void)setDelegate:(id<JTSLocalizableDelegate>)delegate {
    [self shared].delegate = delegate;
}

+ (JTSLocalizable *)shared {
    static JTSLocalizable *localizable;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        localizable = [JTSLocalizable new];
    });
    return localizable;
}

+ (void)registerDownloadHandler:(NSDictionary *(^)(NSString *))downloadHandler {
    [self shared].downloadHandler = downloadHandler;
}

+ (void)updateIfNeed:(void (^)(void))completeBlock {
    if (![self shared].downloadHandler) {
        @throw [NSException exceptionWithName:[NSString stringWithFormat:@"%@", [self class]] reason:@"downloadHandler not set" userInfo:nil];
    }
    
#define Done \
dispatch_async(dispatch_get_main_queue(), ^{\
    if (completeBlock) {\
        completeBlock();\
    }\
});\
return;
    
    //download version info
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *versionInfo = [self downloadWithUrl:[[self shared].delegate jts_urlVersion]];
        if (!versionInfo || ![versionInfo isKindOfClass:[NSDictionary class]]) {
            JTSLog(@"version is empty.");
            Done
            return;
        }
        
        NSString *appVersion = versionInfo[@"appVersion"];//app version
        NSString *version = versionInfo[@"version"];//localizable version
        NSString *bundleID = versionInfo[@"bundleId"];
        
        if (!appVersion || !version || !bundleID) {
            Done
            return;
        }
        
        NSString *currentAppversion = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
        if (![appVersion isKindOfClass:[NSString class]] || ![appVersion isEqualToString:currentAppversion]) {
            Done
            return;
        }
        
        NSString *path = [self currentCacheLocalURL:version];
        BOOL cacheExits = [NSFileManager.defaultManager fileExistsAtPath:path];
        BOOL needUpdate = [version isKindOfClass:[NSString class]] && (version.floatValue > [self currentVersion].floatValue);
        if (!cacheExits || needUpdate) {//update
            [[NSUserDefaults standardUserDefaults] setObject:version forKey:kJTSLocalizableVersion];//update local version
            
            //download localizable strings //key=value
            NSDictionary *localStrings =  [self downloadWithUrl:[[self shared].delegate jts_urlLocalizable:[NSLocale currentLocale]]];
            if (localStrings && [localStrings isKindOfClass:[NSDictionary class]]) {
                [self shared].localizables = localStrings;
                
                //cache to local
                
                NSString *dir = [path stringByDeletingLastPathComponent];
                if(![NSFileManager.defaultManager fileExistsAtPath:dir]) {
                    NSError *error;
                    [NSFileManager.defaultManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
                    if(error) {
                        JTSLog(@"%@", error);
                    }
                }
                
                [localStrings writeToFile:path atomically:YES];
                Done
                return;
            }
        } else {//load from cache
            [self shared].localizables = [[NSDictionary alloc] initWithContentsOfFile:[self currentCacheLocalURL:version]];
            Done;
        }
    });
}

+ (NSString *)currentVersion {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kJTSLocalizableVersion];
}

+ (NSString *)currentCacheLocalURL:(NSString *)version {
    NSString *url = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject stringByAppendingFormat:@"/JTSLocalizable/%@.json", version ?:@""];
    return url;
}

+ (NSDictionary *)downloadWithUrl:(NSString *)url {
    NSDictionary *obj = [self shared].downloadHandler(url);
    return obj;
}

+ (NSString *)localizableString:(NSString *)key comment:(NSString *)comment {
    return [[self shared].localizables objectForKey:key];
}


@end
