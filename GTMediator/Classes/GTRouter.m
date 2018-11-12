//
//  GTRouter.m
//  FBSnapshotTestCase
//
//  Created by liuxc on 2018/11/10.
//

#import "GTRouter.h"


#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "GTModuleProtocol.h"
#import "GTServiceProtocol.h"
#import "GTCommon.h"
#import "GTModuleManager.h"
#import "GTServiceManager.h"
#import "GTContext.h"
#import "GTMediatorNavigator.h"

@interface NSObject (GTRetType)

+ (id)gt_getReturnFromInv:(NSInvocation *)inv withSig:(NSMethodSignature *)sig;

@end

@implementation NSObject (GTRetType)

+ (id)gt_getReturnFromInv:(NSInvocation *)inv withSig:(NSMethodSignature *)sig {
    NSUInteger length = [sig methodReturnLength];
    if (length == 0) return nil;
    
    char *type = (char *)[sig methodReturnType];
    while (*type == 'r' || // const
           *type == 'n' || // in
           *type == 'N' || // inout
           *type == 'o' || // out
           *type == 'O' || // bycopy
           *type == 'R' || // byref
           *type == 'V') { // oneway
        type++; // cutoff useless prefix
    }
    
#define return_with_number(_type_) \
do { \
_type_ ret; \
[inv getReturnValue:&ret]; \
return @(ret); \
} while (0)
    
    switch (*type) {
        case 'v': return nil; // void
        case 'B': return_with_number(bool);
        case 'c': return_with_number(char);
        case 'C': return_with_number(unsigned char);
        case 's': return_with_number(short);
        case 'S': return_with_number(unsigned short);
        case 'i': return_with_number(int);
        case 'I': return_with_number(unsigned int);
        case 'l': return_with_number(int);
        case 'L': return_with_number(unsigned int);
        case 'q': return_with_number(long long);
        case 'Q': return_with_number(unsigned long long);
        case 'f': return_with_number(float);
        case 'd': return_with_number(double);
        case 'D': { // long double
            long double ret;
            [inv getReturnValue:&ret];
            return [NSNumber numberWithDouble:ret];
        };
            
        case '@': { // id
            id ret = nil;
            [inv getReturnValue:&ret];
            return ret;
        };
            
        case '#': { // Class
            Class ret = nil;
            [inv getReturnValue:&ret];
            return ret;
        };
            
        default: { // struct / union / SEL / void* / unknown
            const char *objCType = [sig methodReturnType];
            char *buf = calloc(1, length);
            if (!buf) return nil;
            [inv getReturnValue:buf];
            NSValue *value = [NSValue valueWithBytes:buf objCType:objCType];
            free(buf);
            return value;
        };
    }
#undef return_with_number
}

@end

static NSString *const GTRClassRegex = @"(?<=T@\")(.*)(?=\",)";

typedef NS_ENUM(NSUInteger, GTRViewControlerEnterMode) {
    GTRViewControlerEnterModePush,
    GTRViewControlerEnterModeModal,
    GTRViewControlerEnterModeShare
};

typedef NS_ENUM(NSUInteger, GTRUsage) {
    GTRUsageUnknown,
    GTRUsageCallService,
    GTRUsageJumpViewControler,
    GTRUsageRegister
};

static NSMutableDictionary<NSString *, GTRouter *> *routerByScheme = nil;

@interface GTRPathComponent : NSObject

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *bundleName;
@property (nonatomic, strong) Class mClass;
@property (nonatomic, copy) NSDictionary<NSString *, id> *params;
@property (nonatomic, copy) GTRPathComponentCustomHandler handler;

@end

@implementation GTRPathComponent


@end

static NSString *GTRURLGlobalScheme = nil;

@interface GTRouter ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, GTRPathComponent *> *pathComponentByKey;
@property (nonatomic, copy) NSString *scheme;

@end

@implementation GTRouter

#pragma mark - property init
- (NSMutableDictionary<NSString *, GTRPathComponent *> *)pathComponentByKey {
    if (!_pathComponentByKey) {
        _pathComponentByKey = @{}.mutableCopy;
    }
    return _pathComponentByKey;
}


#pragma mark - router init

