//
//  NSObject+entityDetail.m
//  DemoThree
//
//  Created by 刘恒 on 15/9/9.
//  Copyright (c) 2015年 ihop. All rights reserved.
//

#import "NSObject+entityDetail.h"

@implementation NSObject (entityDetail)

- (NSMutableArray *) entityDetailType:(networkOperationType)type
{
    NSMutableArray *muArr = [NSMutableArray array];
    Class clazz = [self class];
    NSMutableArray *propertyArray = [NSMutableArray array];
    NSMutableArray *valueArray = [NSMutableArray array];
    [self entityPropertKey:propertyArray value:valueArray class:clazz];
    if (type == RequestType) {
        [self entityPropertKey:propertyArray value:valueArray class:[self superclass]];
    }
    [muArr addObject:propertyArray];
    [muArr addObject:valueArray];
    return muArr;
}

- (void)entityPropertKey:(NSMutableArray *)propertyArray value:(NSMutableArray *)valueArray class:(Class)clazz
{
    u_int count;
    objc_property_t *properties = class_copyPropertyList(clazz, &count);
    for (int i=0 ; i < count; i++) {
        objc_property_t prop = properties[i];
        NSString *propName = [NSString stringWithFormat:@"%s",property_getName(prop)];
        [propertyArray addObject:propName];
        id value = [self valueForKey:propName];
        if (value == nil) {
            [valueArray addObject:[NSNull null]];
        }
        else{
            [valueArray addObject:value];
        }
    }
}

-(void)DsSetValueAndUndefinedKey:(NSDictionary *)KeyAndValue underfinedEntity:(NSString *)entity;
{
     NSLog(@"-----未完整定义键值%@ : %@， 对应实体：%@",KeyAndValue[@"key"],KeyAndValue[@"value"],entity);
}
@end
