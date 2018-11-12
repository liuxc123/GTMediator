//
//  GTClientDelegate.m
//  FBSnapshotTestCase
//
//  Created by liuxc on 2018/11/10.
//

#import "GTClientDelegate.h"
#import "GTMediator.h"
#import "GTModuleManager.h"
#import "GTTimeProfiler.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#import <UserNotifications/UserNotifications.h>
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@interface GTClientDelegate () <UNUserNotificationCenterDelegate>
#else
@interface GTClientDelegate ()
#endif

@end

@implementation GTClientDelegate

@synthesize window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[GTModuleManager sharedManager] triggerEvent:GTMSetupEvent];
    [[GTModuleManager sharedManager] triggerEvent:GTMInitEvent];

    dispatch_async(dispatch_get_main_queue(), ^{
        [[GTModuleManager sharedManager] triggerEvent:GTMSplashEvent];
    });
    if (@available(iOS 10.0, *)) {
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    }

#ifdef DEBUG
    [[GTTimeProfiler sharedTimeProfiler] saveTimeProfileDataIntoFile:@"GTMediatorTimeProfiler"];
#endif

    return YES;
}


- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler API_AVAILABLE(ios(9.0))
{
    [[GTMediator shareInstance].context.touchShortcutItem setShortcutItem: shortcutItem];
    [[GTMediator shareInstance].context.touchShortcutItem setScompletionHandler: completionHandler];
    [[GTModuleManager sharedManager] triggerEvent:GTMQuickActionEvent];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[GTModuleManager sharedManager] triggerEvent:GTMWillResignActiveEvent];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[GTModuleManager sharedManager] triggerEvent:GTMDidEnterBackgroundEvent];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[GTModuleManager sharedManager] triggerEvent:GTMWillEnterForegroundEvent];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[GTModuleManager sharedManager] triggerEvent:GTMDidBecomeActiveEvent];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[GTModuleManager sharedManager] triggerEvent:GTMWillTerminateEvent];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [[GTMediator shareInstance].context.openURLItem setOpenURL:url];
    [[GTMediator shareInstance].context.openURLItem setSourceApplication:sourceApplication];
    [[GTMediator shareInstance].context.openURLItem setAnnotation:annotation];
    [[GTModuleManager sharedManager] triggerEvent:GTMOpenURLEvent];
    return YES;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80400
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{

    [[GTMediator shareInstance].context.openURLItem setOpenURL:url];
    [[GTMediator shareInstance].context.openURLItem setOptions:options];
    [[GTModuleManager sharedManager] triggerEvent:GTMOpenURLEvent];
    return YES;
}
#endif


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[GTModuleManager sharedManager] triggerEvent:GTMDidReceiveMemoryWarningEvent];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[GTMediator shareInstance].context.notificationsItem setNotificationsError:error];
    [[GTModuleManager sharedManager] triggerEvent:GTMDidFailToRegisterForRemoteNotificationsEvent];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[GTMediator shareInstance].context.notificationsItem setDeviceToken: deviceToken];
    [[GTModuleManager sharedManager] triggerEvent:GTMDidRegisterForRemoteNotificationsEvent];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[GTMediator shareInstance].context.notificationsItem setUserInfo: userInfo];
    [[GTModuleManager sharedManager] triggerEvent:GTMDidReceiveRemoteNotificationEvent];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [[GTMediator shareInstance].context.notificationsItem setUserInfo: userInfo];
    [[GTMediator shareInstance].context.notificationsItem setNotificationResultHander: completionHandler];
    [[GTModuleManager sharedManager] triggerEvent:GTMDidReceiveRemoteNotificationEvent];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[GTMediator shareInstance].context.notificationsItem setLocalNotification: notification];
    [[GTModuleManager sharedManager] triggerEvent:GTMDidReceiveLocalNotificationEvent];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
- (void)application:(UIApplication *)application didUpdateUserActivity:(NSUserActivity *)userActivity
{
    if([UIDevice currentDevice].systemVersion.floatValue >= 8.0f){
        [[GTMediator shareInstance].context.userActivityItem setUserActivity: userActivity];
        [[GTModuleManager sharedManager] triggerEvent:GTMDidUpdateUserActivityEvent];
    }
}

- (void)application:(UIApplication *)application didFailToContinueUserActivityWithType:(NSString *)userActivityType error:(NSError *)error API_AVAILABLE(ios(8.0))
{
    if([UIDevice currentDevice].systemVersion.floatValue >= 8.0f){
        [[GTMediator shareInstance].context.userActivityItem setUserActivityType: userActivityType];
        [[GTMediator shareInstance].context.userActivityItem setUserActivityError: error];
        [[GTModuleManager sharedManager] triggerEvent:GTMDidFailToContinueUserActivityEvent];
    }
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
{
    if([UIDevice currentDevice].systemVersion.floatValue >= 8.0f){
        [[GTMediator shareInstance].context.userActivityItem setUserActivity: userActivity];
        [[GTMediator shareInstance].context.userActivityItem setRestorationHandler: restorationHandler];
        [[GTModuleManager sharedManager] triggerEvent:GTMContinueUserActivityEvent];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType
{
    if([UIDevice currentDevice].systemVersion.floatValue >= 8.0f){
        [[GTMediator shareInstance].context.userActivityItem setUserActivityType: userActivityType];
        [[GTModuleManager sharedManager] triggerEvent:GTMWillContinueUserActivityEvent];
    }
    return YES;
}
- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(nullable NSDictionary *)userInfo reply:(void(^)(NSDictionary * __nullable replyInfo))reply {
    if([UIDevice currentDevice].systemVersion.floatValue >= 8.0f){
        [GTMediator shareInstance].context.watchItem.userInfo = userInfo;
        [GTMediator shareInstance].context.watchItem.replyHandler = reply;
        [[GTModuleManager sharedManager] triggerEvent:GTMHandleWatchKitExtensionRequestEvent];
    }
}
#endif
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler  API_AVAILABLE(ios(10.0)){
    [[GTMediator shareInstance].context.notificationsItem setNotification: notification];
    [[GTMediator shareInstance].context.notificationsItem setNotificationPresentationOptionsHandler: completionHandler];
    [[GTMediator shareInstance].context.notificationsItem setCenter:center];
    [[GTModuleManager sharedManager] triggerEvent:GTMWillPresentNotificationEvent];
};

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    [[GTMediator shareInstance].context.notificationsItem setNotificationResponse: response];
    [[GTMediator shareInstance].context.notificationsItem setNotificationCompletionHandler:completionHandler];
    [[GTMediator shareInstance].context.notificationsItem setCenter:center];
    [[GTModuleManager sharedManager] triggerEvent:GTMDidReceiveNotificationResponseEvent];
};






























@end



@implementation GTOpenURLItem

@end

@implementation GTShortcutItem

@end

@implementation GTUserActivityItem

@end

@implementation GTNotificationsItem

@end
