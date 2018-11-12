//
//  GTModuleManager.m
//  FBSnapshotTestCase
//
//  Created by liuxc on 2018/11/10.
//

#import "GTModuleManager.h"
#import "GTModuleProtocol.h"
#import "GTContext.h"
#import "GTTimeProfiler.h"
#import "GTAnnotation.h"
#import "GTCommon.h"

#define kModuleArrayKey     @"moduleClasses"
#define kModuleInfoNameKey  @"moduleClass"
#define kModuleInfoTargetKey @"moduleTarget"
#define kModuleInfoLevelKey @"moduleLevel"
#define kModuleInfoPriorityKey @"modulePriority"
#define kModuleInfoHasInstantiatedKey @"moduleHasInstantiated"
#define kModuleBundleNameKey @"moduleBundleName"


static  NSString *kSetupSelector = @"modSetUp:";
static  NSString *kInitSelector = @"modInit:";
static  NSString *kSplashSeletor = @"modSplash:";
static  NSString *kTearDownSelector = @"modTearDown:";
static  NSString *kWillResignActiveSelector = @"modWillResignActive:";
static  NSString *kDidEnterBackgroundSelector = @"modDidEnterBackground:";
static  NSString *kWillEnterForegroundSelector = @"modWillEnterForeground:";
static  NSString *kDidBecomeActiveSelector = @"modDidBecomeActive:";
static  NSString *kWillTerminateSelector = @"modWillTerminate:";
static  NSString *kUnmountEventSelector = @"modUnmount:";
static  NSString *kQuickActionSelector = @"modQuickAction:";
static  NSString *kOpenURLSelector = @"modOpenURL:";
static  NSString *kDidReceiveMemoryWarningSelector = @"modDidReceiveMemoryWaring:";
static  NSString *kFailToRegisterForRemoteNotificationsSelector = @"modDidFailToRegisterForRemoteNotifications:";
static  NSString *kDidRegisterForRemoteNotificationsSelector = @"modDidRegisterForRemoteNotifications:";
static  NSString *kDidReceiveRemoteNotificationsSelector = @"modDidReceiveRemoteNotification:";
static  NSString *kDidReceiveLocalNotificationsSelector = @"modDidReceiveLocalNotification:";
static  NSString *kWillPresentNotificationSelector = @"modWillPresentNotification:";
static  NSString *kDidReceiveNotificationResponseSelector = @"modDidReceiveNotificationResponse:";
static  NSString *kWillContinueUserActivitySelector = @"modWillContinueUserActivity:";
static  NSString *kContinueUserActivitySelector = @"modContinueUserActivity:";
static  NSString *kDidUpdateContinueUserActivitySelector = @"modDidUpdateContinueUserActivity:";
static  NSString *kFailToContinueUserActivitySelector = @"modDidFailToContinueUserActivity:";
static  NSString *kHandleWatchKitExtensionRequestSelector = @"modHandleWatchKitExtensionRequest:";
static  NSString *kAppCustomSelector = @"modDidCustomEvent:";

@interface GTModuleManager()

@property(nonatomic, strong) NSMutableArray     *GTModuleDynamicClasses;

@property(nonatomic, strong) NSMutableArray<NSDictionary *>     *GTModuleInfos;
@property(nonatomic, strong) NSMutableArray     *GTModules;

@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableArray<id<GTModuleProtocol>> *> *GTModulesByEvent;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NSString *> *GTSelectorByEvent;

@end

@implementation GTModuleManager

#pragma mark - public

+ (instancetype)sharedManager
{
    static id sharedManager = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedManager = [[GTModuleManager alloc] init];
    });
    return sharedManager;
}

- (void)loadLocalModules
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:[GTContext shareInstance].moduleConfigName ofType:@"plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        return;
    }
    NSDictionary *moduleList = [[NSDictionary alloc] initWithContentsOfFile:plistPath];

    NSArray<NSDictionary *> *modulesArray = [moduleList objectForKey:kModuleArrayKey];

    NSMutableDictionary<NSString *, NSNumber *> *moduleInfoByClass = @{}.mutableCopy;
    [self.GTModuleInfos enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [moduleInfoByClass setObject:@1 forKey:[obj objectForKey:kModuleInfoNameKey]];
    }];
    [modulesArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!moduleInfoByClass[[obj objectForKey:kModuleInfoNameKey]]) {
            [self.GTModuleInfos addObject:obj];
        }
    }];
}

