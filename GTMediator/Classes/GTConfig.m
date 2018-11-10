//
//  GTConfig.m
//  FBSnapshotTestCase
//
//  Created by liuxc on 2018/11/10.
//

#import "GTConfig.h"
#import "GTCommon.h"

@interface GTConfig()

@property (nonatomic, strong) NSMutableDictionary *config;

@end

@implementation GTConfig

static GTConfig *_GTConfigInstance;

+ (instancetype)shareInstance
{
    static dispatch_once_t p;

    dispatch_once(&p, ^{
        _GTConfigInstance = [[[self class] alloc] init];
    });
    return _GTConfigInstance;
}

+ (NSString *)stringValue:(NSString *)key
{
    if (![GTConfig shareInstance].config) {
        return nil;
    }
    return (NSString *)[[GTConfig shareInstance].config objectForKey:key];
}

+ (NSDictionary *)dictionaryValue:(NSString *)key
{
    if (![GTConfig shareInstance].config) {
        return nil;
    }

    if (![[[GTConfig shareInstance].config objectForKey:key] isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    return (NSDictionary *)[[GTConfig shareInstance].config objectForKey:key];
}

+ (NSArray *)arrayValue:(NSString *)key
{
    if (![GTConfig shareInstance].config) {
        return nil;
    }

    if (![[[GTConfig shareInstance].config objectForKey:key] isKindOfClass:[NSArray class]]) {
        return nil;
    }

    return (NSArray *)[[GTConfig shareInstance].config objectForKey:key];
}

+ (NSInteger)integerValue:(NSString *)key
{
    if (![GTConfig shareInstance].config) {
        return 0;
    }

    return [[[GTConfig shareInstance].config objectForKey:key] integerValue];
}

+ (float)floatValue:(NSString *)key
{
    if (![GTConfig shareInstance].config) {
        return 0.0;
    }

    return [(NSNumber *)[[GTConfig shareInstance].config objectForKey:key] floatValue];
}

+ (BOOL)boolValue:(NSString *)key
{
    if (![GTConfig shareInstance].config) {
        return NO;
    }

    return [(NSNumber *)[[GTConfig shareInstance].config objectForKey:key] boolValue];
}


+ (id)get:(NSString *)key
{
    if (![GTConfig shareInstance].config) {
        @throw [NSException exceptionWithName:@"ConfigNotInitialize" reason:@"config not initialize" userInfo:nil];

        return nil;
    }

    id v = [[GTConfig shareInstance].config objectForKey:key];
    if (!v) {
        GTLog(@"InvaildKeyValue %@ is nil", key);
    }

    return v;
}

+ (BOOL)has:(NSString *)key
{
    if (![GTConfig shareInstance].config) {
        return NO;
    }

    if (![[GTConfig shareInstance].config objectForKey:key]) {
        return NO;
    }

    return YES;
}

+ (void)set:(NSString *)key value:(id)value
{
    if (![GTConfig shareInstance].config) {
        [GTConfig shareInstance].config = [[NSMutableDictionary alloc] initWithCapacity:10];
    }

    [[GTConfig shareInstance].config setObject:value forKey:key];
}


+ (void)set:(NSString *)key boolValue:(BOOL)value
{
    [self set:key value:[NSNumber numberWithBool:value]];
}

+ (void)set:(NSString *)key integerValue:(NSInteger)value
{
    [self set:key value:[NSNumber numberWithInteger:value]];
}


+ (void)add:(NSDictionary *)parameters
{
    if (![GTConfig shareInstance].config) {
        [GTConfig shareInstance].config = [[NSMutableDictionary alloc] initWithCapacity:10];
    }

    [[GTConfig shareInstance].config addEntriesFromDictionary:parameters];
}

+ (NSDictionary *)getAll
{
    return [GTConfig shareInstance].config;
}

+ (void)clear
{
    if ([GTConfig shareInstance].config) {
        [[GTConfig shareInstance].config removeAllObjects];
    }
}


@end
