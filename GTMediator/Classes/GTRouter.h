//
//  GTRouter.h
//  FBSnapshotTestCase
//
//  Created by liuxc on 2018/11/10.
//

#import <Foundation/Foundation.h>

/**
 路由类
 作用：1.负责控制模块间跳转的功能
      2.动态注册服务
      3.动态注册模块
      4.动态注册
 */

static NSString *const GTRURLSchemeGlobalKey = @"URLGlobalScheme";
static NSString *const GTRURLHostCallService = @"call.service.beehive";
static NSString *const GTRURLHostRegister = @"register.beehive";
static NSString *const GTRURLHostJumpViewController = @"jump.vc.beehive";
static NSString *const GTRURLSubPathSplitPattern = @".";
static NSString *const GTRURLQueryParamsKey = @"params";
static NSString *const GTRURLFragmentViewControlerEnterModePush = @"push";
static NSString *const GTRURLFragmentViewControlerEnterModeModal = @"modal";
static NSString *const GTRURLFragmentViewControlerEnterModeShare = @"share";

typedef void(^GTRPathComponentCustomHandler)(NSDictionary<NSString *, id> *params);

@interface GTRouter : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;


+ (instancetype)globalRouter;
+ (instancetype)routerForScheme:(NSString *)scheme;

+ (void)unRegisterRouterForScheme:(NSString *)scheme;
+ (void)unRegisterAllRouters;

//handler is a custom module or service solve function
//处理一个自定义模块或服务解决功能
- (void)addPathComponent:(NSString *)pathComponentKey
                forClass:(Class)mClass;
- (void)addPathComponent:(NSString *)pathComponentKey
                forClass:(Class)mClass
                 handler:(GTRPathComponentCustomHandler)handler;
- (void)addPathComponent:(NSString *)pathComponentKey
                forClass:(Class)mClass
              bundleName:(NSString *)bundleName
                 handler:(GTRPathComponentCustomHandler)handler;
- (void)removePathComponent:(NSString *)pathComponentKey;


//url - >  mediator://call.service.beehive/pathComponentKey.protocolName.selector/...?params={}(value url encode)
//url - >  mediator://register.beehive/pathComponentKey.protocolName/...?params={}(value url encode)
//url - >  mediator://jump.vc.beehive/pathComponentKey.protocolName.push(modal)/...?params={}(value url encode)#push
//params -> {pathComponentKey:{paramName:paramValue,...},...}
//when call service， paramName = @1,@2,...(order of paramValue)
+ (BOOL)canOpenURL:(NSURL *)URL;
+ (BOOL)openURL:(NSURL *)URL;
+ (BOOL)openURL:(NSURL *)URL
     withParams:(NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)params;
+ (BOOL)openURL:(NSURL *)URL
     withParams:(NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)params
        andThen:(void(^)(NSString *pathComponentKey, id obj, id returnValue))then;

@end

