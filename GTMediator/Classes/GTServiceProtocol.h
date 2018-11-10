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

@protocol GTServiceProtocol <NSObject>

@optional

// 是否是单例 如果是单例 将持久化存在
+ (BOOL)singleton;

// 单利对象
+ (id)shareInstance;

// 获取当前bundleName Swift类必须写这个属性 OC可以不写
- (NSString *)bundleName;

// 是否是Swift类 Swift类必须写这个属性
- (BOOL)isSwift;

@end
