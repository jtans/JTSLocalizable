#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "JTSLocalizable.h"
#import "JTSLocalizeManager.h"

FOUNDATION_EXPORT double JTSLocalizableVersionNumber;
FOUNDATION_EXPORT const unsigned char JTSLocalizableVersionString[];