+ (instancetype)globalRouter
{
    if (!GTRURLGlobalScheme) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:[GTContext shareInstance].moduleConfigName ofType:@"plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
            NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
            GTRURLGlobalScheme = [plist objectForKey:GTRURLSchemeGlobalKey];
        }
        if (!GTRURLGlobalScheme.length) {
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            GTRURLGlobalScheme = [infoDictionary objectForKey:@"CFBundleIdentifier"];
        }
        if (!GTRURLGlobalScheme.length) {
            GTRURLGlobalScheme = @"com.liuxc.mediator";
        }
    }
    return [self routerForScheme:GTRURLGlobalScheme];
}

+ (instancetype)routerForScheme:(NSString *)scheme
{
    if (!scheme.length) {
        return nil;
    }
    
    GTRouter *router = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        routerByScheme = @{}.mutableCopy;
    });
    
    if (!routerByScheme[scheme]) {
        router = [[self alloc] init];
        router.scheme = scheme;
        [routerByScheme setObject:router forKey:scheme];
    } else {
        router = [routerByScheme objectForKey:scheme];
    }
    
    return router;
}

+ (void)unRegisterRouterForScheme:(NSString *)scheme
{
    if (!scheme.length) {
        return;
    }
    
    [routerByScheme removeObjectForKey:scheme];
}

+ (void)unRegisterAllRouters
{
    [routerByScheme removeAllObjects];
}

- (void)addPathComponent:(NSString *)pathComponentKey
                forClass:(Class)mClass
{
    [self addPathComponent:pathComponentKey forClass:mClass handler:nil];
}

//handler is a custom module or service init function
- (void)addPathComponent:(NSString *)pathComponentKey
                forClass:(Class)mClass
                 handler:(GTRPathComponentCustomHandler)handler
{
    [self addPathComponent:pathComponentKey forClass:mClass bundleName:nil handler:handler];
}

- (void)addPathComponent:(NSString *)pathComponentKey
                forClass:(Class)mClass
              bundleName:(NSString *)bundleName
                 handler:(GTRPathComponentCustomHandler)handler
{
    GTRPathComponent *pathComponent = [[GTRPathComponent alloc] init];
    pathComponent.key = pathComponentKey;
    pathComponent.mClass = mClass;
    pathComponent.handler = handler;
    pathComponent.bundleName = bundleName;
    [self.pathComponentByKey setObject:pathComponent forKey:pathComponentKey];
}

- (void)removePathComponent:(NSString *)pathComponentKey
{
    [self.pathComponentByKey removeObjectForKey:pathComponentKey];
}

+ (BOOL)canOpenURL:(NSURL *)URL
{
    if (!URL) {
        return NO;
    }
    NSString *scheme = URL.scheme;
    if (!scheme.length) {
        return NO;
    }
    
    NSString *host = URL.host;
    GTRUsage usage = [self usage:host];
    if (usage == GTRUsageUnknown) {
        return NO;
    }
    
    GTRouter *router = [self routerForScheme:scheme];

    NSArray<NSString *> *pathComponents = URL.pathComponents;

    __block BOOL flag = YES;
    
    [pathComponents enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<NSString *> * subPaths = [obj componentsSeparatedByString:GTRURLSubPathSplitPattern];
        if (!subPaths.count) {
            flag = NO;
            *stop = NO;
            return;
        }
        NSString *pathComponentKey = subPaths.firstObject;
        if (router.pathComponentByKey[pathComponentKey]) {
            return;
        }
        
        if ([pathComponentKey isEqualToString:@"/"]) {
            return;
        }
        
        //已下目前只支持OC Swift必须通过addPathComponent注册类
        Class mClass = NSClassFromString(pathComponentKey);
        if (!mClass) {
            flag = NO;
            *stop = NO;
            NSLog(@"mClass: %@ == nil", pathComponentKey);
            return;
        }
        
        switch (usage) {
            case GTRUsageCallService: {
                if (subPaths.count < 3) {
                    flag = NO;
                    *stop = NO;
                    return;
                }
                NSString *protocolStr = subPaths[1];
                NSString *selectorStr = subPaths[2];
                Protocol *protocol = NSProtocolFromString(protocolStr);
                SEL selector = NSSelectorFromString(selectorStr);
                if (!protocol ||
                    !selector ||
                    ![mClass conformsToProtocol:@protocol(GTServiceProtocol)] ||
                    ![mClass conformsToProtocol:protocol] ||
                    ![mClass instancesRespondToSelector:selector]) {
                    flag = NO;
                    *stop = NO;
                    return;
                }
            } break;
            case GTRUsageJumpViewControler: {
                if (![mClass isSubclassOfClass:[UIViewController class]]) {
                    flag = NO;
                    *stop = NO;
                    return;
                }
            } break;
            case GTRUsageRegister: {
                if (![mClass conformsToProtocol:@protocol(GTServiceProtocol)]) {
                    return;
                }
                if (subPaths.count < 2) {
                    flag = NO;
                    *stop = NO;
                    return;
                }
                NSString *protocolStr = subPaths[1];
                Protocol *protocol = NSProtocolFromString(protocolStr);
                if (!protocol || ![mClass conformsToProtocol:protocol]) {
                    flag = NO;
                    *stop = NO;
                }
            } break;
                
            default:
                break;
        }
        
    }];
    
    return flag;
}

