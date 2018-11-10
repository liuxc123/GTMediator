//
//  GTWatchDog.h
//  FBSnapshotTestCase
//
//  Created by liuxc on 2018/11/10.
//

#import <Foundation/Foundation.h>

@interface GTWatchDog : NSObject

- (instancetype)initWithThreshold:(double)threshold strictMode:(BOOL)strictMode;

@end
