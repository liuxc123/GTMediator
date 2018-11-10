//
//  GTMediator.m
//  FBSnapshotTestCase
//
//  Created by liuxc on 2018/11/10.
//

#import "GTMediator.h"

@implementation GTMediator

#pragma mark - public

+ (instancetype)shareInstance
{
    static dispatch_once_t p;
    static id GTInstance = nil;

    dispatch_once(&p, ^{
        GTInstance = [[self alloc] init];
    });

    return GTInstance;
}

+ (void)registerDynamicModule:(Class)moduleClass
{
    [[GTModuleManager sharedManager] registerDynamicModule:moduleClass];
}

- (id)createService:(Protocol *)proto
{
    return [[GTServiceManager sharedManager] createService:proto];
}

- (void)registerService:(Protocol *)proto service:(Class)serviceClass
{
    [[GTServiceManager sharedManager] registerService:proto implClass:serviceClass];
}

+ (void)triggerCustomEvent:(NSInteger)eventType
{
    if (eventType < 1000) {
        return;
    }

    [[GTModuleManager sharedManager] triggerEvent:eventType];
}

#pragma mark - Private

- (void)setContext:(GTContext *)context
{
    _context = context;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self loadStaticServices];
        [self loadStaticModules];
    });
}

- (void)loadStaticModules
{

    [[GTModuleManager sharedManager] loadLocalModules];

    [[GTModuleManager sharedManager] registedAllModules];

}

- (void)loadStaticServices
{

    [GTServiceManager sharedManager].enableException = self.enableException;

    [[GTServiceManager sharedManager] registerLocalServices];

}

@end