+ (BOOL)openURL:(NSURL *)URL
{
    return [self openURL:URL withParams:nil andThen:nil];
}
+ (BOOL)openURL:(NSURL *)URL
     withParams:(NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)params
{
    return [self openURL:URL withParams:params andThen:nil];
}

+ (BOOL)openURL:(NSURL *)URL
     withParams:(NSDictionary<NSString *,NSDictionary<NSString *,id> *> *)params
        andThen:(void (^)(NSString *, id, id))then
{
    if (![self canOpenURL:URL]) {
        return NO;
    }
    
    NSString *scheme = URL.scheme;
    GTRouter *router = [self routerForScheme:scheme];
    
    NSString *host = URL.host;
    GTRUsage usage = [self usage:host];
    
    GTRViewControlerEnterMode defaultMode = GTRViewControlerEnterModePush;
    if (URL.fragment.length) {
        defaultMode = [self viewControllerEnterMode:URL.fragment];
    }
    
    NSDictionary<NSString *, NSString *> *queryDic = [self queryDicFromURL:URL];
    NSString *paramsJson = [queryDic objectForKey:GTRURLQueryParamsKey];
    NSDictionary<NSString *, NSDictionary<NSString *, id> *> *allURLParams = [self paramsFromJson:paramsJson];
    
    NSArray<NSString *> *pathComponents = URL.pathComponents;
    
    [pathComponents enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isEqualToString:@"/"]) {
            
            NSArray<NSString *> * subPaths = [obj componentsSeparatedByString:GTRURLSubPathSplitPattern];
            NSString *pathComponentKey = subPaths.firstObject;
            
            Class mClass;
            GTRPathComponentCustomHandler handler;
            GTRPathComponent *pathComponent = [router.pathComponentByKey objectForKey:pathComponentKey];
            if (pathComponent) {
                mClass = pathComponent.mClass;
                handler = pathComponent.handler;
            } else {
                mClass = NSClassFromString(pathComponentKey);
            }
            
            NSDictionary<NSString *, id> *URLParams = [allURLParams objectForKey:pathComponentKey];
            NSDictionary<NSString *, id> *funcParams = [params objectForKey:pathComponentKey];
            NSDictionary<NSString *, id> *finalParams = [self solveURLParams:URLParams withFuncParams:funcParams forClass:usage == GTRUsageCallService ? nil : mClass];
            
            if (handler) {
                handler(finalParams);
                return;
            }
            
            NSString *protocolStr;
            Protocol *protocol;
            if (subPaths.count >= 2) {
                protocolStr = subPaths[1];
                protocol = NSProtocolFromString(protocolStr);
            }
            
            id obj;
            id returnValue;
            
            switch (usage) {
                case GTRUsageCallService: {
                    NSString *selectorStr = subPaths[2];
                    SEL selector = NSSelectorFromString(selectorStr);
                    obj = [[GTServiceManager sharedManager] createService:protocol];
                    returnValue = [self safePerformAction:selector forTarget:obj withParams:finalParams];
                } break;
                case GTRUsageJumpViewControler: {
                    GTRViewControlerEnterMode enterMode = defaultMode;
                    if (subPaths.count >= 3) {
                        enterMode = [self viewControllerEnterMode:subPaths[2]];
                    }
                    
                    if ([mClass conformsToProtocol:@protocol(GTServiceProtocol)] && protocol) {
                        obj = [[GTServiceManager sharedManager] createService:protocol];
                    } else {
                        obj = [[mClass alloc] init];
                    }
                    [self setObject:obj withPropertys:finalParams];
                    BOOL isLast = pathComponents.count - 1 ? YES : NO;
                    [self solveJumpWithViewController:(UIViewController *)obj andJumpMode:enterMode shouldAnimate:isLast];
                } break;
                case GTRUsageRegister: {
                    if ([mClass conformsToProtocol:@protocol(GTModuleProtocol)]) {
                        [[GTModuleManager sharedManager] registerDynamicModule:mClass];
                    } else if ([mClass conformsToProtocol:@protocol(GTServiceProtocol)] && protocol) {
                        [[GTServiceManager sharedManager] registerService:protocol implClass:mClass];
                    }
                } break;
                    
                default:
                    break;
            }
            
            !then?:then(pathComponentKey, obj, returnValue);
        }
    }];
    return YES;
}


