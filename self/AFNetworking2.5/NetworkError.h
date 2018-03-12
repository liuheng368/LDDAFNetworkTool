//
//  NetworkError.h
//  Ihop
//
//  Created by 刘恒 on 15/9/10.
//  Copyright (c) 2015年 ihop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkError : NSObject

@property (nonatomic, strong) id rspObject;
/** 接口Code */
@property (nonatomic, copy) NSString *rspCode;
/** 接口描述 **/
@property (nonatomic, copy) NSString *rspMessage;

@property (nonatomic, copy) NSString *entityName;

@end
