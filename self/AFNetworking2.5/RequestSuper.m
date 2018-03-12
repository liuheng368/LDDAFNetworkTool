//
//  RequestSuper.m
//  Ihop
//
//  Created by 刘恒 on 15/9/9.
//  Copyright (c) 2015年 ihop. All rights reserved.
//

#import "RequestSuper.h"

NSString *const kHeadCode = @"headcode";
NSString *const kHeadMessage = @"message";
NSString *const kUnknownHeadCode = @"0000";
NSString *const kUnknownHeadMessage = @"未知错误";

typedef enum enumNetWorkType
{
    enumNetWorkGet = 0 ,
    enumNetWorkPost,
    enumNetWorkPut,
    enumNetWorkDelete
}enumNetWorkType;

@implementation RequestSuper

- (AFHTTPRequestOperationManager *)shareRequestOperationManager {
    static AFHTTPRequestOperationManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPRequestOperationManager manager];
    });
    return manager;
}

-(instancetype)init
{
    if (self = [super init]) {
        self.sessionid = [UserInformation fetchUserInfo].sessionid;
        self.seq_no = [NSString stringWithFormat:@"%@",[NSDate date]];
    }
    return self;
}

#pragma mark - loadView
+ (LoadingViewLayout *)startLoadViewTitle:(NSString *)loadingTitle
{
    LoadingViewLayout * loadView = [LoadingViewLayout shareLoadingView];
    LoadingViewSuper *load = [LoadingViewSuper shareLoadingViewSuper];
    loadView.delegate = load;
    load.isCancle = NO;
    load.strTitle = loadingTitle;
    [loadView uploadLoadingView:load];
    [loadView presentLoadingView];
    return loadView;
}

+ (LoadingViewLayout *)startAndCancleLoadViewTitle:(NSString *)loadingTitle actionBlock:(BlockAction)block
{
    LoadingViewLayout * loadView = [LoadingViewLayout shareLoadingView];
    LoadingViewSuper *load = [LoadingViewSuper shareLoadingViewSuper];
    load.isCancle = YES;
    loadView.delegate = load;
    load.strTitle = loadingTitle;
    if (block) {
        [load setBlockCancle:^{
            block();
        }];
    }
    [loadView uploadLoadingView:load];
    [loadView presentLoadingView];
    return loadView;
}

+ (void)hideLoadViewDelay
{
    LoadingViewLayout * loadView = [LoadingViewLayout shareLoadingView];
    [loadView delayStopLoadingView];
}

+ (void)hideLoadView
{
    LoadingViewLayout * loadView = [LoadingViewLayout shareLoadingView];
    [loadView stopLoadingView];
}

#pragma mark - JSON方式get获取数据
- (void)startGetJSONDataWithSuccess:(RequestSuccessBlock)success fail:(RequestFailBlock)fail loadingTitle:(NSString *)loadingTitle
{
    [self fetchUploadWithSuccess:success fail:fail type:enumNetWorkGet loadingTitle:loadingTitle];
}

#pragma mark - JSON方式post提交数据
- (void)startPostJSONWithSuccess:(RequestSuccessBlock)success fail:(RequestFailBlock)fail loadingTitle:(NSString *)loadingTitle
{
    [self fetchUploadWithSuccess:success fail:fail type:enumNetWorkPost loadingTitle:loadingTitle];
}

#pragma mark - JSON方式Put提交数据
- (void)startPutJSONWithSuccess:(RequestSuccessBlock)success fail:(RequestFailBlock)fail loadingTitle:(NSString *)loadingTitle
{
    [self fetchUploadWithSuccess:success fail:fail type:enumNetWorkPut loadingTitle:loadingTitle];
}

#pragma mark - JSON方式Delete提交数据
- (void)startDeleteJSONWithSuccess:(RequestSuccessBlock)success fail:(RequestFailBlock)fail loadingTitle:(NSString *)loadingTitle
{
    [self fetchUploadWithSuccess:success fail:fail type:enumNetWorkDelete loadingTitle:loadingTitle];
}

