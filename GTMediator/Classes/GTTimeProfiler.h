//
//  GTTimeProfiler.h
//  FBSnapshotTestCase
//
//  Created by liuxc on 2018/11/10.
//

#import <Foundation/Foundation.h>

@interface GTTimeProfiler : NSObject

#pragma mark - Open API

#define kTimeProfilerResultNotificationName @"GTTimeProfilerResult"
#define kNotificationUserInfoKey            @"logArray"

+ (GTTimeProfiler *)sharedTimeProfiler;

- (instancetype)initTimeProfilerWithMainKey:(NSString *)mainKey;
- (void)recordEventTime:(NSString *)eventName;

- (void)printOutTimeProfileResult;
- (void)saveTimeProfileDataIntoFile:(NSString *)filePath;
- (void)postTimeProfileResultNotification;

@end
