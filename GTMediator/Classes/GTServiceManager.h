//
//  GTServiceManager.h
//  FBSnapshotTestCase
//
//  Created by liuxc on 2018/11/10.
//

#import <Foundation/Foundation.h>

@class GTContext;

@interface GTServiceManager : NSObject

// 是否抛出异常
@property (nonatomic, assign) BOOL enableException;

//单例对象
+ (instancetype)sharedManager;

// 注册本地所有服务
- (void)registerLocalServices;

// 注册服务
- (void)registerService:(Protocol *)service implClass:(Class)implClass;

// 创建服务 获取服务对象
- (id)createService:(Protocol *)service;
- (id)createService:(Protocol *)service withServiceName:(NSString *)serviceName;
- (id)createService:(Protocol *)service withServiceName:(NSString *)serviceName shouldCache:(BOOL)shouldCache;

// 获取服务对象
- (id)getServiceInstanceFromServiceName:(NSString *)serviceName;

// 删除服务
- (void)removeServiceWithServiceName:(NSString *)serviceName;


@end
