//
//  NSObject+entityDetail.h
//  DemoThree
//
//  Created by 刘恒 on 15/9/9.
//  Copyright (c) 2015年 ihop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef enum networkOperationType{
    ResponseType,
    RequestType
}networkOperationType;

@interface NSObject (entityDetail)

/*
    数组第一个元素为NSObject prop
    第二个元素为NSObject value
    *type 留以后拓展
 */
- (NSMutableArray *) entityDetailType:(networkOperationType)type;

/**
 *  自定义键值对
 *
 *  @param key    当前键
 *  @param entity 当前值
 */
-(void)DsSetValueAndUndefinedKey:(NSDictionary *)key underfinedEntity:(NSString *)entity;
@end
