//
//  GTClientDelegate.h
//  FBSnapshotTestCase
//
//  Created by liuxc on 2018/11/10.
//

/**
 GTClientDelegate 替换AppDelegate 接管整个客户端的生命周期
 */

#import <Foundation/Foundation.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#import <UserNotifications/UserNotifications.h>
#endif


@interface GTClientDelegate : UIResponder <UIApplicationDelegate>

@end

typedef void (^GTNotificationResultHandler)(UIBackgroundFetchResult);
API_AVAILABLE(ios(10.0))
typedef void (^GTNotificationPresentationOptionsHandler)(UNNotificationPresentationOptions options);
typedef void (^GTNotificationCompletionHandler)(void);

@interface GTNotificationsItem : NSObject

@property (nonatomic, strong) NSError *notificationsError;
@property (nonatomic, strong) NSData *deviceToken;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, copy) GTNotificationResultHandler notificationResultHander;
@property (nonatomic, strong) UILocalNotification *localNotification;

@end

API_AVAILABLE(ios(10.0))
@interface GTNotificationsItem ()

@property (nonatomic, strong) UNNotification *notification;
@property (nonatomic, strong) UNNotificationResponse *notificationResponse;
@property (nonatomic, copy) GTNotificationPresentationOptionsHandler notificationPresentationOptionsHandler;
@property (nonatomic, copy) GTNotificationCompletionHandler notificationCompletionHandler;
@property (nonatomic, strong) UNUserNotificationCenter *center;

@end

@interface GTOpenURLItem : NSObject

@property (nonatomic, strong) NSURL *openURL;
@property (nonatomic, copy) NSString *sourceApplication;
@property (nonatomic, strong) id annotation;
@property (nonatomic, strong) NSDictionary *options;

@end

typedef void (^GTShortcutCompletionHandler)(BOOL);

API_AVAILABLE(ios(9.0))
@interface GTShortcutItem : NSObject

@property(nonatomic, strong) UIApplicationShortcutItem *shortcutItem;
@property(nonatomic, copy) GTShortcutCompletionHandler scompletionHandler;

@end

typedef void (^GTUserActivityRestorationHandler)(NSArray *);

@interface GTUserActivityItem : NSObject

@property (nonatomic, copy) NSString *userActivityType;
@property (nonatomic, strong) NSUserActivity *userActivity;
@property (nonatomic, strong) NSError *userActivityError;
@property (nonatomic, copy) GTUserActivityRestorationHandler restorationHandler;

@end


typedef void (^GTWatchReplyHandler)(NSDictionary *replyInfo);

@interface GTWatchItem : NSObject

@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, copy) GTWatchReplyHandler replyHandler;

@end