#pragma mark - private

+ (GTRUsage)usage:(NSString *)usagePattern
{
    usagePattern = usagePattern.lowercaseString;
    if ([usagePattern isEqualToString:GTRURLHostCallService]) {
        return GTRUsageCallService;
    } else if ([usagePattern isEqualToString:GTRURLHostJumpViewController]) {
        return GTRUsageJumpViewControler;
    } else if ([usagePattern isEqualToString:GTRURLHostRegister]) {
        return GTRUsageRegister;
    }
    return GTRUsageUnknown;
}


+ (GTRViewControlerEnterMode)viewControllerEnterMode:(NSString *)enterModePattern
{
    enterModePattern = enterModePattern.lowercaseString;
    if ([enterModePattern isEqualToString:GTRURLFragmentViewControlerEnterModePush]) {
        return GTRViewControlerEnterModePush;
    } else if ([enterModePattern isEqualToString:GTRURLFragmentViewControlerEnterModeModal]) {
        return GTRViewControlerEnterModeModal;
    } else if ([enterModePattern isEqualToString:GTRURLFragmentViewControlerEnterModeShare]) {
        return GTRViewControlerEnterModeShare;
    }
    return GTRViewControlerEnterModePush;
}


+ (NSDictionary<NSString *, id> *)queryDicFromURL:(NSURL *)URL
{
    if (!URL) {
        return nil;
    }
    if ([UIDevice currentDevice].systemVersion.floatValue < 8) {
        NSMutableDictionary *dic = @{}.mutableCopy;
        NSString *query = URL.query;
        NSArray<NSString *> *queryStrs = [query componentsSeparatedByString:@"&"];
        [queryStrs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *keyValue = [obj componentsSeparatedByString:@"="];
            if (keyValue.count >= 2) {
                NSString *key = keyValue[0];
                NSString *value = keyValue[1];
                [dic setObject:value forKey:key];
            }
        }];
        return dic;
    } else {
        NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URL
                                                    resolvingAgainstBaseURL:NO];
        NSArray *queryItems = URLComponents.queryItems;
        NSMutableDictionary *dic = @{}.mutableCopy;
        for (NSURLQueryItem *item in queryItems) {
            if (item.name && item.value) {
                [dic setObject:item.value forKey:item.name];
            }
        }
        return dic;
    }
}

+ (NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)paramsFromJson:(NSString *)json
{
    if (!json.length) {
        return nil;
    }
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error) {
        GTLog(@"GTMediator-GTRouter [Error] Wrong URL Query Format: \n%@", error.description);
    }
    return dic;
}


