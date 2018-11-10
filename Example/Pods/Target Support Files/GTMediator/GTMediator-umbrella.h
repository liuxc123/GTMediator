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

#import "GTAnnotation.h"
#import "GTClientDelegate.h"
#import "GTCommon.h"
#import "GTConfig.h"
#import "GTContext.h"
#import "GTDefines.h"
#import "GTMediator.h"
#import "GTMediatorNavigator.h"
#import "GTModuleManager.h"
#import "GTModuleProtocol.h"
#import "GTServiceManager.h"
#import "GTServiceProtocol.h"
#import "GTTimeProfiler.h"
#import "GTWatchDog.h"

FOUNDATION_EXPORT double GTMediatorVersionNumber;
FOUNDATION_EXPORT const unsigned char GTMediatorVersionString[];
