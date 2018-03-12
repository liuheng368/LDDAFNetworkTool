//
//  NSObject+entityDetail.h
//  请求相关实体处理
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
 *  若对应该值不是NSString，则必须要返回修改后键的名称。反之非必须
 *
 *  @param key    当前键
 *  @param entity 当前值
 *
 *  @return 修改后键的名称
 */
-(NSString *)DsSetValueAndUndefinedKey:(NSDictionary *)key underfinedEntity:(NSString *)entity;
@end