- (void)registerDynamicModule:(Class)moduleClass
{
    [self registerDynamicModule:moduleClass shouldTriggerInitEvent:NO];
}

- (void)registerDynamicModule:(Class)moduleClass
       shouldTriggerInitEvent:(BOOL)shouldTriggerInitEvent
{
    [self addModuleFromObject:moduleClass shouldTriggerInitEvent:shouldTriggerInitEvent];
}

- (void)unRegisterDynamicModule:(Class)moduleClass {
    if (!moduleClass) {
        return;
    }
    [self.GTModuleInfos filterUsingPredicate:[NSPredicate predicateWithFormat:@"%@!=%@", kModuleInfoNameKey, NSStringFromClass(moduleClass)]];
    __block NSInteger index = -1;
    [self.GTModules enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:moduleClass]) {
            index = idx;
            *stop = YES;
        }
    }];
    if (index >= 0) {
        [self.GTModules removeObjectAtIndex:index];
    }
    [self.GTModulesByEvent enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSMutableArray<id<GTModuleProtocol>> * _Nonnull obj, BOOL * _Nonnull stop) {
        __block NSInteger index = -1;
        [obj enumerateObjectsUsingBlock:^(id<GTModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:moduleClass]) {
                index = idx;
                *stop = NO;
            }
        }];
        if (index >= 0) {
            [obj removeObjectAtIndex:index];
        }
    }];
}

- (void)registedAllModules
{
    [self.GTModuleInfos sortUsingComparator:^NSComparisonResult(NSDictionary *module1, NSDictionary *module2) {
        NSNumber *module1Level = (NSNumber *)[module1 objectForKey:kModuleInfoLevelKey];
        NSNumber *module2Level =  (NSNumber *)[module2 objectForKey:kModuleInfoLevelKey];
        if (module1Level.integerValue != module2Level.integerValue) {
            return module1Level.integerValue > module2Level.integerValue;
        } else {
            NSNumber *module1Priority = (NSNumber *)[module1 objectForKey:kModuleInfoPriorityKey];
            NSNumber *module2Priority = (NSNumber *)[module2 objectForKey:kModuleInfoPriorityKey];
            return module1Priority.integerValue < module2Priority.integerValue;
        }
    }];

    NSMutableArray *tmpArray = [NSMutableArray array];

    //module init
    [self.GTModuleInfos enumerateObjectsUsingBlock:^(NSDictionary *module, NSUInteger idx, BOOL * _Nonnull stop) {

        NSString *classStr = [module objectForKey:kModuleInfoNameKey];
//        if (!NSClassFromString([module objectForKey:kModuleInfoNameKey])) {
//            classStr = [NSString stringWithFormat:@"%@.%@", [module objectForKey:kModuleBundleNameKey], [module objectForKey:kModuleInfoNameKey]];
//        }
        Class moduleClass = NSClassFromString(classStr);
        BOOL hasInstantiated = ((NSNumber *)[module objectForKey:kModuleInfoHasInstantiatedKey]).boolValue;
        if (NSStringFromClass(moduleClass) && !hasInstantiated) {
            id<GTModuleProtocol> moduleInstance = [[moduleClass alloc] init];
            [tmpArray addObject:moduleInstance];
        }
    }];

    [self.GTModules addObjectsFromArray:tmpArray];

    [self registerAllSystemEvents];

}

- (void)registerCustomEvent:(NSInteger)eventType
         withModuleInstance:(id)moduleInstance
             andSelectorStr:(NSString *)selectorStr {
    if (eventType < 1000) {
        return;
    }
    [self registerEvent:eventType withModuleInstance:moduleInstance andSelectorStr:selectorStr];
}


- (void)triggerEvent:(NSInteger)eventType
{
    [self triggerEvent:eventType withCustomParam:nil];
}

- (void)triggerEvent:(NSInteger)eventType
     withCustomParam:(NSDictionary *)customParam {
    [self handleModuleEvent:eventType forTarget:nil withCustomParam:customParam];
}

#pragma mark - life loop

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.GTModuleDynamicClasses = [NSMutableArray array];
    }
    return self;
}

#pragma mark - private

- (GTModuleLevel)checkModuleLevel:(NSUInteger)level
{
    switch (level) {
        case 0:
            return GTModuleLevelBasic;
            break;
        case 1:
            return GTModuleLevelNormal;
            break;
        default:
            break;
    }
    //default normal
    return GTModuleLevelNormal;
}

