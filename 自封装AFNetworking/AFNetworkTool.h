//
//  AFNetworkTool.h
//  AFNetText2.5
//
//  Created by wxxu on 15/8/28.
//  Copyright (c) 2015年 刘恒. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "ObjCode.h"
#import "NetworkError.h"
#import "NetworkMonitoring.h"

extern NSString *const kHeadCode;
extern NSString *const kHeadMessage;
extern NSString *const kUnknownHeadCode;
extern NSString *const kUnknownHeadMessage;
typedef void(^RequestSuccessBlock)(id responseObject, NSDictionary *options);
typedef void(^RequestFailBlock)(NetworkError *errorObj, NSError *error);


@interface AFNetworkTool : NSObject

/**
 *JSON方式获取数据
 *urlStr:获取数据的url地址
 *parameters:提交的内容参数
 *
 */
+ (void)fetchGetJSONDataWithUrl:(NSString *)url parameters:(id)parameters success:(RequestSuccessBlock)success fail:(RequestFailBlock)fail;

/**
 *JSON方式post提交数据
 *urlStr:服务器地址
 *parameters:提交的内容参数,可以传对象、也可以传字典
 *
 */
+ (void)fetchPostJSONWithUrl:(NSString *)urlStr request:(id)request response:(NSString *)response success:(RequestSuccessBlock)success fail:(RequestFailBlock)fail;

/**
 *文件上传,自己定义文件名
 *urlStr:    需要上传的服务器url
 *fileURL:   需要上传的本地文件URL
 *fileName:  文件在服务器上以什么名字保存，但不可以带文件类型
 *name       服务器端参数名
 *fileTye:   文件类型
 *
 */
+ (void)fetchPostUploadWithUrl:(NSString *)urlStr fileUrl:(NSURL *)fileURL name:(NSString *)name fileName:(NSString *)fileName fileType:(NSString *)fileTye success:(RequestSuccessBlock)success fail:(RequestFailBlock)fail;

@end
