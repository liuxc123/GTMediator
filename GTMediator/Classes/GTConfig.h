//
//  GTConfig.h
//  FBSnapshotTestCase
//
//  Created by liuxc on 2018/11/10.
//

#import <Foundation/Foundation.h>

@interface GTConfig : NSObject

+ (instancetype)shareInstance;

+ (id)get:(NSString *)key;

+ (BOOL)has:(NSString *)key;

+ (void)add:(NSDictionary *)parameters;

+ (NSMutableDictionary *)getAll;

+ (NSString *)stringValue:(NSString *)key;

+ (NSDictionary *)dictionaryValue:(NSString *)key;

+ (NSInteger)integerValue:(NSString *)key;

+ (float)floatValue:(NSString *)key;

+ (BOOL)boolValue:(NSString *)key;

+ (NSArray *)arrayValue:(NSString *)key;

+ (void)set:(NSString *)key value:(id)value;

+ (void)set:(NSString *)key boolValue:(BOOL)value;

+ (void)set:(NSString *)key integerValue:(NSInteger)value;

+ (void)clear;

@end

