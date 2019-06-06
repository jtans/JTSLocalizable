//
//  JTSLocalizeManager.m
//  JTSLocalizeManager
//
//  Created by angle on 2019/6/6.
//

#import "JTSLocalizeManager.h"
#import <AFNetworking/AFNetworking.h>

@implementation JTSLocalizeManager

- (instancetype)init {
    if (self = [super init]) {
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
    }
    return self;
}

+ (instancetype)manager {
    static JTSLocalizeManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self class] new];
    });
    return instance;
}

- (NSString *)bundleIdBase64 {
    static NSString *rs = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *idn =  [[NSBundle mainBundle] objectForInfoDictionaryKey:kCFBundleIdentifierKey];
        NSData *data = [idn dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64 = [data base64EncodedStringWithOptions:0];
        rs = base64;
    });
    return rs;
}

#pragma mark - JTSLocalizableDelegate
- (NSString *)jts_urlVersion {
    return [NSString stringWithFormat:@"https://github.com/jtans/langs/%@/version.json?v=%f",
            [self bundleIdBase64],
            [NSDate timeIntervalSinceReferenceDate]];
}

- (NSString *)jts_urlLocalizable:(NSLocale *)currentLocale {
    return [NSString stringWithFormat:@"https://github.com/jtans/langs/%@/%@.json?v=%f",
            [self bundleIdBase64],
            [currentLocale objectForKey:NSLocaleLanguageCode],
            [NSDate timeIntervalSinceReferenceDate]];
}

@end
