//
//  GTServiceProtocol.h
//  FBSnapshotTestCase
//
//  Created by liuxc on 2018/11/10.
//

#import <Foundation/Foundation.h>
#import "GTAnnotation.h"

/**
 服务协议
 */

typedef void(^GTServiceCallbackHandler)(NSDictionary<NSString *, id> *params);

@protocol GTServiceProtocol <NSObject>

@optional

// 回调Block
@property (nonatomic) GTServiceCallbackHandler callback;

// 是否是单例 如果是单例 将持久化存在
+ (BOOL)singleton;

// 单利对象
+ (id)shareInstance;

// 获取当前swiftbundleName Swift类必须写这个属性
- (NSString *)swiftBundleName;

@end