- (void)addModuleFromObject:(id)object
     shouldTriggerInitEvent:(BOOL)shouldTriggerInitEvent
{
    Class class;
    NSString *moduleName = nil;

    if (object) {
        class = object;
        moduleName = NSStringFromClass(class);
    } else {
        return ;
    }

    __block BOOL flag = YES;
    [self.GTModules enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:class]) {
            flag = NO;
            *stop = YES;
        }
    }];
    if (!flag) {
        return;
    }

    if ([class conformsToProtocol:@protocol(GTModuleProtocol)]) {
        NSMutableDictionary *moduleInfo = [NSMutableDictionary dictionary];

        BOOL responseBasicLevel = [class instancesRespondToSelector:@selector(basicModuleLevel)];

        int levelInt = 1;

        if (responseBasicLevel) {
            levelInt = 0;
        }

        [moduleInfo setObject:@(levelInt) forKey:kModuleInfoLevelKey];
        if (moduleName) {
            [moduleInfo setObject:moduleName forKey:kModuleInfoNameKey];
        }

        [self.GTModuleInfos addObject:moduleInfo];

        id<GTModuleProtocol> moduleInstance = [[class alloc] init];
        [self.GTModules addObject:moduleInstance];
        [moduleInfo setObject:@(YES) forKey:kModuleInfoHasInstantiatedKey];
        [self.GTModules sortUsingComparator:^NSComparisonResult(id<GTModuleProtocol> moduleInstance1, id<GTModuleProtocol> moduleInstance2) {
            NSNumber *module1Level = @(GTModuleLevelNormal);
            NSNumber *module2Level = @(GTModuleLevelNormal);
            if ([moduleInstance1 respondsToSelector:@selector(basicModuleLevel)]) {
                module1Level = @(GTModuleLevelBasic);
            }
            if ([moduleInstance2 respondsToSelector:@selector(basicModuleLevel)]) {
                module2Level = @(GTModuleLevelBasic);
            }
            if (module1Level.integerValue != module2Level.integerValue) {
                return module1Level.integerValue > module2Level.integerValue;
            } else {
                NSInteger module1Priority = 0;
                NSInteger module2Priority = 0;
                if ([moduleInstance1 respondsToSelector:@selector(modulePriority)]) {
                    module1Priority = [moduleInstance1 modulePriority];
                }
                if ([moduleInstance2 respondsToSelector:@selector(modulePriority)]) {
                    module2Priority = [moduleInstance2 modulePriority];
                }
                return module1Priority < module2Priority;
            }
        }];
        [self registerEventsByModuleInstance:moduleInstance];

        if (shouldTriggerInitEvent) {
            [self handleModuleEvent:GTMSetupEvent forTarget:moduleInstance withSeletorStr:nil andCustomParam:nil];
            [self handleModulesInitEventForTarget:moduleInstance withCustomParam:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleModuleEvent:GTMSplashEvent forTarget:moduleInstance withSeletorStr:nil andCustomParam:nil];
            });
        }
    }

}

- (void)registerAllSystemEvents
{
    [self.GTModules enumerateObjectsUsingBlock:^(id<GTModuleProtocol> moduleInstance, NSUInteger idx, BOOL * _Nonnull stop) {
        [self registerEventsByModuleInstance:moduleInstance];
    }];
}

- (void)registerEventsByModuleInstance:(id<GTModuleProtocol>)moduleInstance
{
    NSArray<NSNumber *> *events = self.GTSelectorByEvent.allKeys;
    [events enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self registerEvent:obj.integerValue withModuleInstance:moduleInstance andSelectorStr:self.GTSelectorByEvent[obj]];
    }];
}

