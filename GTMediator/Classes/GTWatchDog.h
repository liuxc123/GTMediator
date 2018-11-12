//
//  GTWatchDog.h
//  FBSnapshotTestCase
//
//  Created by liuxc on 2018/11/10.
//

#import <Foundation/Foundation.h>

/**
 GTWatchDog是可以开一个线程，设置好handler，每隔一段时间就执行一个handler。
 */
@interface GTWatchDog : NSObject

- (instancetype)initWithThreshold:(double)threshold strictMode:(BOOL)strictMode;

@end
