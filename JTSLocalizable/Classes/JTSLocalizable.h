//
//  JTSLocalizable.h
//  JTSLocalizable
//
//  Created by tansheng on 2018/7/4.
//  Copyright © 2018年 znfox. All rights reserved.
//

#import <Foundation/Foundation.h>

//get string from local
#define JTSLocalizableString(key, comment_) [JTSLocalizable localizableString:(key) comment:(comment_)]

#if DEBUG
#define JTSLog(format, ...) NSLog(format,##__VA_ARGS__)
#else
#define JTSLog(format, ...) 
#endif


/**
 url provide delgate
 */
@protocol JTSLocalizableDelegate <NSObject>

/**
 see ./Support/JTSLocalizable_version.json
 Example json content:
 {
 "version":"1.2",
 "appVersion":"1.0",
 "bundleId":"com.znfox.JTSLocalizable"
 }

 @return url
 */
- (NSString *)jts_urlVersion;

/**
 see ./Support/JTSLocalizable_en.json
 Example json content:
 {
 "title":"标题"
 }

 @param currentLocale currentLocale description
 @return url
 */
- (NSString *)jts_urlLocalizable:(NSLocale *)currentLocale;

@end

@interface JTSLocalizable : NSObject

+ (void)setDelegate:(id<JTSLocalizableDelegate>)delegate;
/**
 set download handler

 @param downloadHandler downloadHandler description
 */
+ (void)registerDownloadHandler:(NSDictionary* (^)(NSString *url))downloadHandler;

/**
 update complete

 @param completeBlock completeBlock run in main thread.
 */
+ (void)updateIfNeed:(void (^)(void))completeBlock;

/**
 pick LocalizableString, replace NSLocalizableString from your code.
 also you can use JTSLocalizableString(key, comment).

 @param key key description
 @param comment comment description
 @return return value description
 */
+ (NSString *)localizableString:(NSString *)key comment:(NSString *)comment;

@end
