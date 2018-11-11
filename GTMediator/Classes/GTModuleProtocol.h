//
//  GTModuleProtocol.h
//  FBSnapshotTestCase
//
//  Created by liuxc on 2018/11/10.
//

//微应用的协议
//微应用的配置以及客户端的生命周期 

#import <Foundation/Foundation.h>
#import "GTAnnotation.h"
@class GTContext;
@class GTMediator;

#define GT_EXPORT_MODULE(isAsync) \
+ (void)load { [GTMediator registerDynamicModule:[self class]]; } \
-(BOOL)async { return [[NSString stringWithUTF8String:#isAsync] boolValue];}

@protocol GTModuleProtocol <NSObject>

@optional

//如果不去设置Level默认是Normal
//basicModuleLevel不去实现默认Normal
- (void)basicModuleLevel;
//越大越优先
- (NSInteger)modulePriority;
//异步加载
- (BOOL)async;
//实例对象
- (id)target;
// 获取当前swiftbundleName Swift类必须写这个属性
- (NSString *)swiftNundleName;

- (void)modSetUp:(GTContext *)context;

- (void)modInit:(GTContext *)context;

- (void)modSplash:(GTContext *)context;

- (void)modQuickAction:(GTContext *)context;

- (void)modTearDown:(GTContext *)context;

- (void)modWillResignActive:(GTContext *)context;

- (void)modDidEnterBackground:(GTContext *)context;

- (void)modWillEnterForeground:(GTContext *)context;

- (void)modDidBecomeActive:(GTContext *)context;

- (void)modWillTerminate:(GTContext *)context;

- (void)modUnmount:(GTContext *)context;

- (void)modOpenURL:(GTContext *)context;

- (void)modDidReceiveMemoryWaring:(GTContext *)context;

- (void)modDidFailToRegisterForRemoteNotifications:(GTContext *)context;

- (void)modDidRegisterForRemoteNotifications:(GTContext *)context;

- (void)modDidReceiveRemoteNotification:(GTContext *)context;

- (void)modDidReceiveLocalNotification:(GTContext *)context;

- (void)modWillPresentNotification:(GTContext *)context;

- (void)modDidReceiveNotificationResponse:(GTContext *)context;

- (void)modWillContinueUserActivity:(GTContext *)context;

- (void)modContinueUserActivity:(GTContext *)context;

- (void)modDidFailToContinueUserActivity:(GTContext *)context;

- (void)modDidUpdateContinueUserActivity:(GTContext *)context;

- (void)modHandleWatchKitExtensionRequest:(GTContext *)context;

- (void)modDidCustomEvent:(GTContext *)context;

@end
