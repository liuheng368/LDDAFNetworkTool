//
//  ObjCode.h
//  DemoThree
//
//  Created by 刘恒 on 15/9/8.
//  Copyright (c) 2015年 ihop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+entityDetail.h"
@interface ObjCode : NSObject

+ (NSDictionary *) entityToDictionary:(id)entity;
+ (id) DictionaryToentity:(NSDictionary *)dic response:(NSString *)response;
@end
