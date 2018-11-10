//
//  GTModuleManager.h
//  FBSnapshotTestCase
//
//  Created by liuxc on 2018/11/10.
//

/**
 GTModuleManager 微应用管理类
 微应用：带有UI界面的
 */

#import <Foundation/Foundation.h>


// 模块等级
typedef NS_ENUM(NSUInteger, GTModuleLevel)
{
    GTModuleLevelBasic  = 0,
    GTModuleLevelNormal = 1
};

// 事件类型
typedef NS_ENUM(NSInteger, GTModuleEventType)
{
    GTMSetupEvent = 0,
    GTMInitEvent,
    GTMTearDownEvent,
    GTMSplashEvent,
    GTMQuickActionEvent,
    GTMWillResignActiveEvent,
    GTMDidEnterBackgroundEvent,
    GTMWillEnterForegroundEvent,
    GTMDidBecomeActiveEvent,
    GTMWillTerminateEvent,
    GTMUnmountEvent,
    GTMOpenURLEvent,
    GTMDidReceiveMemoryWarningEvent,
    GTMDidFailToRegisterForRemoteNotificationsEvent,
    GTMDidRegisterForRemoteNotificationsEvent,
    GTMDidReceiveRemoteNotificationEvent,
    GTMDidReceiveLocalNotificationEvent,
    GTMWillPresentNotificationEvent,
    GTMDidReceiveNotificationResponseEvent,
    GTMWillContinueUserActivityEvent,
    GTMContinueUserActivityEvent,
    GTMDidFailToContinueUserActivityEvent,
    GTMDidUpdateUserActivityEvent,
    GTMHandleWatchKitExtensionRequestEvent,
    GTMDidCustomEvent = 1000

};

@class GTModule;

// 模块管理类
@interface GTModuleManager : NSObject

// 单例
+ (instancetype)sharedManager;

// If you do not comply with set Level protocol, the default Normal
// 如果你没有设置 Level等级 默认是normal

// 注册模块
- (void)registerDynamicModule:(Class)moduleClass;

// 注册模块 触发shouldTriggerInitEvent
- (void)registerDynamicModule:(Class)moduleClass
       shouldTriggerInitEvent:(BOOL)shouldTriggerInitEvent;

// 返注册模块
- (void)unRegisterDynamicModule:(Class)moduleClass;

// 加载本地模块
- (void)loadLocalModules;

// 注册所有模块
- (void)registedAllModules;

//注册自定义Event eventType >= 1000
- (void)registerCustomEvent:(NSInteger)eventType
         withModuleInstance:(id)moduleInstance
             andSelectorStr:(NSString *)selectorStr;

// 触发事件Event
- (void)triggerEvent:(NSInteger)eventType;

// 触发事件Event 自定义参数customParam
- (void)triggerEvent:(NSInteger)eventType
     withCustomParam:(NSDictionary *)customParam;

@end

