//
//  NetworkMonitoring.m
//  Ihop
//
//  Created by 刘恒 on 15/9/10.
//  Copyright (c) 2015年 ihop. All rights reserved.
//

#import "NetworkMonitoring.h"
#import "AppDelegate.h"
@implementation NetworkMonitoring
{
    AFNetworkReachabilityStatus statusType;
}

+ (AFNetworkStatus)sharedNetworkMonitoring
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *children = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    NSInteger type = 0;
    for (id chind in children) {
        if ([chind isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            type = [[chind valueForKeyPath:@"dataNetworkType"] integerValue];
            break;
        }
    }
    switch (type) {
        case -1:
        {
            return AFNetworkStatusUnknown;
        }
            break;
        case 0:
        {
            return AFNetworkStatusNotReachable;
        }
            break;
        case 1:
        {
            return AFNetworkStatusVia2G;
        }
            break;
        case 2:
        {
            return AFNetworkStatusVia3G;
        }
            break;
        case 3:
        {
            return AFNetworkStatusVia4G;
        }
            break;
        case 5:
        {
            return AFNetworkStatusViaWiFi;
        }
            break;
        default:
            return AFNetworkStatusUnknown;
            break;
    }
}

/**
 *  关闭监听
 */
+ (void)stopNetworkMonitoring
{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}
@end
