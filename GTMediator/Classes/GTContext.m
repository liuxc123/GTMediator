//
//  GTContext.m
//  FBSnapshotTestCase
//
//  Created by liuxc on 2018/11/10.
//

#import "GTContext.h"

@interface GTContext()

@property(nonatomic, strong) NSMutableDictionary *modulesByName;

@property(nonatomic, strong) NSMutableDictionary *servicesByName;

@end

@implementation GTContext

+ (instancetype)shareInstance
{
    static dispatch_once_t p;
    static id GTInstance = nil;

    dispatch_once(&p, ^{
        GTInstance = [[[self class] alloc] init];
        if ([GTInstance isKindOfClass:[GTContext class]]) {
            ((GTContext *) GTInstance).config = [GTConfig shareInstance];
        }
    });

    return GTInstance;
}

- (void)addServiceWithImplInstance:(id)implInstance serviceName:(NSString *)serviceName
{
    [[GTContext shareInstance].servicesByName setObject:implInstance forKey:serviceName];
}

- (void)removeServiceWithServiceName:(NSString *)serviceName
{
    [[GTContext shareInstance].servicesByName removeObjectForKey:serviceName];
}

- (id)getServiceInstanceFromServiceName:(NSString *)serviceName
{
    return [[GTContext shareInstance].servicesByName objectForKey:serviceName];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modulesByName  = [[NSMutableDictionary alloc] initWithCapacity:1];
        self.servicesByName  = [[NSMutableDictionary alloc] initWithCapacity:1];
        self.moduleConfigName = @"BeeHive.bundle/BeeHive";
        self.serviceConfigName = @"BeeHive.bundle/BHService";
        if (@available(iOS 9.0, *)) {
            self.touchShortcutItem = [GTShortcutItem new];
        }
        self.openURLItem = [GTOpenURLItem new];
        self.notificationsItem = [GTNotificationsItem new];
        self.userActivityItem = [GTUserActivityItem new];
    }

    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    GTContext *context = [[self.class allocWithZone:zone] init];

    context.env = self.env;
    context.config = self.config;
    context.appkey = self.appkey;
    context.customEvent = self.customEvent;
    context.application = self.application;
    context.launchOptions = self.launchOptions;
    context.moduleConfigName = self.moduleConfigName;
    context.serviceConfigName = self.serviceConfigName;
    if (@available(iOS 9.0, *)) {
        context.touchShortcutItem = self.touchShortcutItem;
    }
    context.openURLItem = self.openURLItem;
    context.notificationsItem = self.notificationsItem;
    context.userActivityItem = self.userActivityItem;
    context.customParam = self.customParam;

    return context;
}

@end
