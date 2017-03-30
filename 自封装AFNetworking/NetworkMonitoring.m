//
//  NetworkMonitoring.m
//  DemoThree
//
//  Created by 刘恒 on 15/9/10.
//  Copyright (c) 2015年 ihop. All rights reserved.
//

#import "NetworkMonitoring.h"

@implementation NetworkMonitoring

+ (AFNetworkReachabilityStatus)sharedNetworkMonitoring
{
    static NetworkMonitoring *onceSelf;
    static dispatch_once_t oncePatch;
    dispatch_once(&oncePatch, ^{
        onceSelf = [[NetworkMonitoring alloc] init];
    });
    
    return [onceSelf fetchNetwork];
}

-(AFNetworkReachabilityStatus)fetchNetwork
{
    __weak typeof(self) weakSelf = self;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (_networkChangeBlock) {
            _networkChangeBlock(status);
            UIAlertView *ale = [[UIAlertView alloc] initWithTitle:@"网络异常" message:@"未检测到网络，请重试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [ale show];
        }
        weakSelf.network = status;
    }];
    return self.network;
}

/**
 *  关闭监听
 */
+ (void)stopNetworkMonitoring
{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}
@end