- (void)fetchUploadWithSuccess:(RequestSuccessBlock)success fail:(RequestFailBlock)fail type:(enumNetWorkType)enumType loadingTitle:(NSString *)loadingTitle
{
    //loadView
    LoadingViewLayout *loadView;
    if (loadingTitle.length > 0) {
        loadView = [RequestSuper startAndCancleLoadViewTitle:loadingTitle actionBlock:nil];
    }
    
    AFNetworkStatus status = [NetworkMonitoring sharedNetworkMonitoring];
    if (status != AFNetworkStatusUnknown && status != AFNetworkStatusNotReachable)
    {
        Class rspClass = [self class];
        NSString *strResquest = NSStringFromClass(rspClass);
        NSMutableString *response = [strResquest mutableCopy];
        NSRange range = [strResquest rangeOfString:@"Request"];
        NSAssert(range.location != NSNotFound, @"LHeng_Request对象查询失败:验证%@是否满足Request + 接口名这种格式 ",strResquest);
        [response replaceCharactersInRange:range withString:@"Response"];
        
        //    [NetworkMonitoring sharedNetworkMonitoring];
        AFHTTPRequestOperationManager *manager = [self shareRequestOperationManager];
        
        [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        manager.requestSerializer.timeoutInterval = 10.0f;
        [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        
        // 设置请求格式
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        // 设置返回格式
        AFJSONResponseSerializer *res = [AFJSONResponseSerializer serializer];
        res.removesKeysWithNullValues = YES;
        manager.responseSerializer = res;
        NSDictionary *dicParamenters = [ObjCode entityToDictionary:self];
        switch (enumType) {
            case enumNetWorkGet:
            {
                [manager GET:DS_Get_NetworkUrl(self.service) parameters:dicParamenters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if (loadView) {
                        [loadView delayStopLoadingView];
                    }
                    if (success) {
                        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *code = @{kHeadCode:responseObject[kHeadCode],kHeadMessage:responseObject[kHeadMessage]};
                            success([ObjCode DictionaryToEntity:responseObject response:response],code);
                        }
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                    if (loadView) {
//                        [loadView delayStopLoadingView];
//                    }
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
                break;
            case enumNetWorkPost:
            {
                [manager POST:DS_Get_NetworkUrl(self.service)
                   parameters:dicParamenters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                       if (loadView) {
                           [loadView delayStopLoadingView];
                       }
                       if (success) {
                           if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                               NSDictionary *code = @{kHeadCode:responseObject[kHeadCode],kHeadMessage:responseObject[kHeadMessage]};
                               success([ObjCode DictionaryToEntity:responseObject response:response],code);
                           }
                       }
                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                       if (loadView) {
//                           [loadView delayStopLoadingView];
//                       }
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
                               return;
                           }
                           fail(err,error);
                       }
                   }];
            }
                break;
            case enumNetWorkPut:
            {
                [manager PUT:DS_Get_NetworkUrl(self.service) parameters:dicParamenters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if (loadView) {
                        [loadView delayStopLoadingView];
                    }
                    if (success) {
                        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *code = @{kHeadCode:responseObject[kHeadCode],kHeadMessage:responseObject[kHeadMessage]};
                            success([ObjCode DictionaryToEntity:responseObject response:response],code);
                        }
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                    if (loadView) {
//                        [loadView delayStopLoadingView];
//                    }
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
                break;
            case enumNetWorkDelete:
            {
                [manager DELETE:DS_Get_NetworkUrl(self.service) parameters:dicParamenters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if (loadView) {
                        [loadView delayStopLoadingView];
                    }
                    if (success) {
                        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *code = @{kHeadCode:responseObject[kHeadCode],kHeadMessage:responseObject[kHeadMessage]};
                            success([ObjCode DictionaryToEntity:responseObject response:response],code);
                        }
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                    if (loadView) {
//                        [loadView delayStopLoadingView];
//                    }
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
                break;
            default:
                break;
        }
    }
    else
    {
//        [RequestSuper hideLoadViewDelay];
            
//        [[UIApplication sharedApplication].delegate.window showHUDWithText:@"网络异常！" Type:ShowTextOnly];
        
//        __weak __typeof(self) weakSelf = self;
//        [DSAlertController alertAndCancleConTitle:@"网络异常" alertMessage:@"请检查设备网络状态或稍后重试" alertAction:[DSAlertViewAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault action:^{
//            [weakSelf fetchUploadWithSuccess:success fail:fail type:enumType loadingTitle:loadingTitle];
//        }] superVC:nil];
        
    }
//    NSDictionary *dicParamenters = [ObjCode entityToDictionary:self];
//    NSLog(@"%@+++++%@", DS_Get_NetworkUrl(self.service), dicParamenters);
}

#pragma mark JSON方式提交data数据
- (void)startPostUploadData:(NSData *)data fileRequestName:(NSString *)fileRequestName fileName:(NSString *)fileName fileType:(NSString *)fileTye success:(RequestSuccessBlock)success fail:(RequestFailBlock)fail loadingTitle:(NSString *)loadingTitle
{
    Class rspClass = [self class];
    NSString *strResquest = NSStringFromClass(rspClass);
    NSMutableString *response = [strResquest mutableCopy];
    NSRange range = [strResquest rangeOfString:@"Request"];
    NSAssert(range.location != NSNotFound, @"LHeng_Request对象查询失败:验证%@是否满足Request + 接口名这种格式 ",strResquest);
    [response replaceCharactersInRange:range withString:@"Response"];
    
    AFHTTPRequestOperationManager *manager = [self shareRequestOperationManager];
    // 设置请求格式
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    // 设置返回格式
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary *dicParamenters = [ObjCode entityToDictionary:self];
    //loadView
    LoadingViewLayout *loadView;
    if (loadingTitle.length > 0) {
        loadView = [RequestSuper startAndCancleLoadViewTitle:loadingTitle actionBlock:nil];
    }
    [manager POST:DS_Get_NetworkUrl(self.service) parameters:dicParamenters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (data.length > 0 ) {
            [formData appendPartWithFileData:data name:fileRequestName fileName:fileName mimeType:fileTye];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (loadView) {
            [loadView delayStopLoadingView];
        }
        if (success) {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *code = @{kHeadCode:responseObject[kHeadCode],kHeadMessage:responseObject[kHeadMessage]};
                success([ObjCode DictionaryToEntity:responseObject response:response],code);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (loadView) {
            [loadView delayStopLoadingView];
        }
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
                return;
            }
            fail(err,error);
        }
    }];
}

#pragma mark JSON方式提交文件
- (void)startPostUploadFilePath:(NSString *)filePath fileName:(NSString *)fileName success:(RequestSuccessBlock)success fail:(RequestFailBlock)fail loadingTitle:(NSString *)loadingTitle
{
    Class rspClass = [self class];
    NSString *strResquest = NSStringFromClass(rspClass);
    NSMutableString *response = [strResquest mutableCopy];
    NSRange range = [strResquest rangeOfString:@"Request"];
    NSAssert(range.location != NSNotFound, @"LHeng_Request对象查询失败:验证%@是否满足Request + 接口名这种格式 ",strResquest);
    [response replaceCharactersInRange:range withString:@"Response"];
    
    AFHTTPRequestOperationManager *manager = [self shareRequestOperationManager];
    // 设置请求格式
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    // 设置返回格式
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary *dicParamenters = [ObjCode entityToDictionary:self];
    //loadView
    LoadingViewLayout *loadView;
    if (loadingTitle.length > 0) {
        loadView = [RequestSuper startAndCancleLoadViewTitle:loadingTitle actionBlock:nil];
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    [manager POST:DS_Get_NetworkUrl(self.service) parameters:dicParamenters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if ([fm fileExistsAtPath:filePath]) {
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:fileName error:nil];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (loadView) {
            [loadView delayStopLoadingView];
        }
        if (success) {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *code = @{kHeadCode:responseObject[kHeadCode],kHeadMessage:responseObject[kHeadMessage]};
                success([ObjCode DictionaryToEntity:responseObject response:response],code);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (loadView) {
            [loadView delayStopLoadingView];
        }
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
                return;
            }
            fail(err,error);
        }
    }];

}

+ (void)cancelAllRequest
{
    RequestSuper *reqSelf = [[RequestSuper alloc] init];
    AFHTTPRequestOperationManager *manager = [reqSelf shareRequestOperationManager];
    [manager.operationQueue cancelAllOperations];
}
@end
