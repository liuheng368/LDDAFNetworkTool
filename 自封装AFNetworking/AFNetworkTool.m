//
//  AFNetworkTool.m
//  AFNetText2.5
//
//  Created by wxxu on 15/1/27.
//  Copyright (c) 2015年 wxxu. All rights reserved.
//

#import "AFNetworkTool.h"

NSString *const kHeadCode = @"headcode";
NSString *const kHeadMessage = @"message";
NSString *const kUnknownHeadCode = @"0000";
NSString *const kUnknownHeadMessage = @"未知错误";

@implementation AFNetworkTool

#pragma mark - JSON方式get获取数据
+ (void)fetchGetJSONDataWithUrl:(NSString *)url parameters:(id)parameters success:(void (^)(id json))success fail:(void (^)())fail
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if (fail) {
            fail();
        }
    }];
}

#pragma mark - JSON方式post提交数据
+ (void)fetchPostJSONWithUrl:(NSString *)urlStr request:(id)request response:(NSString *)response success:(RequestSuccessBlock)success fail:(RequestFailBlock)fail;
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 设置请求格式
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    // 设置返回格式
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary *dicParamenters;
    if ([request isKindOfClass:[NSDictionary class]]) {
        dicParamenters = request;
    }
    else if ([request isKindOfClass:[NSObject class]])
    {
       dicParamenters = [ObjCode entityToDictionary:request];
    }
    
    if ([NetworkMonitoring sharedNetworkMonitoring] != AFNetworkReachabilityStatusNotReachable) {
        [manager POST:Network_Test_Url(urlStr) parameters:dicParamenters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (success) {
                if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *code = @{kHeadCode:responseObject[kHeadCode],kHeadMessage:responseObject[kHeadMessage]};
                    success([ObjCode DictionaryToentity:responseObject response:response],code);
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (fail) {
                NetworkError *err = [[NetworkError alloc] init];
                if (operation.responseObject) {
                    err.rspObject = operation.responseObject;
                    err.rspCode = operation.responseObject[kHeadCode];
                    err.rspMessage = operation.responseObject[kHeadMessage];
                    err.entityName = response;
                    
                }
                else
                {
                    err.rspCode = kUnknownHeadCode;
                    err.rspMessage = kUnknownHeadMessage;
                    err.entityName = response;
                    fail(err,error);
                }
                fail(err,error);
            }
        }];
    }
}


#pragma mark - 文件上传 自己定义文件名
+ (void)fetchPostUploadWithUrl:(NSString *)urlStr fileUrl:(NSURL *)fileURL name:(NSString *)name fileName:(NSString *)fileName fileType:(NSString *)fileTye success:(void (^)(id responseObject))success fail:(void (^)())fail;
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:urlStr parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSError *error;
        [formData appendPartWithFileURL:fileURL name:name fileName:fileName mimeType:fileTye error:&error];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (fail) {
            fail();
        }
    }];
}

@end
