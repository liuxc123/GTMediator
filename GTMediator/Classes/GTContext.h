//
//  GTContext.h
//  FBSnapshotTestCase
//
//  Created by liuxc on 2018/11/10.
//

#import <Foundation/Foundation.h>
#import "GTServiceProtocol.h"
#import "GTClientDelegate.h"
#import "GTConfig.h"

//环境场景
typedef NS_ENUM(NSUInteger, GTEnvironmentType) {
    GTEnvironmentTypeDev = 0,   //开发环境
    GTEnvironmentTypeTest,      //测试环境
    GTEnvironmentTypeStage,     //阶段环境
    GTEnvironmentTypeProd       //发布环境
};

/**
 GTMediator框架上下文 Context
 */
@interface GTContext : NSObject

@property(nonatomic, strong) UIWindow *window;
@property(nonatomic, strong) UINavigationController *navigationController;


//全局环境
@property(nonatomic, assign) GTEnvironmentType env;

//全局配置
@property(nonatomic, strong) GTConfig *config;

//客户端appkey
@property(nonatomic, strong) NSString *appkey;

//自定义事件 customEvent >= 1000
@property(nonatomic, assign) NSInteger customEvent;

@property(nonatomic, strong) UIApplication *application;

@property(nonatomic, strong) NSDictionary *launchOptions;

@property(nonatomic, strong) NSString *moduleConfigName;

@property(nonatomic, strong) NSString *serviceConfigName;

//OpenURL model
@property (nonatomic, strong) GTOpenURLItem *openURLItem;

//Notifications Remote or Local
@property (nonatomic, strong) GTNotificationsItem *notificationsItem;

//user Activity Model
@property (nonatomic, strong) GTUserActivityItem *userActivityItem;

//watch Model
@property (nonatomic, strong) GTWatchItem *watchItem;

//custom param
@property (nonatomic, copy) NSDictionary *customParam;


// 单例对象
+ (instancetype)shareInstance;

// 注册一个服务
- (void)addServiceWithImplInstance:(id)implInstance serviceName:(NSString *)serviceName;

// 删除一个服务
- (void)removeServiceWithServiceName:(NSString *)serviceName;

// 根据服务名获取实例
- (id)getServiceInstanceFromServiceName:(NSString *)serviceName;


@end

API_AVAILABLE(ios(9.0))
@interface GTContext ()

//3D-Touch model
@property (nonatomic, strong) GTShortcutItem *touchShortcutItem;

@end
