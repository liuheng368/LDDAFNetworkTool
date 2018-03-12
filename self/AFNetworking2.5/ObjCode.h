//
//  ObjCode.h
//  数据解析
//
//  Created by 刘恒 on 15/9/8.
//  Copyright (c) 2015年 ihop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+entityDetail.h"
@interface ObjCode : NSObject

+ (NSDictionary *) entityToDictionary:(id)entity;
+ (id) DictionaryToEntity:(NSDictionary *)dic response:(NSString *)response;
@end
