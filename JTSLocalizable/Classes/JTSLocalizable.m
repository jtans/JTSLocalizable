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

static NSComparisonResult jts_versionCompare(NSString *ver1, NSString *ver2) {
    if ([ver1 isEqualToString:ver2]) {
        return NSOrderedSame;
    }
    /*
     *  1  1.1
     *  1.0  1.0.1
     */
    NSArray *ver1Sections = [ver1 componentsSeparatedByString:@"."];
    NSArray *ver2Sections = [ver2 componentsSeparatedByString:@"."];
    uint8_t maxSectionCount = MAX(ver1Sections.count, ver2Sections.count);
    
    //fill sections
    for (int i = 0; i < 2; i++) {
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:maxSectionCount];
        NSArray *src = i == 0 ? ver1Sections : ver2Sections;
        [temp addObjectsFromArray:src];
        for (int j = (int)src.count; j < maxSectionCount; j++) {
            [temp addObject:@(0)];
        }
        if (i == 0) {
            ver1Sections = [temp copy];
        } else {
            ver2Sections = [temp copy];
        }
    }
    
    //compare
    NSUInteger(^calcVersion)(NSArray *) = ^(NSArray *vers) {
        NSUInteger val = 0;
        for (uint8_t i = 0; i < vers.count; i++) {
            val += [vers[i] integerValue] * pow(10, maxSectionCount - i);
        }
        return val;
    };
    
    NSUInteger ver1Value = calcVersion(ver1Sections);
    NSUInteger ver2Value = calcVersion(ver2Sections);
    if (ver1Value == ver2Value) {
        return NSOrderedSame;
    }
    if (ver1Value < ver2Value) {
        return NSOrderedAscending;
    }
    return NSOrderedDescending;
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
        //skip appVersion < currentAppversion
        if (![appVersion isKindOfClass:[NSString class]] || jts_versionCompare(appVersion, currentAppversion) == NSOrderedAscending) {
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
            }
        } else {//load from cache
            [self shared].localizables = [[NSDictionary alloc] initWithContentsOfFile:[self currentCacheLocalURL:version]];
        }
        Done;
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