+ (UIViewController *)currentViewController
{
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (viewController) {
        if ([viewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tbvc = (UITabBarController*)viewController;
            viewController = tbvc.selectedViewController;
        } else if ([viewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nvc = (UINavigationController*)viewController;
            viewController = nvc.topViewController;
        } else if (viewController.presentedViewController) {
            viewController = viewController.presentedViewController;
        } else if ([viewController isKindOfClass:[UISplitViewController class]] &&
                   ((UISplitViewController *)viewController).viewControllers.count > 0) {
            UISplitViewController *svc = (UISplitViewController *)viewController;
            viewController = svc.viewControllers.lastObject;
        } else  {
            return viewController;
        }
    }
    return viewController;
}

+ (NSDictionary<NSString *, id> *)solveURLParams:(NSDictionary<NSString *, id> *)URLParams
                                  withFuncParams:(NSDictionary<NSString *, id> *)funcParams
                                        forClass:(Class)mClass
{
    if (!URLParams) {
        URLParams = @{};
    }
    NSMutableDictionary<NSString *, id> *params = URLParams.mutableCopy;
    NSArray<NSString *> *funcParamKeys = funcParams.allKeys;
    [funcParamKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [params setObject:funcParams[obj] forKey:obj];
    }];
    if (mClass) {
        NSArray<NSString *> *paramKeys = params.allKeys;
        [paramKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            objc_property_t prop = class_getProperty(mClass, obj.UTF8String);
            if (!prop) {
                [params removeObjectForKey:obj];
            } else {
                NSString *propAttr = [[NSString alloc] initWithCString:property_getAttributes(prop) encoding:NSUTF8StringEncoding];
                NSRange range = [propAttr rangeOfString:GTRClassRegex options:NSRegularExpressionSearch];
                if (range.length != 0) {
                    NSString *propClassName = [propAttr substringWithRange:range];
                    Class propClass = objc_getClass([propClassName UTF8String]);
                    if ([propClass isSubclassOfClass:[NSString class]] && [params[obj] isKindOfClass:[NSNumber class]]) {
                        [params setObject:[NSString stringWithFormat:@"%@", params[obj]] forKey:obj];
                    } else if ([propClass isSubclassOfClass:[NSNumber class]] && [params[obj] isKindOfClass:[NSString class]]) {
                        [params setObject:@(((NSString *)params[obj]).doubleValue) forKey:obj];
                    }
                    
                }
            }
        }];
    }
    return params;
}

+ (void)setObject:(id)object
    withPropertys:(NSDictionary<NSString *, id> *)propertys
{
    if (!object) {
        return;
    }
    [propertys enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [object setValue:obj forKey:key];
    }];
}


+ (id)safePerformAction:(SEL)action
              forTarget:(NSObject *)target
             withParams:(NSDictionary *)params
{
    NSMethodSignature * sig = [target methodSignatureForSelector:action];
    if (!sig) { return nil; }
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    if (!inv) { return nil; }
    [inv setTarget:target];
    [inv setSelector:action];
    NSArray<NSString *> *keys = params.allKeys;
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(NSString *  _Nonnull obj1, NSString *  _Nonnull obj2) {
        if (obj1.integerValue < obj2.integerValue) {
            return NSOrderedAscending;
        } else if (obj1.integerValue == obj2.integerValue) {
            return NSOrderedSame;
        } else {
            return NSOrderedDescending;
        }
    }];
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id value = params[obj];
        [inv setArgument:&value atIndex:idx+2];
    }];
    [inv invoke];
    return [NSObject gt_getReturnFromInv:inv withSig:sig];
}

+ (void)solveJumpWithViewController:(UIViewController *)viewController
                        andJumpMode:(GTRViewControlerEnterMode)enterMode
                      shouldAnimate:(BOOL)animate
{
    UIViewController *currentViewController = [self currentViewController];



    switch (enterMode) {
        case GTRViewControlerEnterModePush:
            [[GTMediatorNavigator shareInstance] showController:viewController baseViewController:currentViewController routeMode:NavigationModePush];
            break;
        case GTRViewControlerEnterModeModal:
            [[GTMediatorNavigator shareInstance] showController:viewController baseViewController:currentViewController routeMode:NavigationModePresent];
            break;
        case GTRViewControlerEnterModeShare:
            [[GTMediatorNavigator shareInstance] showController:viewController baseViewController:currentViewController routeMode:NavigationModeShare];
            break;
        default:
            break;
    }
}

@end
