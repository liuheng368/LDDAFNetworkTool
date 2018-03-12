//
//  ObjCode.m
//  Ihop
//
//  Created by 刘恒 on 15/9/8.
//  Copyright (c) 2015年 ihop. All rights reserved.
//

#import "ObjCode.h"

@implementation ObjCode

+ (NSDictionary *) entityToDictionary:(id)entity
{
    NSMutableArray *propArray;
    if (entity && [entity isKindOfClass:[NSObject class]]) {
       propArray = [entity entityDetailType:RequestType];
    }
    NSDictionary* returnDic = [NSDictionary dictionaryWithObjects:[propArray lastObject] forKeys:[propArray firstObject]];
    return returnDic;
}

+ (id)DictionaryToEntity:(NSDictionary *)dic response:(NSString *)response
{
    if ([dic isKindOfClass:[NSDictionary class]]) {
        
        return [self recursionOfDictonary:dic string:response];
    }
    return nil;
}

+ (id)recursionOfDictonary:(NSDictionary *)dic string:(NSString *)ResponseName
{
    if (![dic isKindOfClass:[NSDictionary class]]) {return nil;}
    NSObject *responseSuper = [[NSClassFromString(ResponseName) alloc] init];
    NSAssert(responseSuper, @"LHeng_对象创建失败:验证%@类是否存在或@implementation是否实现", ResponseName);
    if ([dic count] <= 0) return responseSuper;
    
    NSArray *propKey = [[responseSuper entityDetailType:ResponseType] firstObject];
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id objSup, BOOL *stop) {
        if (!([key isEqualToString:@"message"] || [key isEqualToString:@"headcode"])) {
            [propKey enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stopTwo) {
                if ([obj isEqualToString:key]) {
                    if ([objSup isKindOfClass:[NSString class]] || [objSup isKindOfClass:[NSNumber class]]) {
                        [responseSuper setValue:objSup forKey:propKey[idx]];
                    }
                    if ([objSup isKindOfClass:[NSArray class]]) {
                        [responseSuper setValue:[self recursionOfArray:objSup string:propKey[idx]] forKey:propKey[idx]];
                    }
                    if ([objSup isKindOfClass:[NSDictionary class]]) {
                        [responseSuper setValue:[self recursionOfDictonary:objSup string:propKey[idx]] forKey:propKey[idx]];
                    }
                    *stopTwo = YES;
                    return;
                }
                if (idx == propKey.count - 1) {
                    //此处为自定义键值处理
                    NSString *ress = [responseSuper performSelector:@selector(DsSetValueAndUndefinedKey:underfinedEntity:) withObject:@{@"key":key,@"value":objSup} withObject:responseSuper];
                    if (ress.length>0) {
                        if ([objSup isKindOfClass:[NSArray class]]) {
                            [responseSuper setValue:[self recursionOfArray:objSup string:ress] forKey:ress];
                        }
                        if ([objSup isKindOfClass:[NSDictionary class]]) {
                            [responseSuper setValue:[self recursionOfDictonary:objSup string:ress] forKey:ress];
                        }
                    }
                }
            }];
        }
    }];
    return responseSuper;
}

+ (NSArray*)recursionOfArray:(NSArray *)arr string:(NSString *)ResponseName
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:arr.count];
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
            [array addObject:obj];
        }
        if ([obj isKindOfClass:[NSArray class]]) {
                [array addObject:[self recursionOfArray:obj string:ResponseName]];
        }
        if ([obj isKindOfClass:[NSDictionary class]]) {
                 [array addObject:[self recursionOfDictonary:obj string:ResponseName]];
        }
    }];
    return array;
}

@end
