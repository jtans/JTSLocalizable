//
//  JTSLocalizeManager.h
//  JTSLocalizeManager
//
//  Created by angle on 2019/6/6.
//

#import <Foundation/Foundation.h>
#import <JTSLocalizable/JTSLocalizable.h>

NS_ASSUME_NONNULL_BEGIN

@interface JTSLocalizeManager : NSObject<JTSLocalizableDelegate>

+ (instancetype)manager;

@end

NS_ASSUME_NONNULL_END