- (void)registerEvent:(NSInteger)eventType
   withModuleInstance:(id)moduleInstance
       andSelectorStr:(NSString *)selectorStr
{
    SEL selector = NSSelectorFromString(selectorStr);
    if (!selector || ![moduleInstance respondsToSelector:selector]) {
        return;
    }
    NSNumber *eventTypeNumber = @(eventType);
    if (!self.GTSelectorByEvent[eventTypeNumber]) {
        [self.GTSelectorByEvent setObject:selectorStr forKey:eventTypeNumber];
    }
    if (!self.GTModulesByEvent[eventTypeNumber]) {
        [self.GTModulesByEvent setObject:@[].mutableCopy forKey:eventTypeNumber];
    }
    NSMutableArray *eventModules = [self.GTModulesByEvent objectForKey:eventTypeNumber];
    if (![eventModules containsObject:moduleInstance]) {
        [eventModules addObject:moduleInstance];
        [eventModules sortUsingComparator:^NSComparisonResult(id<GTModuleProtocol> moduleInstance1, id<GTModuleProtocol> moduleInstance2) {
            NSNumber *module1Level = @(GTModuleLevelNormal);
            NSNumber *module2Level = @(GTModuleLevelNormal);
            if ([moduleInstance1 respondsToSelector:@selector(basicModuleLevel)]) {
                module1Level = @(GTModuleLevelBasic);
            }
            if ([moduleInstance2 respondsToSelector:@selector(basicModuleLevel)]) {
                module2Level = @(GTModuleLevelBasic);
            }
            if (module1Level.integerValue != module2Level.integerValue) {
                return module1Level.integerValue > module2Level.integerValue;
            } else {
                NSInteger module1Priority = 0;
                NSInteger module2Priority = 0;
                if ([moduleInstance1 respondsToSelector:@selector(modulePriority)]) {
                    module1Priority = [moduleInstance1 modulePriority];
                }
                if ([moduleInstance2 respondsToSelector:@selector(modulePriority)]) {
                    module2Priority = [moduleInstance2 modulePriority];
                }
                return module1Priority < module2Priority;
            }
        }];
    }
}


#pragma mark - property setter or getter
- (NSMutableArray<NSDictionary *> *)GTModuleInfos {
    if (!_GTModuleInfos) {
        _GTModuleInfos = @[].mutableCopy;
    }
    return _GTModuleInfos;
}

- (NSMutableArray *)GTModules
{
    if (!_GTModules) {
        _GTModules = [NSMutableArray array];
    }
    return _GTModules;
}

- (NSMutableDictionary<NSNumber *, NSMutableArray<id<GTModuleProtocol>> *> *)GTModulesByEvent
{
    if (!_GTModulesByEvent) {
        _GTModulesByEvent = @{}.mutableCopy;
    }
    return _GTModulesByEvent;
}

- (NSMutableDictionary<NSNumber *, NSString *> *)GTSelectorByEvent
{
    if (!_GTSelectorByEvent) {
        _GTSelectorByEvent = @{
                               @(GTMSetupEvent):kSetupSelector,
                               @(GTMInitEvent):kInitSelector,
                               @(GTMTearDownEvent):kTearDownSelector,
                               @(GTMSplashEvent):kSplashSeletor,
                               @(GTMWillResignActiveEvent):kWillResignActiveSelector,
                               @(GTMDidEnterBackgroundEvent):kDidEnterBackgroundSelector,
                               @(GTMWillEnterForegroundEvent):kWillEnterForegroundSelector,
                               @(GTMDidBecomeActiveEvent):kDidBecomeActiveSelector,
                               @(GTMWillTerminateEvent):kWillTerminateSelector,
                               @(GTMUnmountEvent):kUnmountEventSelector,
                               @(GTMOpenURLEvent):kOpenURLSelector,
                               @(GTMDidReceiveMemoryWarningEvent):kDidReceiveMemoryWarningSelector,

                               @(GTMDidReceiveRemoteNotificationEvent):kDidReceiveRemoteNotificationsSelector,
                               @(GTMWillPresentNotificationEvent):kWillPresentNotificationSelector,
                               @(GTMDidReceiveNotificationResponseEvent):kDidReceiveNotificationResponseSelector,

                               @(GTMDidFailToRegisterForRemoteNotificationsEvent):kFailToRegisterForRemoteNotificationsSelector,
                               @(GTMDidRegisterForRemoteNotificationsEvent):kDidRegisterForRemoteNotificationsSelector,

                               @(GTMDidReceiveLocalNotificationEvent):kDidReceiveLocalNotificationsSelector,

                               @(GTMWillContinueUserActivityEvent):kWillContinueUserActivitySelector,

                               @(GTMContinueUserActivityEvent):kContinueUserActivitySelector,

                               @(GTMDidFailToContinueUserActivityEvent):kFailToContinueUserActivitySelector,

                               @(GTMDidUpdateUserActivityEvent):kDidUpdateContinueUserActivitySelector,

                               @(GTMQuickActionEvent):kQuickActionSelector,
                               @(GTMHandleWatchKitExtensionRequestEvent):kHandleWatchKitExtensionRequestSelector,
                               @(GTMDidCustomEvent):kAppCustomSelector,
                               }.mutableCopy;
    }
    return _GTSelectorByEvent;
}


