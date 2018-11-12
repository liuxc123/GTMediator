//
//  GTWatchDog.m
//  FBSnapshotTestCase
//
//  Created by liuxc on 2018/11/10.
//

#import "GTWatchDog.h"
#import "GTCommon.h"
#import <UIKit/UIKit.h>

typedef void (^handler)(void);
typedef void (^watchdogFiredCallBack)(void);


@interface PingThread : NSThread

@property (nonatomic, assign) double threshold;
@property (nonatomic, assign) BOOL   pingTaskIsRunning;
@property (nonatomic, copy)   handler handler;

@end

@implementation PingThread

- (instancetype)initWithThreshold:(double)threshold handler:(handler)handler
{
    if (self = [super init]) {
        self.pingTaskIsRunning = NO;
        self.threshold = threshold;
        self.handler = handler;
    }

    return self;
}

- (void)main
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    while (!self.cancelled) {
        self.pingTaskIsRunning = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pingTaskIsRunning = NO;
            dispatch_semaphore_signal(semaphore);
        });

        [NSThread sleepForTimeInterval:self.threshold];
        if (self.pingTaskIsRunning) {
            self.handler();
        }

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
}

@end

@interface GTWatchDog()


@property (nonatomic, assign) double threshold;
@property (nonatomic, strong) PingThread *pingThread;

@end

@implementation GTWatchDog

- (instancetype)initWithThreshold:(double)threshold strictMode:(BOOL)strictMode
{
    self = [self initWithThreshold:threshold callBack:^() {
        NSString *message = [NSString stringWithFormat:@"👮 Main thread was blocked 👮"];
        if (strictMode) {
            //避免后台切换导致进入断言
            NSAssert([UIApplication sharedApplication].applicationState == UIApplicationStateBackground, message);
        } else {
            GTLog(@"%@", message);
        }
    }];

    return self;
}


- (instancetype)initWithThreshold:(double)threshold callBack:(watchdogFiredCallBack)callBack
{
    if (self = [self init]) {
        self.threshold = 0.4;//默认间隔
        self.threshold = threshold;
        self.pingThread = [[PingThread alloc] initWithThreshold:threshold handler:callBack];
        [self.pingThread start];
    }

    return self;
}


- (void)dealloc
{
    [self.pingThread cancel];
}

@end


