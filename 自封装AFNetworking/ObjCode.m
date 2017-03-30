//
//  ObjCode.m
//  DemoThree
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

+ (id)DictionaryToentity:(NSDictionary *)dic response:(NSString *)response
{
    if ([dic isKindOfClass:[NSDictionary class]]) {
        return recursionOfDictonary(dic,response);
    }
    return nil;
}

static id recursionOfDictonary (NSDictionary *dic,
                                NSString *ResponseName)
{
    NSObject *responseSuper = [[NSClassFromString(ResponseName) alloc] init];
    NSArray *propKey = [[responseSuper entityDetailType:ResponseType] firstObject];
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id objSup, BOOL *stop) {
        if (!([key isEqualToString:@"message"] || [key isEqualToString:@"headcode"])) {
            [propKey enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stopTwo) {
                if ([obj isEqualToString:key]) {
                    if ([objSup isKindOfClass:[NSString class]] || [objSup isKindOfClass:[NSNumber class]]) {
                        [responseSuper setValue:objSup forKey:propKey[idx]];
                    }
                    if ([objSup isKindOfClass:[NSArray class]]) {
                        [responseSuper setValue:recursionOfArray(objSup, propKey[idx]) forKey:propKey[idx]];
                    }
                    if ([objSup isKindOfClass:[NSDictionary class]]) {
                        [responseSuper setValue:recursionOfDictonary(objSup, propKey[idx]) forKey:propKey[idx]];
                    }
                    *stopTwo = YES;
                    return;
                }
                if (idx == propKey.count - 1) {
                    [responseSuper performSelector:@selector(DsSetValueAndUndefinedKey:underfinedEntity:) withObject:@{@"key":key,@"value":objSup} withObject:responseSuper];
                }
            }];
        }
    }];
    return responseSuper;
}

static NSArray* recursionOfArray (NSArray *arr,
                                  NSString *ResponseName)
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:arr.count];
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            [array addObject:obj];
        }
        if ([obj isKindOfClass:[NSArray class]]) {
            if (recursionOfArray(obj, ResponseName)) {
                [array addObject:recursionOfArray(obj, ResponseName)];
            }
        }
        if ([obj isKindOfClass:[NSDictionary class]]) {
            if (recursionOfDictonary(obj, ResponseName)) {
                 [array addObject:recursionOfDictonary(obj, ResponseName)];
            }
        }
    }];
    return array;
}

@end
