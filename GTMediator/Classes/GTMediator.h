//
//  GTMediator.h
//  FBSnapshotTestCase
//
//  Created by liuxc on 2018/11/10.
//

#import <Foundation/Foundation.h>
#import "GTModuleProtocol.h"
#import "GTModuleManager.h"
#import "GTServiceProtocol.h"
#import "GTServiceManager.h"
#import "GTClientDelegate.h"
#import "GTContext.h"
#import "GTDefines.h"

/**
 组件化中间件
 */

@interface GTMediator : NSObject

// 全局上下文
@property(nonatomic, strong) GTContext *context;

// 是否抛出异常
@property (nonatomic, assign) BOOL enableException;

// 单例
+ (instancetype)shareInstance;

// 注册模块
+ (void)registerDynamicModule:(Class) moduleClass;

// 创建服务
- (id)createService:(Protocol *)proto;

//Registration is recommended to use a static way
// 注册服务
- (void)registerService:(Protocol *)proto service:(Class) serviceClass;

// 触发事件
+ (void)triggerCustomEvent:(NSInteger)eventType;

@end

