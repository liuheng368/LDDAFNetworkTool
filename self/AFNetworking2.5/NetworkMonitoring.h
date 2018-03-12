//
//  NetworkMonitoring.h
//  Ihop
//
//  Created by 刘恒 on 15/9/10.
//  Copyright (c) 2015年 ihop. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^NetworkChangeBlock)(AFNetworkReachabilityStatus);
@interface NetworkMonitoring : NSObject<UIAlertViewDelegate>

typedef NS_ENUM(NSInteger, AFNetworkStatus) {
    AFNetworkStatusUnknown          = -1,       //未知
    AFNetworkStatusNotReachable     = 0,        //无网络
    AFNetworkStatusVia2G            = 1,
    AFNetworkStatusVia3G            = 2,
    AFNetworkStatusVia4G            = 3,
    AFNetworkStatusViaWiFi          = 5,
};


/**
 *  获取网路状态（默认开启）
 *
 *  @return 网络当前状态
 */
+ (AFNetworkStatus)sharedNetworkMonitoring;

/**
 *  关闭监听
 */
+ (void)stopNetworkMonitoring;
@end
