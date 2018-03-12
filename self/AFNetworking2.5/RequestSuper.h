//
//  RequestSuper.h
//  Ihop
//
//  Created by 刘恒 on 15/9/9.
//  Copyright (c) 2015年 ihop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "ObjCode.h"
#import "NetworkError.h"
#import "NetworkMonitoring.h"
#import "LoadingViewSuper.h"
extern NSString *const kHeadCode;
extern NSString *const kHeadMessage;
extern NSString *const kUnknownHeadCode;
extern NSString *const kUnknownHeadMessage;

/**
 *  成功回调
 *
 *  @param responseObject 请求实体
 *  @param options        请求头，使用kHeadCode、kHeadMessage来取出对应value
 */
typedef void(^RequestSuccessBlock)(id responseObject, NSDictionary *options);
/**
 *  错误回调
 *
 *  @param errorObj 接口返回错误信息
 *  @param error    错误描述
 */
typedef void(^RequestFailBlock)(NetworkError *errorObj, NSError *error);
/**
 *  取消点击事件
 *  只需带额外事件，无需实现关闭弹框、停止请求
 */
typedef void(^BlockAction)(void);

@interface RequestSuper : NSObject
@property (nonatomic,copy) NSString *sessionid; //登录后必传
@property (nonatomic,copy) NSString *service;   //该请求接口服务名
@property (nonatomic,copy) NSString *seq_no;    //不使用缓存
/**
 *  请求弹框,不带取消按钮
 *
 *  @param title 弹框文案
 */
+ (LoadingViewLayout *)startLoadViewTitle:(NSString *)loadingTitle;

/**
 *  请求弹框,带取消按钮
 *
 *  @param title 弹框文案
 */
+ (LoadingViewLayout *)startAndCancleLoadViewTitle:(NSString *)loadingTitle actionBlock:(BlockAction)block;
+ (void)hideLoadView;



/**
 *  JSON方式get请求
 *
 *  @param success  成功
 *  @param fail     失败
 */
- (void)startGetJSONDataWithSuccess:(RequestSuccessBlock)success fail:(RequestFailBlock)fail loadingTitle:(NSString *)loadingTitle;
/**
 *  JSON方式post请求
 *
 *  @param success  成功
 *  @param fail     失败
 */
- (void)startPostJSONWithSuccess:(RequestSuccessBlock)success fail:(RequestFailBlock)fail loadingTitle:(NSString *)loadingTitle;

/**
 *  JSON方式PUT请求
 *
 *  @param success  成功
 *  @param fail     失败
 */
- (void)startPutJSONWithSuccess:(RequestSuccessBlock)success fail:(RequestFailBlock)fail loadingTitle:(NSString *)loadingTitle;

/**
 *  JSON方式Delete请求
 *
 *  @param success  成功
 *  @param fail     失败
 */
- (void)startDeleteJSONWithSuccess:(RequestSuccessBlock)success fail:(RequestFailBlock)fail loadingTitle:(NSString *)loadingTitle;

/**
 *  JSON方式post提交文件
 *
 *  @param data     二进制文件
 *  @param name     上传文件参数名
 *  @param fileRequestName 文件服务器保存名
 *  @param fileType  文件类型
 *  @param success  成功
 *  @param fail     失败
 */
- (void)startPostUploadData:(NSData *)data fileRequestName:(NSString *)fileRequestName fileName:(NSString *)fileName fileType:(NSString *)fileTye success:(RequestSuccessBlock)success fail:(RequestFailBlock)fail loadingTitle:(NSString *)loadingTitle;

/**
 *  JSON方式post提交文件
 *
 *  @param FilePath 文件路径
 *  @param name     上传文件参数名
 *  @param fileRequestName 文件服务器保存名
 *  @param fileTye  文件类型
 *  @param success  成功
 *  @param fail     失败
 */
- (void)startPostUploadFilePath:(NSString *)filePath fileName:(NSString *)fileName success:(RequestSuccessBlock)success fail:(RequestFailBlock)fail loadingTitle:(NSString *)loadingTitle;

- (AFHTTPRequestOperationManager *)shareRequestOperationManager;
/**
 *  取消所有请求
 */
+ (void)cancelAllRequest;
@end