#pragma mark - module protocol
- (void)handleModuleEvent:(NSInteger)eventType
                forTarget:(id<GTModuleProtocol>)target
          withCustomParam:(NSDictionary *)customParam
{
    switch (eventType) {
        case GTMInitEvent:
            //special
            [self handleModulesInitEventForTarget:nil withCustomParam :customParam];
            break;
        case GTMTearDownEvent:
            //special
            [self handleModulesTearDownEventForTarget:nil withCustomParam:customParam];
            break;
        default: {
            NSString *selectorStr = [self.GTSelectorByEvent objectForKey:@(eventType)];
            [self handleModuleEvent:eventType forTarget:nil withSeletorStr:selectorStr andCustomParam:customParam];
        }
            break;
    }

}

- (void)handleModulesInitEventForTarget:(id<GTModuleProtocol>)target
                        withCustomParam:(NSDictionary *)customParam
{
    GTContext *context = [GTContext shareInstance].copy;
    context.customParam = customParam;
    context.customEvent = GTMInitEvent;

    NSArray<id<GTModuleProtocol>> *moduleInstances;
    if (target) {
        moduleInstances = @[target];
    } else {
        moduleInstances = [self.GTModulesByEvent objectForKey:@(GTMInitEvent)];
    }

    [moduleInstances enumerateObjectsUsingBlock:^(id<GTModuleProtocol> moduleInstance, NSUInteger idx, BOOL * _Nonnull stop) {
        __weak typeof(&*self) wself = self;
        void ( ^ bk )(void);
        bk = ^(){
            __strong typeof(&*self) sself = wself;
            if (sself) {
                if ([moduleInstance respondsToSelector:@selector(modInit:)]) {
                    [moduleInstance modInit:context];
                }
            }
        };

        [[GTTimeProfiler sharedTimeProfiler] recordEventTime:[NSString stringWithFormat:@"%@ --- modInit:", [moduleInstance class]]];

        if ([moduleInstance respondsToSelector:@selector(async)]) {
            BOOL async = [moduleInstance async];

            if (async) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    bk();
                });

            } else {
                bk();
            }
        } else {
            bk();
        }
    }];

}


- (void)handleModulesTearDownEventForTarget:(id<GTModuleProtocol>)target
                            withCustomParam:(NSDictionary *)customParam
{
    GTContext *context = [GTContext shareInstance].copy;
    context.customParam = customParam;
    context.customEvent = GTMTearDownEvent;

    NSArray<id<GTModuleProtocol>> *moduleInstances;
    if (target) {
        moduleInstances = @[target];
    } else {
        moduleInstances = [self.GTModulesByEvent objectForKey:@(GTMTearDownEvent)];
    }

    //Reverse Order to unload
    for (int i = (int)moduleInstances.count - 1; i >= 0; i--) {
        id<GTModuleProtocol> moduleInstance = [moduleInstances objectAtIndex:i];
        if (moduleInstance && [moduleInstance respondsToSelector:@selector(modTearDown:)]) {
            [moduleInstance modTearDown:context];
        }
    }
}

- (void)handleModuleEvent:(NSInteger)eventType
                forTarget:(id<GTModuleProtocol>)target
           withSeletorStr:(NSString *)selectorStr
           andCustomParam:(NSDictionary *)customParam
{
    GTContext *context = [GTContext shareInstance].copy;
    context.customParam = customParam;
    context.customEvent = eventType;
    if (!selectorStr.length) {
        selectorStr = [self.GTSelectorByEvent objectForKey:@(eventType)];
    }
    SEL seletor = NSSelectorFromString(selectorStr);
    if (!seletor) {
        selectorStr = [self.GTSelectorByEvent objectForKey:@(eventType)];
        seletor = NSSelectorFromString(selectorStr);
    }
    NSArray<id<GTModuleProtocol>> *moduleInstances;
    if (target) {
        moduleInstances = @[target];
    } else {
        moduleInstances = [self.GTModulesByEvent objectForKey:@(eventType)];
    }
    [moduleInstances enumerateObjectsUsingBlock:^(id<GTModuleProtocol> moduleInstance, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([moduleInstance respondsToSelector:seletor]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [moduleInstance performSelector:seletor withObject:context];
#pragma clang diagnostic pop

            [[GTTimeProfiler sharedTimeProfiler] recordEventTime:[NSString stringWithFormat:@"%@ --- %@", [moduleInstance class], NSStringFromSelector(seletor)]];
        }
    }];
}



@end
